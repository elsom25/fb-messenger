Rails.application.config.middleware.use OmniAuth::Builder do
  CONFIG = YAML.load_file(Rails.root.join('config/facebook.yml'))[Rails.env]
  SCOPE = [
    # General user information
    :email,
    :user_status,
    :user_location,
    :user_about_me,
    :user_likes,
    :user_education_history,
    :user_events,
    :user_groups,
    :user_likes,

    :read_stream,
    :read_friendlists,
    :read_mailbox,
    :friends_online_presence,

    :manage_pages,

    :publish_stream,              # publish pictures to album for profile/cover photo update
    :publish_actions,

    :friends_status,
    :friends_about_me,
    :friends_likes,
    :friends_education_history,   # to determine friends that go to same school
    :friends_events,
    :friends_groups,
    :friends_likes,

    :offline_access,              # gives a long-lasting auth token
    :xmpp_login                   # allows for chat messages (mass messaging)
  ].join ','

  provider :facebook,
    CONFIG['fb_app_id'],
    CONFIG['fb_secret_key'],
    scope: SCOPE

end
