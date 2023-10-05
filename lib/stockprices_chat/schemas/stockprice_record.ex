defmodule StockpricesChat.StockpriceRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stockprices" do
    field(:ticker, :string)
    field(:date, :string)
    field(:price, :float)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:ticker, :date, :price])
    |> validate_required([:ticker, :date, :price])
    |> unique_constraint(:stockprices_ticker_date_index)
  end
end
