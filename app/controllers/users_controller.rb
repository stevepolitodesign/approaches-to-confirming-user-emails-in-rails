class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: "Confirm your account: "
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
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
