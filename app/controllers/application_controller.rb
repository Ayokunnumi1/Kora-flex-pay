class ApplicationController < ActionController::Base
  def current_user
    @current_user = User.first
  end

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[first_name last_name bank_name bank_code account_number phone_number])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[first_name last_name bank_name bank_code account_number phone_number])
  end
end
