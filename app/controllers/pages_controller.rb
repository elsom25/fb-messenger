class PagesController < ApplicationController
  def home
    redirect_to new_message_path if logged_in?
  end
end
