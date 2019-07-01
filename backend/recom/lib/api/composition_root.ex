defmodule Recom.CompositionRoot do
  alias Recom.{CompositionRoot, Api, Usecases, Storage}

  defmodule Shopper do
    defmodule ListPurchasablesUsecase do
      @behaviour Usecases.Shopper.ListPurchasables.Behaviour

      @impl true
      def list_purchasables(instant) do
        Usecases.Shopper.ListPurchasables.list_purchasables(
          instant,
          Storage.PurchasablesGateway.DbAdapter
        )
      end
    end

    defmodule ListPurchasablesController do
      def init(opts), do: opts

      def call(conn, _opts) do
        Api.Shopper.PurchasablesController.list(conn,
          at: Timex.now(),
          with_usecase: CompositionRoot.Shopper.ListPurchasablesUsecase
        )
      end
    end
  end
end
