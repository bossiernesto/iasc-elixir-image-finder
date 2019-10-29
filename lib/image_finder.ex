defmodule ImageFinder do
  use Application
  alias ImageFinder.{Supervisor, WorkerSupervisor}

  def start(_type, _args) do
    ImageFinder.Supervisor.start_link
  end

  def fetch(source_file, target_directory) do
    {:ok, worker} = Supervisor.append_new_worker()
    GenServer.cast(worker, {:fetch, source_file, target_directory})
    :ok
  end
end
