class NotificationMailer < ApplicationMailer
  def project_card_creation(recipient_mail, initiator_name, column_name, text)
    @initiator_name = initiator_name
    @text = text
    @column_name = column_name
    mail to: recipient_mail, :subject => "Project card was created"
  end

  def project_card_moving(recipient_mail, initiator_name, column_name, text)
    @initiator_name = initiator_name
    @text = text
    @column_name = column_name
    mail to: recipient_mail, :subject => "Project card was moved"
  end

  def project_card_editing(recipient_mail, initiator_name, column_name, text, old_text)
    @initiator_name = initiator_name
    @text = text
    @old_text = old_text
    @column_name = column_name
    mail to: recipient_mail, :subject => "Project card was changed"
  end

  def project_card_deleting(recipient_mail, initiator_name, column_name, text)
    @initiator_name = initiator_name
    @text = text
    @column_name = column_name
    mail to: recipient_mail, :subject => "Project card was deleted"
  end
end
