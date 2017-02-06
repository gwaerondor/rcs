ExUnit.start()

defmodule File_poller_test do
  use ExUnit.Case, async: true
  import ExUnit.Assertions

  test "Polling a directory should list all source files" do
    dir = Path.absname("./test/dummies/")
    expected = Enum.sort(["first_dummy.exs"])
    result = Enum.sort(File_poller.list_source_files(dir))
    assert_equal(expected, result)
  end

  test "It should be possible to list all beams in the loaded directory" do
    dir = Path.absname("./test/dummies/")
    expected = ["Elixir.Dummy.beam"]
    result = File_poller.list_beam_files(dir)
    assert_equal(expected, result)
  end
  
  test "Polling a non-existing directory should return an empty list" do
    dir = "../i_do_not_exist/"
    expected = []
    result = File_poller.list_source_files(dir)
    assert_equal(expected, result)
  end

  test "It should be possible to list module names given beams in .../loaded/" do
    input = ["Elixir.First_dummy.beam",
	     "Elixir.Second_dummy.beam",
	     "third_dummy.beam",
	     "invalid_thing.bork"]
    expected = ["First_dummy",
		"Second_dummy",
		"third_dummy"]
    result = File_poller.file_names_to_modules(input)
    assert_equal(expected, result)
  end

  test "It should be possible to expand module names to beam names" do
    input = ["Some_dummy", "another_dummy", "MOAR_DUMMIES"]
    expected = ["Elixir.Some_dummy.beam",
		"another_dummy.beam",
		"Elixir.MOAR_DUMMIES.beam"]
    result = File_poller.modules_to_file_names(input)
    assert_equal(expected, result)
  end

  describe "File poller process related tests" do
    setup do
      File_poller.start("test/dummies/")
      ensure_file_poller_is_alive()
      on_exit(fn() -> kill_file_poller() end)
      :ok
    end
    
    defp kill_file_poller() do
      pid = Process.whereis(:file_poller)
      Process.exit(pid, :kill)
      ensure_file_poller_is_dead()
    end
    
    defp ensure_file_poller_is_alive() do
      case is_pid(Process.whereis(:file_poller)) do
	true ->
	  :ok
	false ->
	  :timer.sleep(10)
	  ensure_file_poller_is_alive()
      end
    end

    defp ensure_file_poller_is_dead() do
      case is_pid(Process.whereis(:file_poller)) do
	true ->
	  :timer.sleep(10)
	  ensure_file_poller_is_dead()
	false ->
	  :ok
      end
    end

    test "It should be possible to register a process that scans a folder" do
      res = Process.whereis(:file_poller)
      assert_not_equal(:nil, res)
    end
    
    test "It should not be possible to start two file pollers" do
      expected = {:error, "Already started"}
      result = File_poller.start("anywhere")
      assert_equal(expected, result)
    end
  end

  test "If source files in loaded; compile and load and move the source" do
    :ok = File.cp("test/dummies/first_dummy.exs", "loaded/first_dummy.exs")
    assert File.exists?("loaded/first_dummy.exs")
    File_poller.run("loaded/")
    refute File.exists?("loaded/first_dummy.exs")
    assert_equal({:module, Dummy}, Code.ensure_loaded(Dummy))
  end
  
  @tag :skip
  test "Trying to compile a bad source file should create a broken entry" do
    assert false
  end

  @tag :skip
  test "If an .ex or .exs is encountered, it should be moved to loaded/src" do
    assert false
  end

  @tag :skip
  test "It should be possible to get the MD5 of all loaded beams" do
    assert false
  end

  @tag :skip
  test "It should be possible to get a list of all loaded modules" do
    assert false
  end

  @tag :skip
  test "It should be possible to get a list of all available functions" do
    assert false
  end

  @tag :skip
  test "It should be possible to delete beams" do
    assert false
  end
  
  defp assert_equal(expected, actual) do
    assert(expected == actual)
  end

  defp assert_not_equal(unexpected, actual) do
    assert(unexpected != actual)
  end
end
