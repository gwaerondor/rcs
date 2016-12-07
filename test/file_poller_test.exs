ExUnit.start()

defmodule File_poller_test do
  use ExUnit.Case, async: true
  import ExUnit.Assertions
  
  test "Polling a directory should list all files" do
    dir = "test/dummies"
    expected = Enum.sort(["first_dummy.exs", "Elixir.Dummy.beam"])
    result = Enum.sort(File_poller.list_files(dir))
    assert_equal(expected, result)
  end

  test "Polling a non-existing directory should return an error" do
    dir = "../i_do_not_exist/"
    expected = {:error, :enoent}
    result = File_poller.list_files(dir)
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
  
  test "It should be possible to register a process that scans a folder" do
    File_poller.start("test/dummies/")
    unexpected = nil
    res = Process.whereis(:file_poller)
    Process.exit(res, :killed)
    assert_not_equal(unexpected, res)
  end

  test "It should not be possible to start two file pollers" do
    expected = {:error, "Couldn't start file poller"}
    pid = spawn(fn() ->
      Process.register(self(), :file_poller)
      :timer.sleep(1000)
    end)
    result = File_poller.start("anywhere")
    Process.exit(pid, :kill)
    assert_equal(expected, result)
  end

  @tag :skip
  test "If an .ex or .exs is encountered, compile and load" do
    assert false
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
