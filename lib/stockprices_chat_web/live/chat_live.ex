defmodule StockpricesChatWeb.ChatLive do
  use StockpricesChatWeb, :live_view
  alias StockpricesChat.Services.UtilsService
  alias StockpricesChat.Services.StockpriceService
  require Logger

  def mount(_params, _session, socket) do
    {:ok, assign(socket, message: "", history: [])}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1 class="mb-2 text-2xl lg:text-4xl font-extrabold text-center">Welcome to the StockPrices Chat!</h1>
    <div class="flex flex-col space-y-4">
      <div>
        <h2 class="font-bold text-center mb-2">
          Please ask the information you need by following the next format:
        </h2>

        <ol class="list-decimal list-inside font-sans text-sm">
          <li><span class="chip-required">REQUIRED</span> The stock symbol or ticker, like: AAPL, MSFT, GOOG</li>
          <li><span class="chip-optional">OPTIONAL</span> A single date or date range, as follows:
            <ul class="list-disc list-inside ml-4">
              <li>A date in YYYY-MM-DD format, i.e. 2023-09-30</li>
              <li>A date range as YYYY-MM-DD YYYY-MM-DD, i.e. 2023-09-30 2023-10-02</li>
              <li>If no date is provided, the current price will be returned</li>
            </ul>
          </li>
          <li>Examples:
            <div class="font-mono ml-4 p-4 bg-gray-900 text-green-500 rounded-lg">
              AAPL
              <br>
              AAPL 2023-09-01
              <br>
              AAPL 2023-09-01 2023-09-15
            </div>
          </li>
        </ol>
      </div>

      <div class="w-full rounded-lg p-2 border-2 border-blue-200 overflow-y-auto max-h-96 font-mono">
        <%= for h <- @history do %>
          <p><%= h %></p>

        <% end %>
        <%= @message %>
      </div>

      <div class="mt-2 flex rounded-md shadow-sm">
          <form phx-submit="handle_submit" class="relative flex flex-grow items-stretch focus-within:z-10">
            <input type="text" name="my_input" value={@message} class="block w-full rounded-none rounded-l-md border-0 py-1.5 pl-2 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-200 sm:text-sm sm:leading-6" placeholder="Type your request here">
            <button type="submit" class="relative ml-2 inline-flex items-center gap-x-1.5 rounded-r-md px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-blue-200">
              Send
            </button>
          </form>
      </div>
    </div>
    """
  end

  def handle_event("handle_submit", %{"my_input" => new_message}, socket) do
    Logger.info("New input is: #{new_message}")
    with {:ok, request} <- UtilsService.get_parsed(new_message),
      {:ok, response} <- StockpriceService.get_stockprice(request) do
      response = get_prices_with_change(response)
      list_str = Enum.map(response, fn row -> "#{row.ticker} #{row.date} #{row.price} #{row.change}" end)
      updated_history = create_updated_history(socket.assigns.history, list_str)
      {:noreply, assign(socket, message: "", history: updated_history)}
    else
      {:error, reason} ->
        updated_history = create_updated_history(socket.assigns.history, [reason])
        {:noreply, assign(socket, message: "", history: updated_history)}
    end
  end

  def get_prices_with_change(stockprices) do
    {_, new_list} = Enum.reduce(stockprices, {nil, []}, fn price, {prev_price, acc} ->
      case prev_price do
        nil ->
          {price, acc ++ [price |> Map.put(:change, "")]}
        _ ->
          diff = price.price - prev_price.price
          change = case diff do
            diff when diff > 0 -> "▲"
            diff when diff < 0 -> "▼"
            _ -> ""
          end
          {price, acc ++ [price |> Map.put(:change, change)]}
      end
    end)
    new_list
  end

  def create_updated_history(history, new_lines) do
    history ++ new_lines ++ ["========================"]
  end
end
