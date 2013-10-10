class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  ensure_security_headers

  before_filter :current_user
  before_filter :setup_fb_graph, :setup_fb_config

  helper_method :logged_in?
  helper_method :current_user
  helper_method :current_service

  rescue_from ActionController::RoutingError, with: :go_home

protected

  def current_user
    @current_user ||= User.find(session[:user_id]) if session.has_key?(:user_id)
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
  end

  def current_service
    if session.has_key?(:service_id)
      @current_service ||= Service.where(user_id: session[:user_id], id: session[:service_id]).first
    end
  rescue ActiveRecord::RecordNotFound
    session[:service_id] = nil
  end

  def current_user?
    !!current_user
  end

  def logged_in?
    current_user?
  end

  def authenticate_user!
    go_home unless logged_in?
  end

  def logout!
    @current_user = nil
    reset_session
  end

  def go_home
    redirect_to redirect_path
  end

  def redirect_path
    :root
  end

  def setup_fb_config
    @fb_app_id ||= YAML.load_file(Rails.root.join('config/facebook.yml'))[Rails.env]['fb_app_id']
  end

  def setup_fb_graph
    return unless session[:oauth_token]

    @graph ||= Koala::Facebook::API.new session[:oauth_token]
    @me ||= @graph.get_object 'me' do |data|
      OpenStruct.new(
        name: data['first_name'],
        profile_path: @graph.get_picture(data['id']),
        gender: data['gender'],
        email: data['email']
      )
    end
  end
end
