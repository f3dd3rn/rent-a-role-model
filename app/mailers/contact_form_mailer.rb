class ContactFormMailer < ActionMailer::Base

  def contact_form_email(role_model, contact_form_data)
    @teacher_name = contact_form_data[:name]
    @school = contact_form_data[:school]
    @event = contact_form_data[:event]
    @teacher_email = contact_form_data[:email]
    @message = contact_form_data[:message]
    @appointment = contact_form_data[:datetime]
    from_email_with_name = mail_with_name(@teacher_name, @teacher_email)
    to_email_with_name = mail_with_name(role_model.name, role_model.email)
    mail(
      to: to_email_with_name,
      subject: "Rent a Role Model Anfrage",
      from: from_email_with_name,
      reply_to: @teacher_email
    )
  end

private
  def mail_with_name(name, email)
    return %("#{name}" <#{email}>)
  end

  def append_email_message_with_additional_data(message, data_hash = {})
  end
end