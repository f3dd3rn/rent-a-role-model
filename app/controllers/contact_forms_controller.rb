#encoding: utf-8
class ContactFormsController < ApplicationController
  def new
    @user = User.find(params[:user_id])
  end

  def create
    begin
      @user = User.find(params[:user_id])
      if (request.post? && valid_input(params))
        ContactFormMailer.contact_form_email(@user, params).deliver_now
        render :create
      else
        flash.now[:error] = 'Fehler beim Versenden. Bitte prüfen Sie Ihre Angaben.'
        render :new
      end
    rescue ScriptError
       flash[:error] = 'Sorry, this message appears to be spam and was not delivered.'
    end
  end

  private
  def valid_input params
    valid = false
    if request.post?
      valid = (params[:name].present? &&
      params[:message].present? &&
      params[:school].present? &&
      params[:event].present? &&
      valid_email(params))
      return valid
    end
  end

  def valid_email(params)
    return (params[:email].present? && (params[:email] =~ /\A[\w\.%\+\-]+@[\w\-]+\.+[\w]{2,}\z/i))
  end
end
