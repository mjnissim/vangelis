class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_path, :alert => exception.message
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  check_authorization :unless => :devise_controller?

  before_filter do
    # The following code is a patch because of CanCan not working
    # with Rails 4.0.
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)

    # Make the first user to sign up into an admin
    if User.count == 1
      User.first.update_attributes admin: true
    end
  end
end
