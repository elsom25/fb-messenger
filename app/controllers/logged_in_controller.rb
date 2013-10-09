class LoggedInController < ApplicationController
  before_filter :authenticate_user!
end
