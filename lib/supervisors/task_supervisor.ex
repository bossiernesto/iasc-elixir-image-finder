defmodule ImageFinder.TaskSupervisor do
  use Supervisor

  alias ImageFinder.{Task}

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [worker(Task, [], restart: :transient)]
    supervise(children, strategy: :simple_one_for_one)
  end

  def append_new_task(link, destination_folder, supervisor, worker) do
    Supervisor.start_child(supervisor, [link, destination_folder, worker])
  end
end
