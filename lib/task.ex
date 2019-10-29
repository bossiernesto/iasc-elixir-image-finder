defmodule ImageFinder.Task do
  use GenServer

  def start_link(link, destination_folder, worker) do
    state = {link, destination_folder, worker}
    GenServer.start_link(__MODULE__, {:ok, state})
  end

  def init({:ok, state}) do
    GenServer.cast(self(), :start)
    {:ok, state}
  end

  def handle_cast(:start, {link, folder, worker} = state) do
    IO.puts "descargando"
    :timer.sleep(2000)
    IO.puts "Finalizada descarga"
    GenServer.cast(worker, :ready)
    {:stop, :normal, state}
  end
end
