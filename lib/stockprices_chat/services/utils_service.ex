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
end
