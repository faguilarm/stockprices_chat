defmodule StockpricesChat.Repo.Migrations.AddUniqueIndexToStockprices do
  use Ecto.Migration

  def change do
    create unique_index(:stockprices, [:ticker, :date])
  end
end
