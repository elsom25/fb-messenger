class MessagesController < AuthenticatedController
  before_filter :get_friends

  def index
    redirect_to action: :new
  end

  def new
    @message = Message.new( current_user.fb_uid, session[:oauth_token] )
  end

  def create
    @message = Message.new( current_user.fb_uid, session[:oauth_token] )
    @message.send_mass_message(params[:friends_uids], "test message")
  end

protected

  def get_friends
    @friends = Message.get_friends( @graph ).uw_all
  end

end
