defmodule ImageFinder.Supervisor do
  use Supervisor
  alias ImageFinder.WorkerSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [supervisor(WorkerSupervisor, [], restart: :transient)]
    supervise(children, strategy: :simple_one_for_one)
  end

  def append_new_worker do
    {:ok, worker_supervisor} = Supervisor.start_child(__MODULE__, [])
    WorkerSupervisor.append_new_worker(worker_supervisor)
  end
end
