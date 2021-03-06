class DeliveryGul < ApplicationMailer
  def send_welcome_mail(user_id:)
    @user = User.find(user_id)
    mail(
      from: Admin::Setting.admin_email_address,
      to: @user.email,
      subject: "Welcome to #{Admin::Setting.app_title}"
    )
  end

  def send_password_reset_link(user)
    @user = user
    @password_reset_link = reset_password_url id: @user.id, token: @user.password_reset_token
    mail(from: Admin::Setting.admin_email_address, to: user.email, subject: "Password reset for #{Admin::Setting.app_title}")
  end

  def invite_collaborator(id:, email_address:)
    @map = Map.find_by(id: id)
    mail(from: Admin::Setting.admin_email_address,
         reply_to: @map.maintainer_email_address,
         to: email_address,
         subject: "You've been invited to collaborate on '#{@map.title}'-map!")
  end

  def invite_guest(id:, email_address:)
    @map = Map.find_by(id: id)
    mail(from: Admin::Setting.admin_email_address,
         reply_to: @map.maintainer_email_address,
         to: email_address,
         subject: "You've been invited to have a look at '#{@map.title}'-map!")
  end
end
