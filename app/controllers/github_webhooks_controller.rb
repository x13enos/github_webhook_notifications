class GithubWebhooksController < ActionController::Base
  include GithubWebhook::Processor

  def github_project_card(payload)
    ProjectCardRequestsHandler.new(payload).perform
  end

  def webhook_secret(payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end
