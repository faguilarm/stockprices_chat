defmodule StockpricesChatWeb.ChatLive do
  use StockpricesChatWeb, :live_view
  alias StockpricesChat.Services.UtilsService
  require Logger

  def mount(_params, _session, socket) do
    {:ok, assign(socket, message: "", history: [])}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1 class="mb-2 text-4xl font-extrabold">Welcome to the StockPrices Chat!</h1>
    <div class="flex flex-col space-y-4">
      <div>
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
      </div>

      <div class="w-full rounded-lg p-2 border-2 border-blue-200 overflow-y-auto max-h-96">
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
    with {:ok, request} <- UtilsService.get_parsed(new_message) do
      IO.inspect(request)
      updated_history = socket.assigns.history ++ [new_message]
      {:noreply, assign(socket, my_message: "", history: updated_history)}
    else
      {:error, reason} ->
        updated_history = socket.assigns.history ++ [reason]
        {:noreply, assign(socket, my_message: "", history: updated_history)}
    end
  end
end
