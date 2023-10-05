defmodule StockpricesChat.Types.StockpriceRequest do
  #@type format :: :simple | :table | :graph
  defstruct [:ticker, :from, :to, :format ]
end
