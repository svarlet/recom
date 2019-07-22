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

  defmodule Shopkeeper do
    defmodule CreateProductController do
      use Exceptional

      alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner
      alias Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator
      alias Recom.Storage.PurchasablesGateway.DbAdapter
      alias Recom.Notification
      alias Recom.Api.Shopkeeper.CreateProduct.ResponseBuilder

      @behaviour Plug

      def init(opts), do: opts

      def call(conn, _opts) do
        conn.params
        |> ProductScanner.scan()
        ~> ProductValidator.validate()
        ~> DbAdapter.save_product()
        ~> tee(&Notification.send/1)
        ~> ResponseBuilder.build(conn)
      end

      defp tee(value, f) do
        f.(value)
        value
      end
    end
  end
end
