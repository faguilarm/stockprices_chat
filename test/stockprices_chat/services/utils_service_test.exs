defmodule UtilsServiceTest do
  use ExUnit.Case
  alias StockpricesChat.Services.UtilsService

  test "should parse a user message requesting the current price for AAPL" do
    assert UtilsService.get_parsed("AAPL") == {:ok, %StockpricesChat.Types.StockpriceRequest{ticker: "AAPL"}}
  end

  test "should parse a user message requesting AAPL price on 2023-09-01" do
    assert UtilsService.get_parsed("AAPL 2023-09-01") == {:ok, %StockpricesChat.Types.StockpriceRequest{ticker: "AAPL", from: ~D[2023-09-01], to: ~D[2023-09-01]}}
  end

  test "should parse a user message requesting AAPL price on 2023-09-01 to 2023-09-15" do
    assert UtilsService.get_parsed("AAPL 2023-09-01 2023-09-15") == {:ok, %StockpricesChat.Types.StockpriceRequest{ticker: "AAPL", from: ~D[2023-09-01], to: ~D[2023-09-15]}}
  end

  test "should parse map from csv to the structure required for changeset" do
    assert UtilsService.parse_csv_map(%{"<TICKER>" => "AAPL.US", "<DATE>" => "20201005", "<CLOSE>" => "116.5"}) == %{date: "2020-10-05", price: 116.5, ticker: "AAPL"}
  end

  test "should parse_float from float string" do
    assert UtilsService.parse_float("1.23") == 1.23
  end

  test "should parse_float from int string" do
    assert UtilsService.parse_float("1") == 1
  end
end
