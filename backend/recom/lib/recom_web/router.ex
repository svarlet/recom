defmodule RecomWeb.Router do
  use RecomWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RecomWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/shows/:id/purchasables", PurchasablesController, :list
  end

  # Other scopes may use custom stacks.
  # scope "/api", RecomWeb do
  #   pipe_through :api
  # end
end
