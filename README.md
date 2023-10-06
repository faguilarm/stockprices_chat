# Stockprices Chat
![image](https://github.com/faguilarm/stockprices_chat/assets/17299644/88793a6d-2ae0-4b99-9cab-78604000b2a1)

# About the project
This is a simple application that offers a chat-like UI to request information regarding stock prices, can gather the response from an external source or from its database.
## Current features
* If only the ticker is entered, the application will get the response from the [Stooq API](https://stooq.com/) and will save it in the database (Sqlite3).
* If a single date of date range is provided, it will look for the result from the database, as this is taken as a query for historical prices.
* For results of two or more rows, simple characters (▲, ▼) are added to represent the variation of the price from the previous day.
## Todo / Next steps
* Add a new option to request stockprices using this notation `2d`, `3w` and `2m` (days, weeks, months) to represent a period of time from today to some point in the past.
* Add a new option to allow displaying results in tables and line graphs, in addition to the basic format currently supported.
* Improve the UI, offer an interface more similar to a standard chat.
* Fix the seed process to use `Repo.insert_all` or a better way for bulk inserts, instead of `Repo.insert`.
* Add testing coverage.
* Add module and function documentation.
* Improve the build and deployment process.
# Installation
## Setup
After getting a working copy of the project, you just need to execute the following:
> Note that this project was created using **Elixir 1.15.6 (compiled with Erlang/OTP 26)**

* Run `mix setup` to install and setup dependencies

* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

* Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Seed
A `seed.exs` script was provided to make an initial load of data, using the files available at [Stooq.com](https://stooq.com/db/h/). As the zip file includes more than 4,000 stock symbols (just for Nasdaq), and each one of them can have hundreds or thousands of records, a more optimal approach was to include only 10 of the more relevant tech companies:
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
