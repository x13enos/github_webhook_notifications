class ProjectCardRequestsHandler
  include HTTParty

  def initialize(payload)
    @payload = payload
  end

  def perform
    find_initiator
    select_action
    get_column_name
    get_recipients
    send_email
  end

  private

  def find_initiator
    user_url = @payload["sender"]["url"]
    user_response = HTTParty.get(user_url, request_params)
    @initiator_login = user_response["login"]
    @initiator_name = user_response["name"] || @initiator_login
  end

  def select_action
    @action = @payload["action"]
  end

  def get_column_name
    column_url = @payload["project_card"]["column_url"]
    column_response = HTTParty.get(column_url, request_params)
    @column_name = column_response["name"]
  end

  def get_recipients
    list_of_recipients = ENV["LIST_OF_RECIPIENTS"].split(',')
    @recipients = list_of_recipients.each_with_object({}) do |r, o|
      recipient = r.split(":")
      o[recipient[0]] = recipient[1]
    end
  end

  def send_email
    case @action
    when 'created'
      send_email_of_creating
    end
  end

  def send_email_of_creating
    note_text = @payload["project_card"]["note"]
    @recipients.except(@initiator_login).each do |login, mail|
      NotificationMailer.project_card_creation(mail, @initiator_name, @column_name, note_text).deliver!
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
end
