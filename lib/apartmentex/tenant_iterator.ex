defmodule Apartmentex.TenantIterator do
  @callback list(none()) :: list(binary())
  @callback repo(none()) :: atom()
end
