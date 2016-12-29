defmodule Discuss.Router do
  use Discuss.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Discuss.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Discuss do
    pipe_through :browser # Use the default browser stack

    resources "/", TopicController

  end

  scope "/auth", Discuss do
    pipe_through :browser

    delete "/signout", AuthController, :signout
    # request function is already defined by ueberauth
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

end
