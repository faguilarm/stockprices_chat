defmodule StockpricesChat.Repo do
  use Ecto.Repo,
    otp_app: :stockprices_chat,
    adapter: Ecto.Adapters.SQLite3
end
