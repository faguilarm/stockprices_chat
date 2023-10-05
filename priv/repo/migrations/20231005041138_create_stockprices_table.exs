defmodule StockpricesChat.Repo.Migrations.CreateStockpricesTable do
  use Ecto.Migration

  def change do
    create table(:stockprices) do
      add :ticker, :string, null: false
      add :date, :string, null: false
      add :price, :float, default: 0
    end
  end
end
