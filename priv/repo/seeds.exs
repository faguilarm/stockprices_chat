# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     StockpricesChat.Repo.insert!(%StockpricesChat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias StockpricesChat.Services.UtilsService
alias StockpricesChat.StockpriceRecord
alias StockpricesChat.Repo
require Logger

Logger.configure(level: :info)

zip_file = "priv/data/nasdaq_stocks_10.zip"
work_dir = "tmp"

# Extract the zip file on the desired location (work_dir)
# We can comment this line if the zip file was already extracted
{:ok, _entries} = UtilsService.get_unzipped_entries(zip_file, work_dir)

# List all the CSV files in the work_dir
{:ok, csv_files} = UtilsService.get_csv_files(work_dir)

Logger.info("#{Enum.count(csv_files)} CSV files will be processed")

_total_csv_entries = 0
_total_records = 0

Enum.each(csv_files, fn csv_file ->
  Logger.debug("Processing #{csv_file}")

  # Load CSV file into a list of maps
  entries =
    csv_file
    |> File.stream!
    |> CSV.decode(headers: true)
    |> Enum.to_list
    |> Enum.filter(fn {:ok, _row} -> true; _ -> false end) #Take only the rows that were parsed correctly
    |> Enum.map(fn {:ok, row} ->
      Map.take(row, ["<TICKER>", "<DATE>", "<CLOSE>"]) end) #Take only the fields we need

  Logger.debug("Processing list of entries: #{inspect(entries)}")
  #total_csv_entries = total_csv_entries + Enum.count(entries)

  # Iterate line by line on the list, parse the map and insert into the database
  Enum.each(entries, fn entry ->
    Logger.debug("Processing entry: #{inspect(entry)}")
    parsed = UtilsService.parse_csv_map(entry)
    Logger.debug("Parsed entry: #{inspect(parsed)}")
    changeset = StockpriceRecord.changeset(%StockpriceRecord{}, parsed)
    Logger.debug("Changeset: #{inspect(changeset)}")
    {:ok, record} = Repo.insert(changeset, on_conflict: [set: [price: parsed.price]],
      conflict_target: [:ticker, :date])
    Logger.debug("Inserted record: #{inspect(record)}")
    #total_records = total_records + 1
  end)
end)

#TODO This won't work, Enum.each has to be replaced by a Enum.reduce to use accumulator
#Logger.info("#{total_csv_entries} CSV entries were loaded and parsed")
#Logger.info("#{total_records} records were inserted into the database")
Logger.info("Done!")
