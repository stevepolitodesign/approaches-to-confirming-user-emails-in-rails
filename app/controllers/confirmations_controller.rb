class ConfirmationsController < ApplicationController
  def edit
    @user = User.unconfirmed.find_signed!(params[:signed_id])
    @user.update!(confirmed_at: Time.current)
  end
end
