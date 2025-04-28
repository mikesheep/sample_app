class UserMailer < ApplicationMailer

  def account_activation(user) #アカウント有効化
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def password_reset #パスワードリセット
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
