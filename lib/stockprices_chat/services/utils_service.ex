defmodule StockpricesChat.Services.UtilsService do
  alias StockpricesChat.Types.StockpriceRequest
  require Logger

  def get_parsed(message) do
    [ticker | dates] = String.split(message, " ")
    Logger.info("Received: #{ticker} (#{String.length(ticker)}) and #{dates} (#{length(dates)})")
    case {String.length(ticker), length(dates)} do
      {t, d} when t <= 5 and d == 0 ->
        # No dates, just ticker
        {:ok, %StockpriceRequest{ticker: ticker}}
      {t, d} when t <= 5 and d in [1,2] ->
        # Extract first date
        {:ok, from} = Date.from_iso8601(hd(dates))
        # Look for second date, if not found, use 'from' again to define range
        {:ok, to} = if d == 2 do Date.from_iso8601(Enum.at(dates,1)) else {:ok, from} end
        {:ok, %StockpriceRequest{ticker: ticker, from: from, to: to}}
      _ ->
        {:error, "Invalid message format, please try again"}
    end
  end

  def get_unzipped_entries(source, target) do
    Logger.info("Unzipping #{source} to #{target}")
    source_path = Path.expand(source)
    target_path = Path.expand(target)
    :zip.extract(~c"#{source_path}", cwd: ~c"#{target_path}")
  end

  def get_csv_files(source) do
    Logger.info("Reading CSV files from #{source}")
    source_path = Path.expand(source)
    files = File.ls!(~c"#{source_path}")
    csv_files = Enum.map(files, fn file -> Path.expand("#{source}/#{file}") end)
    {:ok, csv_files}
  end

  def parse_csv_map(map) do
    date_string = map["<DATE>"]
    %{
      ticker: map["<TICKER>"],
      date: "#{String.slice(date_string, 0..3)}-#{String.slice(date_string, 4..5)}-#{String.slice(date_string, 6..7)}",
      price: parse_float(map["<CLOSE>"])
    }
  end

  def parse_float(string) do
    {float, _} = Float.parse(string)
    float
  end
end
# Path.expand("./stocktest2") |> File.ls!()
# listaA = "./aaciu.us.txt" |> File.stream! |> CSV.decode(headers: true) |> Enum.to_list |> Enum.filter(fn {:ok, row} -> true; _ -> false end) |> Enum.map(fn {:ok, row} -> Map.take(row, ["<TICKER>", "<DATE>", "<CLOSE>"]) end)
    #Enum.each(csv_files, fn csv_file ->
    #  csv_fullpath = Path.expand("#{source}/#{csv_file}")
    #  IO.puts("#{csv_file}, #{csv_fullpath}")
    #end)
