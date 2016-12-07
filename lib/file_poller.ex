defmodule File_poller do
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
end
