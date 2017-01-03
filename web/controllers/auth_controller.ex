defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth

  alias Discuss.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{
      token: auth.credentials.token,
      email: auth.info.email,
      provider: "github",
      inserted_at: Ecto.DateTime.from_erl(:erlang.localtime),
      updated_at: Ecto.DateTime.from_erl(:erlang.localtime)
    }
    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    # configure_session with `drop: true` removes any cookie reference
    # on the response, thus removing the flash messages as well. In this
    # case, we only remove the user_id on the session
    # |> configure_session(drop: true)
    |> put_session(:user_id, nil)
    |> put_flash(:info, "Signed out successfully")
    |> redirect(to: topic_path(conn, :index))

  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset) # returns {:ok, struct} or {:error, changeset}
      user ->
        {:ok, user}
    end
  end
end
