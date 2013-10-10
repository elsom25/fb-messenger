class Message
  include ActiveModel::Model

  CONFIG = YAML.load_file(Rails.root.join('config/facebook.yml'))[Rails.env]
  SELECTION = %w(uid name first_name).join(',').freeze
  BLACKLIST = %w(511137279 571555191).join(',').freeze
  #         = Adam Garcia; David Collins;


  attr_reader :sender_uid, :sender_token

  def initialize(sender_uid, sender_token)
    @sender_uid = sender_uid
    @sender_token = sender_token
  end

  def send_mass_message(friend_list, body, subject=nil)
    client = create_client

    friend_list.each do |friend|
      templated_body = "hey #{friend.first_name.downcase},\n\n#{body}"
      message = create_message(friend.uid, templated_body, subject)
      client.send message
    end

    client.close
  end

  def self.get_friends(graph)
    uw_in_school_friends_raw = graph.fql_query(%Q{
      SELECT #{SELECTION}
      FROM user
      WHERE uid IN (
        SELECT uid2
        FROM friend
        WHERE uid1 = me()
      )
      AND NOT (uid IN (#{BLACKLIST}))
      AND 'University of Waterloo' IN education.school
      AND ('2014' IN education.year
        OR '2015' IN education.year
        OR '2016' IN education.year
        OR '2017' IN education.year
        OR '2018' IN education.year
      )
    }).to_set
    uw_friends_raw = graph.fql_query(%Q{
      SELECT #{SELECTION}
      FROM user
      WHERE uid IN (
        SELECT uid2
        FROM friend
        WHERE uid1 = me()
      )
      AND NOT (uid IN (#{BLACKLIST}))
      AND 'University of Waterloo' IN education.school
    }).to_set
    waterloo_region_friends_raw = graph.fql_query(%Q{
      SELECT #{SELECTION}
      FROM user
      WHERE uid IN (
        SELECT uid2
        FROM friend
        WHERE uid1 = me()
      )
      AND NOT (uid IN (#{BLACKLIST}))
      AND 'Waterloo' IN affiliations
    }).to_set
    all_friends_raw = graph.fql_query(%Q{
      SELECT #{SELECTION}
      FROM user
      WHERE uid IN (
        SELECT uid2
        FROM friend
        WHERE uid1 = me()
      )
      AND NOT (uid IN (#{BLACKLIST}))
    }).to_set

    uw_friends = uw_in_school_friends_raw | uw_friends_raw
    waterloo_region_friends = uw_friends  | waterloo_region_friends_raw
    all_friends = waterloo_region_friends | all_friends_raw

    OpenStruct.new(
         uw_in_school: uw_in_school_friends_raw.to_a,
               uw_all: uw_friends.to_a,
      waterloo_region: waterloo_region_friends.to_a,
                  all: all_friends.to_a
    )
  end

protected

  def create_client
    sender_chat_id = "-#{@sender_uid}@chat.facebook.com"
    client = Jabber::Client.new(Jabber::JID.new(sender_chat_id))

    client.connect
    client.auth_sasl(
      Jabber::SASL::XFacebookPlatform.new(
        client,
        CONFIG['fb_app_id'],
        @sender_token,
        CONFIG['fb_secret_key']
      ),
      nil
    )

    client
  end

  def create_message(receiver_uid, body, subject=nil)
    receiver_chat_id = "-#{receiver_uid}@chat.facebook.com"

    message = Jabber::Message.new receiver_chat_id, body
    message.subject = subject if subject

    message
  end

end

class MessageResult
  include ActiveModel::Model
  attr_accessor :status, :status_message, :num_messages, :points

  def initialize(attributes)
    super
    @points ||= 0
  end
end
