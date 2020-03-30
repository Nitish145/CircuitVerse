class Api::V0::AuthenticationController < Api::V0::BaseController

  before_action :authorize_request, except: [:login, :signup]

  # POST /auth/login
  def login
    @user = User.find_by_email(params[:email])
    if @user&.valid_password?(params[:password])
      exp = (Date.today + 365)
      token = JsonWebToken.encode(user_id: @user.id, exp: exp)
      render json: {
        token: token,
        exp: exp.strftime("%m-%d-%Y %H:%M"),
        username: @user.name
      }, status: :accepted
    else
      if @user
        render json: {
          errors: [
            {
              message: "Incorrect Credentials",
              code: "incorrect_credentials"
            }
          ]
        }, status: :unauthorized
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

    # POST /auth/signup
  def signup
    if User.exists?(email: params[:email])
      render json: {
        errors: [
          {
            message: "User already exists",
            code: "Conflict"
          }
        ]
      }, status: :conflict
    else
      @user = User.create!(signup_params)
      exp = (Date.today + 365)
      token = JsonWebToken.encode(user_id: @user.id, exp: exp)
      render json: {
        token: token,
        exp: exp.strftime("%m-%d-%Y %H:%M"),
        username: @user.name
      }, status: :created
    end
  end

  private

    def login_params
      params.permit(:email, :password)
    end

    def signup_params
      params.permit(:name, :email, :password)
    end

end
