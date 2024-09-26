class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      admins_index_path
    else
      root_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[first_name last_name bank_name bank_code account_number phone_number])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[first_name last_name bank_name bank_code account_number phone_number])
  end
end
