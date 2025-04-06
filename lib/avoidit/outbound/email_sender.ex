defmodule Avoidit.Outbound.EmailSender do
  use Oban.Worker, queue: :email_sender
  import Ecto.Query

  def perform(%Oban.Job{args: %{"email_id" => email_id, "one_off" => true}}) do
    send_email(email_id)
  end

  def perform(%Oban.Job{args: %{"email_id" => email_id}}) do
    schedule_next_email(email_id)
    send_email(email_id)
  end

  def send_email(email_id) do
    email = Avoidit.Outbound.get_email_by_id!(email_id, load: [:sources])
    Avoidit.Outbound.DailyEmail.daily_email(email)
  end

  def schedule_next_email(email_id) do
    email = Avoidit.Outbound.get_email_by_id!(email_id)
    time = email.send_time

    schedule_at =
      DateTime.new!(Date.utc_today(), time)
      |> DateTime.shift_zone!(Application.get_env(:avoidit, :time_zone))
      |> DateTime.add(1, :day)

    # clear out all existing jobs for this email
    # to ensure we don't have duplicates
    Oban.Job
    |> where([j], j.queue == "email_sender")
    |> where([j], j.state != "executing")
    |> where([j], j.args == ^%{"email_id" => email_id})
    |> Oban.cancel_all_jobs()

    %{"email_id" => email_id}
    |> Avoidit.Outbound.EmailSender.new(scheduled_at: schedule_at)
    |> Oban.insert()
  end
end
