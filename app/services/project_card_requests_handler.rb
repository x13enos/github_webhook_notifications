class ProjectCardRequestsHandler
  include HTTParty

  def initialize(payload)
    @payload = payload
  end

  def perform
    find_initiator
    get_column_name
    get_recipients
    get_project_url
    send_email
  end

  private

  def find_initiator
    user_response = HTTParty.get(user_url, request_params)
    @initiator_login = user_response["login"]
    @initiator_name = user_response["name"] || @initiator_login
  end

  def get_column_name
    @column_response = HTTParty.get(column_url, request_params)
    @column_name = @column_response["name"]
  end

  def get_recipients
    list_of_recipients = ENV["LIST_OF_RECIPIENTS"].split(',')
    @recipients = list_of_recipients.each_with_object({}) do |r, o|
      recipient = r.split(":")
      o[recipient[0]] = recipient[1]
    end
  end

  def get_project_url
    project_response = HTTParty.get(@column_response["project_url"], request_params)
    @project_url = project_response["html_url"]
  end

  def send_email
    case action
    when 'created'
      send_email_of_creating
    when 'moved'
      send_email_of_moving
    when 'edited'
      send_email_of_editing
    when 'deleted'
      send_email_of_deleting
    end
  end

  def send_email_of_creating
    @recipients.except(@initiator_login).each do |login, mail|
      NotificationMailer.project_card_creation(mail, @initiator_name, @project_url, @column_name, note_text).deliver!
    end
  end

  def send_email_of_moving
    @recipients.except(@initiator_login).each do |login, mail|
      NotificationMailer.project_card_moving(mail, @initiator_name, @project_url, @column_name, note_text).deliver!
    end
  end

  def send_email_of_editing
    @recipients.except(@initiator_login).each do |login, mail|
      NotificationMailer.project_card_editing(mail, @initiator_name, @project_url, @column_name, note_text, old_note_text).deliver!
    end
  end

  def send_email_of_deleting
    @recipients.except(@initiator_login).each do |login, mail|
      NotificationMailer.project_card_deleting(mail, @initiator_name, @project_url, @column_name, note_text).deliver!
    end
  end

  def request_params
    {
      headers: {
        "Accept" => "application/vnd.github.inertia-preview+json",
        "User-Agent" => ENV["GITHUB_USER"]
      },
      basic_auth: { username: ENV["GITHUB_USER"], password: ENV["GITHUB_TOKEN"] }
    }
  end

  def note_text
    @payload["project_card"]["note"]
  end

  def column_url
    @payload["project_card"]["column_url"]
  end

  def action
    @payload["action"]
  end

  def user_url
    @payload["sender"]["url"]
  end

  def old_note_text
    @payload["changes"]["note"]["from"]
  end
end
