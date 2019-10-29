defmodule ImageFinder.Worker2 do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:fetch, source_file, target_directory}, _from, state) do
    content = File.read! source_file
    regexp = ~r/http(s?)\:.*?\.(png|jpg|gif)/
    Regex.scan(regexp, content)
      |> Enum.map(&List.first/1)
      |> Enum.map(&(fetch_link &1, target_directory))
    {:reply, :ok, state}
  end

  def fetch_link(link, target_directory) do
    HTTPotion.get(link).body  |> save(target_directory)
  end

  def digest(body) do
    :crypto.hash(:md5 , body) |> Base.encode16()
  end

  def save(body, directory) do
    File.write! "#{directory}/#{digest(body)}", body
  end
end
