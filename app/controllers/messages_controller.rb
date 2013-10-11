class MessagesController < AuthenticatedController
  before_filter :get_connections
  before_filter :set_view_variables

  def index
    redirect_to action: :new
  end

  def new; end

  def create
    selected_messages = params[:messages][:messages].select(&:present?)
    unless selected_messages.present?
      flash[:error] = 'You must type at least 1 message.'
      return render :new
    end

    friends = params[:messages][:friends_uids]
    if friends
      @selected_friends = friends.map{ |f| OpenStruct.new(JSON.parse(f)) }
      # @message.send_mass_message( @selected_friends, selected_messages )
    end

    groups = params[:messages][:groups_uids]
    if groups
      @selected_groups = groups.map{ |g| OpenStruct.new(JSON.parse(g)) }
      @message.send_mass_post( @selected_groups, selected_messages )
    end

    redirect_to new_message_path, notice: "Successfully messaged #{helpers.pluralize(@selected_friends.length, 'friend')} and #{helpers.pluralize(@selected_groups.length, 'group')}!"
  end

protected

  def get_connections
    friends  = Message.get_friends( @graph )
    groups   = Message.get_groups_and_pages( @graph )

    @friends = friends.uw_all
    gon.friends_uw_in_school    = friends.uw_in_school
    gon.friends_uw_all          = friends.uw_all
    gon.friends_waterloo_region = friends.waterloo_region
    gon.friends_all             = friends.all

    @groups  = groups.all
    gon.groups = groups.groups
    gon.pages  = groups.pages
  end

  def set_view_variables
    @message = Message.new( current_user.fb_uid, session[:oauth_token], @graph )
    @selected_friends = []#@friends
    @selected_groups = []#@groups
  end

  def helpers
    ActionController::Base.helpers
  end

end
