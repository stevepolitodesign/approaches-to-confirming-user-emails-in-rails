class ConfirmationsController < ApplicationController
  def edit
    @confirmation = Confirmation.find_signed!(params[:signed_id], purpose: :confirmation)
    @confirmation.confirmable.update!(confirmed_at: Time.current)
    @confirmation.destroy!
  end
end
