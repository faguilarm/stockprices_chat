defmodule StockpricesChat.Services.StockpriceService do
  alias StockpricesChat.Types.StockpriceRequest
  alias StockpricesChat.StockpriceRecord
  alias StockpricesChat.Repo
  alias StockpricesChat.Services.UtilsService
  require Logger
  use HTTPoison.Base
  import Ecto.Query

  @endpoint "https://stooq.com/q/l/?"

  def get_stockprice(%StockpriceRequest{} = request) do
    if request.from == nil do
      Logger.info("Query Stooq API to get price for #{request.ticker}")
      {:ok, response} = get_current_stockprice(request.ticker)
      # Basic CSV parsing as we are expecting a single line of data
      fields =
        response
        |> String.split("\r\n")
        |> Enum.at(1)
        |> String.split(",")
      date = Enum.at(fields, 1) # get the DATE
      price = Enum.at(fields, 6) # get the CLOSE price
      Logger.info("Got #{price} for #{request.ticker} on #{date}")
      # Basic validation of the API result, i.e. in case of a typo
      with {{:ok, _}, true} <- {Date.from_iso8601(date), price != "N/D"} do
         changeset = StockpriceRecord.changeset(%StockpriceRecord{}, %{ticker: request.ticker, date: date, price: UtilsService.parse_float(price)})
        {:ok, record} = Repo.insert(changeset, on_conflict: [set: [price: price]], conflict_target: [:ticker, :date])
        {:ok, [record]}
      else
        _ ->
          {:error, "Can't find results for the provided ticker, did you type it correctly?"}
      end
    else
      Logger.info("Look for data in database: #{request.ticker} from #{request.from} to #{request.to}")
      from_str = Date.to_string(request.from)
      to_str = Date.to_string(request.to)
      query = from s in StockpriceRecord,
        where: s.ticker == ^request.ticker and s.date >= ^from_str and s.date <= ^to_str
      records = Repo.all(query)
      with [] <- records do
        {:error, "Can't find results for the provided ticker and date, please try the current price instead (no dates)"}
      else
        _ ->
          {:ok, records}
      end
    end
  end

  def get_current_stockprice(ticker) do
    url = "#{@endpoint}s=#{ticker}.us&f=sd2t2ohlcv&h&e=csv"
    Logger.info("Requesting data from: #{url}")
    response = get(url)
    case response do
      {:ok, %{body: body}} ->
        {:ok, body}
      {:error, %{reason: reason}} ->
        Logger.error("Request failed with: #{reason}")
        {:error, reason}
    end
  end
end
