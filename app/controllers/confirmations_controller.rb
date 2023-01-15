class ConfirmationsController < ApplicationController
  def edit
    @confirmation = Confirmation.find_signed!(params[:signed_id], purpose: :confirmation)
    @confirmation.confirmable.update!(confirmed_at: Time.current)
    @confirmation.confirmable.confirmations.destroy_all!
  end
end
