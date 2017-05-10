class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: :create
  
  # POST /signup
  # return authenticated token upon signup
  def create
    user = User.create!(user_params)
    command = AuthenticateUser.call(user.email, user.password)
    if command.success?
      response = { message: Message.account_created, auth_token: command.result }
      render json: response, status: :created
    else
      render json: { error: command.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
