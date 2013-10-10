class MessagesController < AuthenticatedController
  before_filter :get_friends
  before_filter :set_view_variables

  def index
    redirect_to action: :new
  end

  def new; end

  def create
    unless params[:messages][:friends_uids]
      flash[:error] = 'You must select at least 1 friend.'
      return render :new
    end
    @selected_friends = params[:messages][:friends_uids].map{ |f| OpenStruct.new(JSON.parse(f)) }

    selected_messages = params[:messages][:messages].select(&:present?)
    unless selected_messages.present?
      flash[:error] = 'You must type at least 1 message.'
      return render :new
    end

    raise 't'

    @message.send_mass_message( @selected_friends, selected_messages )

    redirect_to new_message_path, notice: "Successfully messaged #{ActionController::Base.helpers.pluralize(@selected_friends.length, 'friend')}!"
  end

protected

  def get_friends
    @friends = Message.get_friends( @graph ).uw_all
  end

  def set_view_variables
    @message = Message.new( current_user.fb_uid, session[:oauth_token] )
    @selected_friends = []#@friends
  end

end
