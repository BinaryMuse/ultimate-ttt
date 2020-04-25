defmodule UltimateTtt.Repo do
  use Ecto.Repo,
    otp_app: :ultimate_ttt,
    adapter: Ecto.Adapters.Postgres
end
