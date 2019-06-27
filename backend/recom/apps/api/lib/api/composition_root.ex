defmodule CompositionRoot do
  defmodule Shopper do
    defmodule ListPurchasablesUsecase do
      def list_purchasables(instant) do
        Usecases.Shopper.ListPurchasables.list_purchasables(instant, Storage.PurchasablesGateway.DbAdapter)
      end
    end

    defmodule ListPurchasablesController do
      def init(opts) do
        opts
      end

      def call(conn, _opts) do
        Api.Shopper.PurchasablesController.list(conn,
          at: Timex.now(),
          with_usecase: CompositionRoot.Shopper.ListPurchasablesUsecase)
      end
    end
  end
end
