defmodule UltimateTtt do
  @external_resource "README.md"
  @moduledoc @external_resource
             |> File.read!()
             |> String.split("<!-- module-doc -->")
             |> Enum.fetch!(1)
end
