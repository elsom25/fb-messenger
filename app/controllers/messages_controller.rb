class MessagesController < AuthenticatedController
  before_filter :get_friends

  def index
    redirect_to action: :new
  end

  def new
    @selected_friends = []#@friends
    @message = Message.new( current_user.fb_uid, session[:oauth_token] )
  end

  def create
    @selected_friends = params[:messages][:friends_uids].map{ |f| OpenStruct.new(JSON.parse(f)) }
    @message_message = params[:messages][:message]

    @message = Message.new( current_user.fb_uid, session[:oauth_token] )
    @message.send_mass_message( @selected_friends, @message_message )

    redirect_to new_message_path, notice: "Successfully messaged #{ActionController::Base.helpers.pluralize(@selected_friends.length, 'friend')}!"
  end

protected

  def get_friends
    @friends = Message.get_friends( @graph ).uw_all
  end

end
