ExUnit.start()

defmodule File_poller_test do
  use ExUnit.Case, async: true
  import ExUnit.Assertions
  
  test "Polling a directory should list all files" do
    dir = "."
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
  
  defp assert_equal(expected, actual) do
    assert(expected == actual)
  end
end
