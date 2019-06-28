defmodule Storage.PurchasablesGatewayTest_AllExpiredTest do
  use Storage.DataCase
  use Timex

  alias Storage.PurchasablesGateway.DbAdapter
  alias Storage.Product

  setup do
    instant = Timex.now()

    [
      %Product{
        name: "expired 2 days ago",
        start: Timex.shift(instant, days: -5),
        end: Timex.shift(instant, days: -2)},
      %Product{
        name: "expired 3 years ago",
        start: Timex.shift(instant, years: -3, days: -2),
        end: Timex.shift(instant, years: -3)}
    ]
    |> Enum.each(&Storage.Repo.insert!/1)

    %{instant: instant}
  end

  describe "all/1" do
    test "returns an ok tuple with an empty list of product entities", context do
      assert {:ok, []} = DbAdapter.all(context.instant)
    end
  end
end
