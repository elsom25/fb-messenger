class Message
  CONFIG = YAML.load_file(Rails.root.join('config/facebook.yml'))[Rails.env]
  BLACKLIST = %w(511137279 571555191 ).join(',').freeze
  #         = Adam Garcia; David Collins;

  attr_reader :sender_uid, :sender_token

  def initialize(sender_uid, sender_token)
    @sender_uid = sender_uid
    @sender_token = sender_token
  end

  def send_mass_message(receiver_uid_list, body, subject=nil)
    client = create_client

    receiver_uid_list.each do |uid|
      client.send create_message(uid, body, subject)
    end

    client.close
  end

  def self.get_all_friends(graph)
    uw_in_school_friends = graph.fql_query(%Q{
      SELECT uid, name
      FROM user
      WHERE uid IN (
        SELECT uid2
        FROM friend
        WHERE uid1 = me()
      )
      AND NOT (uid IN (#{self::BLACKLIST}))
      AND 'University of Waterloo' IN education.school
      AND ('2014' IN education.year
        OR '2015' IN education.year
        OR '2016' IN education.year
        OR '2017' IN education.year
        OR '2018' IN education.year
      )
    }).to_set
    uw_friends = graph.fql_query(%Q{
      SELECT uid, name
      FROM user
      WHERE uid IN (
        SELECT uid2
        FROM friend
        WHERE uid1 = me()
      )
      AND NOT (uid IN (#{self::BLACKLIST}))
      AND 'University of Waterloo' IN education.school
    }).to_set
    waterloo_region_friends = graph.fql_query(%Q{
      SELECT uid, name
      FROM user
      WHERE uid IN (
        SELECT uid2
        FROM friend
        WHERE uid1 = me()
      )
      AND NOT (uid IN (#{self::BLACKLIST}))
      AND 'Waterloo' IN affiliations
    }).to_set
    all_friends = graph.fql_query(%Q{
      SELECT uid, name
      FROM user
      WHERE uid IN (
        SELECT uid2
        FROM friend
        WHERE uid1 = me()
      )
      AND NOT (uid IN (#{self::BLACKLIST}))
    }).to_set

    friends = uw_in_school_friends | uw_friends | waterloo_region_friends # | all_friends

    friends.to_a
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
