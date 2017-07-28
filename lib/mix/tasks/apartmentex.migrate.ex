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
      # Load client app
      {:ok, _} = Application.ensure_all_started(Mix.Project.config()[:app])
      # Get list of tenants
      quoted_list = iterator.list
      result = Code.eval_quoted(quoted_list, [], file: __ENV__.file, line: __ENV__.line)
      list = result |> elem(0)
      repo = iterator.repo
      list |> Enum.each(fn tenant -> migrate_one(repo, tenant) end)
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
