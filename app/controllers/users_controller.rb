class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.save
      confirmation = @user.confirmations.create!
      signed_id = confirmation.signed_id expires_in: 15.minutes, purpose: :confirmation
      redirect_to user_path(@user, params: { signed_id: signed_id }),  notice: "Confirm your account"
    else
      flash.now.alert =  @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @signed_id = params[:signed_id]
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
