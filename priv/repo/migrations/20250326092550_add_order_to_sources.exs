defmodule Avoidit.Repo.Migrations.AddOrderToSources do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:sources) do
      add :order, :bigint, null: false
    end
  end

  def down do
    alter table(:sources) do
      remove :order
    end
  end
end
