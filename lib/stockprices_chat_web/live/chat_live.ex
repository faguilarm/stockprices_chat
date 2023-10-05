defmodule StockpricesChatWeb.ChatLive do
  use StockpricesChatWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, message: "")}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl font-extrabold">Welcome to the StockPrices Chat!</h1>
    """
  end
end
