defmodule Recom.Notification do
  require Logger

  # SMELL this should not take a product but an event, eg ProductSaved(product: product)
  def send(product) do
    # Fake broadcasting:
    Logger.info("Saved product.", product: product)
  end
end
