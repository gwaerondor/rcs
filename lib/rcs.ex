defmodule RCS do
  def run() do
    File_poller.start("test/dummies/")
  end
end
