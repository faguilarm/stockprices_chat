defmodule StockpricesChatWeb.ChatLive do
  use StockpricesChatWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, message: "")}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1 class="mb-2 text-4xl font-extrabold">Welcome to the StockPrices Chat!</h1>
    <h2 class="font-bold text-b">
      Please ask the information you need by following the next format:
    </h2>
    <ol class="list-decimal list-inside font-sans">
      <li>(REQUIRED) The stock symbol or ticker, like: AAPL, MSFT, GOOG</li>
      <li>(OPTIONAL) A single date or date range, as follows:
        <ul class="list-disc list-inside ml-4">
          <li>A date in YYYY-MM-DD format, i.e. 2023-09-30</li>
          <li>A date range as YYYY-MM-DD YYYY-MM-DD, i.e. 2023-09-30 2023-10-02</li>
          <li>If no date is provided, the current price will be returned</li>
        </ul>
      </li>
      <li>Examples:
        <pre class="font-mono ml-4 p-2 py-4 bg-gray-900 text-green-500 rounded-lg">
          AAPL
          AAPL 2023-09-30
          AAPL 2023-09-30 2023-10-02
        </pre>
      </li>
    </ol>
    """
  end
end
