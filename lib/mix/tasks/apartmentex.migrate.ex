defmodule Mix.Tasks.Apartmentex.Migrate do
  use Mix.Task

  @shortdoc "Run migrations on all tenants"
  def run(_) do
    iterator = Application.get_env(:apartmentex, :schema_iterator)
    unless iterator do
      Mix.shell.error "No schema iterator configured. No migrations were run."
    else
      # Add client app's load path
      Mix.Project.load_paths |> Enum.at(0) |> Code.prepend_path
      # Load module and iterate over tenants
      with {:module, _} <- Code.ensure_loaded(iterator) do
        iterator.iterate(&migrate_one/2)
      else
        {:error, reason} -> Mix.shell.error(inspect(reason))
      end
    end
  end

  def migrate_one(repo, tenant) do
    with {:ok, _, _} <- Apartmentex.migrate_tenant(repo, tenant) do
      Mix.shell.info "#{tenant} migrated"
    else
      {:error, _, reason} -> Mix.shell.error "#{tenant} migration failed: #{reason}"
    end
  end
end
