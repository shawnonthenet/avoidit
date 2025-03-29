defmodule Avoidit.Outbound.Email do
  use Ash.Resource, otp_app: :avoidit, domain: Avoidit.Outbound, data_layer: AshPostgres.DataLayer

  postgres do
    table "emails"
    repo Avoidit.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:title, :send_time, :email_address]
      argument :sources, {:array, :map}
      change manage_relationship(:sources, type: :direct_control, order_is_key: :order)

      change after_action(fn _changeset, record, _context ->
               Avoidit.Outbound.EmailSender.schedule_next_email(record.id)
               {:ok, record}
             end)
    end

    update :update do
      primary? true
      accept [:title, :send_time, :email_address]
      require_atomic? false
      argument :sources, {:array, :map}
      change manage_relationship(:sources, type: :direct_control, order_is_key: :order)

      change after_action(fn _changeset, record, _context ->
               Avoidit.Outbound.EmailSender.schedule_next_email(record.id)
               {:ok, record}
             end)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :send_time, :time do
      allow_nil? false
    end

    attribute :email_address, :string do
      allow_nil? false
    end

    relationships do
      has_many :sources, Avoidit.Sources.Source do
        sort order: :asc
      end
    end

    timestamps()
  end
end
