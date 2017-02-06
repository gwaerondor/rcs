defmodule File_poller do

  def start(directory) do
    case file_poller_already_started?() do
      true ->
	{:error, "Already started"}
      false ->
	start_new_poller(directory)
    end
  end
  
  defp file_poller_already_started?() do
    pre_existing = Process.whereis(:file_poller)
    is_pid(pre_existing)
  end

  defp start_new_poller(directory) do
    parent = self()
    ref = make_ref()
    spawn(fn() ->
      Process.register(self(), :file_poller)
      send(parent, {ref, :started})
      abs_directory = Path.absname(directory)
      loop(abs_directory)
    end)
    receive do
      {ref, :started} ->
	:ok
    after
      50 ->
    	{:error, "Couldn't start file poller"}
    end
  end

  def loop(directory) do
    run(directory)
    :timer.sleep(500)
    loop(directory)
  end

  def run(directory) do
    sources = list_source_files(directory)
    beams = list_beam_files(directory)
    :error
  end
  
  def list_source_files(directory) do
    for e <- [".ex", ".exs"] do
      list_files_with_ext(directory, e)
    end |> Enum.concat
  end

  def list_beam_files(directory) do
    list_files_with_ext(directory, ".beam")
  end

  def list_files_with_ext(directory, ext) do
    files = Path.join([directory, "*" <> ext])
    |> Path.wildcard
    for f <- files do
      Path.basename(f)
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
    for m <- modules do
      m
      |> prepend_elixir_if_necessary
      |> append(".beam")
    end
  end

  defp prepend_elixir_if_necessary(module_name) do
    case String.match?(module_name, ~r/[A-Z].*/) do
      true ->
	"Elixir." <> module_name
      false ->
	module_name
    end
  end

  defp append(string, appendage), do: string <> appendage

end
