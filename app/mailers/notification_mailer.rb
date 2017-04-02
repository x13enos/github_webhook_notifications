class NotificationMailer < ApplicationMailer
  def project_card_creation(recipient_mail, initiator_name, column_name, text)
    @initiator_name = initiator_name
    @text = text
    @column_name = column_name
    mail to: recipient_mail, :subject => "Project card was created"
  end
end
