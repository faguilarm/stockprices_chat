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

zip_file = "priv/data/nasdaq_stocks_test.zip"
work_dir = "tmp"

#{:ok, _entries} = UtilsService.get_unzipped_entries(zip_file, work_dir)

{:ok, csv_files} = UtilsService.get_csv_files(work_dir)

IO.inspect(csv_files)

Enum.each(csv_files, fn csv_file ->
  IO.puts("Processing #{csv_file}")
  entries =
    csv_file
    |> File.stream!
    |> CSV.decode(headers: true)
    |> Enum.to_list
    |> Enum.filter(fn {:ok, _row} -> true; _ -> false end)
    |> Enum.map(fn {:ok, row}
    -> Map.take(row, ["<TICKER>", "<DATE>", "<CLOSE>"]) end)
  IO.inspect(entries)
  changesets = for map <- entries do
    #IO.inspect(map)
    IO.inspect(UtilsService.parse_csv_map(map))
    StockpriceRecord.changeset(%StockpriceRecord{}, UtilsService.parse_csv_map(map))
  end
  IO.inspect(changesets)
  StockpricesChat.Repo.insert_all(StockpriceRecord, changesets)
  #changeset = MySchema.changeset(%MySchema{}, map)
  #MyRepo.insert!(changeset)
end)
