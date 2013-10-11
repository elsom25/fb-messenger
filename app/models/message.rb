class Message
  include ActiveModel::Model

  CONFIG = YAML.load_file(Rails.root.join('config/facebook.yml'))[Rails.env]
  SELECTION = %w(uid name first_name).join(',').freeze
  BLACKLIST = %w(511137279 571555191).join(',').freeze
  #BLACKLIST= Adam Garcia; David Collins;
  ROOT_QUERY = %Q{
    SELECT #{SELECTION}
    FROM user
    WHERE uid IN (
      SELECT uid2
      FROM friend
      WHERE uid1 = me()
    )
    AND NOT (uid IN (#{BLACKLIST}))
  }

  attr_reader :sender_uid, :sender_token, :graph

  def initialize(sender_uid, sender_token, graph)
    @sender_uid = sender_uid
    @sender_token = sender_token
    @graph = graph
  end

  def send_mass_message(friend_list, message_list, subject=nil)
    client = create_client

    friend_list.each do |friend|
      templated_body = "hey #{friend.first_name.downcase},\n#{message_list.sample}"
      message = create_message(friend.uid, templated_body, subject)
      client.send message
    end

    client.close
  end

  def send_mass_post(object_list, message_list)
    object_list.each do |object|
      templated_message = "Hey #{object.name}!\n\n#{message_list.sample}"
      @graph.put_object(object.id, 'feed', message: templated_message)
    end
  end

  def self.get_friends(graph)
    uw_2018 = graph.fql_query(%Q{
      #{ROOT_QUERY}
      AND 'University of Waterloo' IN education.school
      AND '2018' IN education.year
    }).to_set
    uw_2017 = graph.fql_query(%Q{
      #{ROOT_QUERY}
      AND 'University of Waterloo' IN education.school
      AND '2017' IN education.year
    }).to_set
    uw_2016 = graph.fql_query(%Q{
      #{ROOT_QUERY}
      AND 'University of Waterloo' IN education.school
      AND '2016' IN education.year
    }).to_set
    uw_2015 = graph.fql_query(%Q{
      #{ROOT_QUERY}
      AND 'University of Waterloo' IN education.school
      AND '2015' IN education.year
    }).to_set
    uw_2014 = graph.fql_query(%Q{
      #{ROOT_QUERY}
      AND 'University of Waterloo' IN education.school
      AND '2014' IN education.year
    }).to_set
    uw_2013 = graph.fql_query(%Q{
      #{ROOT_QUERY}
      AND 'University of Waterloo' IN education.school
      AND '2013' IN education.year
    }).to_set
    uw = graph.fql_query(%Q{
      #{ROOT_QUERY}
      AND 'University of Waterloo' IN education.school
    }).to_set
    waterloo_region = graph.fql_query(%Q{
      #{ROOT_QUERY}
      AND 'Waterloo' IN affiliations
    }).to_set
    all = graph.fql_query("#{ROOT_QUERY}").to_set

    uw_other             = uw - (uw_2018 | uw_2017 | uw_2016 | uw_2015 | uw_2014 | uw_2013)
    waterloo_region_only = waterloo_region - uw
    unknown              = all - waterloo_region

    OpenStruct.new(
       uw_2018: uw_2018.to_a,
       uw_2017: uw_2017.to_a,
       uw_2016: uw_2016.to_a,
       uw_2015: uw_2015.to_a,
       uw_2014: uw_2014.to_a,
       uw_2013: uw_2013.to_a,
      uw_other: uw_other.to_a,
      waterloo: waterloo_region_only.to_a,
       unknown: unknown.to_a,
           all: all.to_a
    )
  end

  def self.get_groups_and_pages(graph)
    groups = graph.get_connections('me', 'groups').to_set
    pages  = graph.get_connections('me', 'accounts').to_set

    all = groups | pages

    OpenStruct.new(
      groups: groups.to_a,
       pages: pages.to_a,
         all: all.to_a
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
