defmodule Avoidit.Sources.Source do
  use Ash.Resource, otp_app: :avoidit, domain: Avoidit.Sources, data_layer: AshPostgres.DataLayer

  postgres do
    table "sources"
    repo Avoidit.Repo

    references do
      reference :email, index?: true, on_delete: :delete
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:source, :sub_source, :email_id, :order]
    end

    update :update do
      primary? true
      accept [:source, :sub_source, :order]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :source, :string do
      allow_nil? false
    end

    attribute :sub_source, :string

    attribute :order, :integer do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :email, Avoidit.Outbound.Email
  end

  calculations do
    calculate :number, :integer, expr(order + 1) do
      public? true
    end
  end
end
