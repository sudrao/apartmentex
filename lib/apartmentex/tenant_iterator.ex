defmodule Apartmentex.TenantIterator do
  @callback iterate((:atom, binary() -> any())) :: any()
end
