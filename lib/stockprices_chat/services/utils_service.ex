defmodule StockpricesChat.Services.UtilsService do
  @moduledoc """
  Provides functions for parsing different structures,
  as well as functions to be used during the data import (seeds.exs)
  """
  alias StockpricesChat.Types.StockpriceRequest
  require Logger

  @doc """
  Parse a message from the user into a structure that can be used by the application
  ## Parameters
    * `message` - the message sent by the user
  ## Returns
    * `{:ok, %StockpriceRequest{}}` - if the message was parsed correctly
    * `{:error, message}` - if the message was not parsed correctly
  ## Examples
      iex> UtilsService.get_parsed("AAPL")
      {:ok, %StockpriceRequest{ticker: "AAPL"}}
      iex> UtilsService.get_parsed("AAPL 2023-09-01")
      {:ok, %StockpriceRequest{ticker: "AAPL", from: ~D[2023-09-01], to: ~D[2023-09-01]}}
      iex> UtilsService.get_parsed("AAPL 2023-09-01 2023-09-15")
      {:ok, %StockpriceRequest{ticker: "AAPL", from: ~D[2023-09-01], to: ~D[2023-09-15]}}
      iex> UtilsService.get_parsed("something else")
      {:error, "Invalid message format, please try again"}
  """
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

  @doc """
  Extracts a zip file into a target directory
  ## Parameters
    * `source` - the zip file to be extracted
    * `target` - the target directory where the zip file will be extracted
  ## Returns
    * `{:ok, entries}` - if the zip file was extracted correctly
    * `{:error, reason}` - if the zip file was not extracted correctly
  """
  def get_unzipped_entries(source, target) do
    Logger.info("Unzipping #{source} to #{target}")
    source_path = Path.expand(source)
    target_path = Path.expand(target)
    :zip.extract(~c"#{source_path}", cwd: ~c"#{target_path}")
  end

  @doc """
  Get a list of files from a directory with full path
  """
  def get_csv_files(source) do
    Logger.info("Reading CSV files from #{source}")
    source_path = Path.expand(source)
    files = File.ls!(~c"#{source_path}")
    csv_files = Enum.map(files, fn file -> Path.expand("#{source}/#{file}") end)
    {:ok, csv_files}
  end

  @doc """
  Parse a map from CSV file to the structure required for changeset
  """
  def parse_csv_map(map) do
    date_string = map["<DATE>"]
    %{
      ticker: String.replace(map["<TICKER>"], ".US", ""),
      date: "#{String.slice(date_string, 0..3)}-#{String.slice(date_string, 4..5)}-#{String.slice(date_string, 6..7)}",
      price: parse_float(map["<CLOSE>"])
    }
  end

  @doc """
  Utility function to parse a float from a string
  """
  def parse_float(string) do
    {float, _} = Float.parse(string)
    float
  end
end
