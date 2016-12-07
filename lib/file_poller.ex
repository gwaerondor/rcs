defmodule File_poller do

  def start(directory) do
    parent = self()
    spawn(fn() ->
      Process.register(self(), :file_poller)
      send(parent, :started)
      loop(directory)
    end)
    receive do
      :started ->
	:ok
    after
      50 ->
    	{:error, "Couldn't start file poller"}
    end
  end

  def loop(directory) do
    files = list_files(directory)
    modules = file_names_to_modules(files)
    :io.format("Modules: ~p~n", [modules])
    :timer.sleep(500)
    loop(directory)
  end
  
  def list_files(directory) do
    case File.ls(directory) do
      {:ok, files} ->
	files
      error ->
	error
    end
  end

  def file_names_to_modules(file_names) do
    is_beam = &(String.ends_with?(&1, ".beam"))
    for f <- file_names, is_beam.(f) do
	  f
	  |> String.replace_suffix(".beam", "")
	  |> String.replace_prefix("Elixir.", "")
    end
  end

  def modules_to_file_names(modules) do
    
  end
end
