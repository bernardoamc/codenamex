defmodule CodenamexWeb.Router do
  use CodenamexWeb, :router

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

  scope "/", CodenamexWeb do
    pipe_through :browser

    get "/", RoomController, :index
    resources "/rooms", RoomController, only: [:create, :show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", CodenamexWeb do
  #   pipe_through :api
  # end
end
