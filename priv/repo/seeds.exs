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

zip_file = Application.get_env(:stockprices_chat, :zip_file)
work_dir = Application.get_env(:stockprices_chat, :work_dir)

# Extract the zip file on the desired location (work_dir)
# We can comment this line if the zip file was already extracted
{:ok, _entries} = UtilsService.get_unzipped_entries(zip_file, work_dir)

# List all the CSV files in the work_dir
{:ok, csv_files} = UtilsService.get_csv_files(work_dir)

Logger.info("#{Enum.count(csv_files)} CSV files will be processed")

{csv_entries, inserted_records} = Enum.reduce(csv_files, {0, 0}, fn csv_file, {acc_csv, acc_rec} ->
  Logger.debug("Processing #{csv_file}")

  # Load CSV file into a list of maps
  entries = UtilsService.get_entries_from_csv(csv_file)
  Logger.debug("Processing list of entries: #{inspect(entries)}")

  # Iterate line by line on the list, parse the map and insert into the database
  inserted = Enum.reduce(entries, 0, fn entry, acc ->
    Logger.debug("Processing entry: #{inspect(entry)}")
    parsed = UtilsService.parse_csv_map(entry)
    Logger.debug("Parsed entry: #{inspect(parsed)}")
    changeset = StockpriceRecord.changeset(%StockpriceRecord{}, parsed)
    Logger.debug("Changeset: #{inspect(changeset)}")
    {:ok, record} = Repo.insert(changeset, on_conflict: [set: [price: parsed.price]],
      conflict_target: [:ticker, :date])
    Logger.debug("Inserted record: #{inspect(record)}")
    acc + 1
  end)

  {acc_csv + Enum.count(entries), acc_rec + inserted}
end)

Logger.info("#{csv_entries} CSV entries were loaded and parsed")
Logger.info("#{inserted_records} records were inserted into the database")
Logger.info("Done!")
