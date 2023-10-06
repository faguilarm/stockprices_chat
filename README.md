# StockpricesChat
# About the project

# Installation
## Setup
After getting a working copy of the project, you just need to execute the following:
> Note that this project was created using **Elixir 1.15.6 (compiled with Erlang/OTP 26)**

* Run `mix setup` to install and setup dependencies

* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

* Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Seed
A `seed.exs` script was provided to make an initial load of data, using the files available at [Stooq.com](https://stooq.com/db/h/). As the zip file includes more than 4,000 stock symbols (just for Nasdaq), and each one of them can have hundred or thousands of records, a more optimal approach was to include only 10 of the more relevant tech companies:
* AAPL (Apple)
* AMZN (Amazon)
* GOOG & GOOGL (Google/Alphabet)
* INTC (Intel)
* META (Meta)
* MSFT (Microsoft)
* NFLX (Netflix)
* NVDA (Nvidia)
* PYPL (PayPal)
* TSLA (Tesla)

The number of records included for each company can vary a lot but they all finish on 2023-09-26, the day the snapshot was created. 
>If the seed data wasn't already loaded into the database, you can execute the process running `mix run priv/repo/seeds.exs`
