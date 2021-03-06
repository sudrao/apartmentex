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
      # Load client app if requested
      if iterator[:app_start_needed] do
        {:ok, _} = Application.ensure_all_started(Mix.Project.config()[:app])
      end
      # Get list of tenants
      list =
      case iterator[:list] do
        list when is_list(list) -> list
        quoted_content when is_tuple(quoted_content) ->
          Code.eval_quoted(quoted_content, [], file: __ENV__.file, line: __ENV__.line)
          |> elem(0)
        other -> raise "schema_iterator[:list] should be a list or quoted content. Instead got: " <> inspect(other)
      end
      # Get repo and migrate each tenant in list
      repo = iterator[:repo]
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
