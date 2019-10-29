defmodule ImageFinder.Worker do
  use GenServer

  alias ImageFinder.TaskSupervisor

  def start_link(task_supervisor, worker_supervisor) do
    GenServer.start_link(__MODULE__,{task_supervisor, worker_supervisor})
  end

  def init(supervisors) do
    {:ok, {0, supervisors}}
  end

  def handle_cast({:fetch, source_file, target_directory}, {_, {task_supervisor, _} = supervisors}) do
    links_count = source_file
      |> links
      |> start_tasks(target_directory, task_supervisor)
      |> Enum.count

    {:noreply, {links_count, supervisors}}
  end

  def handle_cast(:ready, state), do: link_downloaded(state)

  def link_downloaded({1, _} = state) do
    {:stop, :normal, state}
  end

  def link_downloaded({links_remaining, supervisors}) do
    {:no_reply, {links_remaining - 1 , supervisors}}
  end

  defp start_tasks(links, target_directory, task_supervisor) do
    Enum.map(links, fn link ->
      TaskSupervisor.append_new_task(link, target_directory, task_supervisor, self())
    end)
  end

  defp links(source_file) do
    content = File.read! source_file
    regexp = ~r/http(s?)\:.*?\.(png|jpg|gif)/
    Regex.scan(regexp, content)
      |> Enum.map(&List.first/1)
  end

  def terminate(:normal, {_, {task_supervisor, _worker_supervisor}}) do
    Supervisor.stop(task_supervisor)
    :normal
  end
end
