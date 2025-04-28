class UserMailer < ApplicationMailer

  def account_activation(user) #アカウント有効化
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
  @user = user
  mail to: user.email, subject: "Password reset"
  end
end

