class Message
  include ActiveModel::Model

  CONFIG = YAML.load_file(Rails.root.join('config/facebook.yml'))[Rails.env]
  PAGE_ID = 242656965898126
  SELECTION = %w(uid name first_name).join(',').freeze
  BLACKLIST = %w(511137279 571555191 1070874668 508384289 100000306667329).join(',').freeze
=begin
  Adam Garcia:   511137279
  David Collins: 571555191
  Danielle Burt: 1070874668
  Maaz Yasin:    508384289
  Renish Kamal:  100000306667329
=end
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
    friend_list.each do |friend|
      templated_body = "hey #{friend.first_name.downcase},\n#{message_list.sample}"

      MessageWorker.perform_async(@sender_uid, @sender_token, friend.name, friend.uid, templated_body, subject)
      ap "Enqueued #{friend.name}"
    end
  end

  def send_mass_post(object_list, message_list)
    object_list.each do |object|
      templated_message = "Hey #{object.name}!\n\n#{message_list.sample}"
      @graph.put_object(object.id, 'feed', message: templated_message)
    end
  end

  def self.get_friends(graph)
    results = graph.fql_multiquery(
      uw_2018: %Q{
        #{ROOT_QUERY}
        AND 'University of Waterloo' IN education.school
        AND '2018' IN education.year
      },
      uw_2017: %Q{
        #{ROOT_QUERY}
        AND 'University of Waterloo' IN education.school
        AND '2017' IN education.year
      },
      uw_2016: %Q{
        #{ROOT_QUERY}
        AND 'University of Waterloo' IN education.school
        AND '2016' IN education.year
      },
      uw_2015: %Q{
        #{ROOT_QUERY}
        AND 'University of Waterloo' IN education.school
        AND '2015' IN education.year
      },
      uw_2014: %Q{
        #{ROOT_QUERY}
        AND 'University of Waterloo' IN education.school
        AND '2014' IN education.year
      },
      uw_2013: %Q{
        #{ROOT_QUERY}
        AND 'University of Waterloo' IN education.school
        AND '2013' IN education.year
      },
      uw: %Q{
        #{ROOT_QUERY}
        AND 'University of Waterloo' IN education.school
      },
      waterloo_region: %Q{
        #{ROOT_QUERY}
        AND 'Waterloo' IN affiliations
      },
      liked_page: %Q{
        #{ROOT_QUERY}
        AND uid IN (
          SELECT user_id
          FROM like
          WHERE object_id = #{PAGE_ID}
        )
      },
      all: "#{ROOT_QUERY}"
    )
    uw_2018         = results['uw_2018'].to_set
    uw_2017         = results['uw_2017'].to_set
    uw_2016         = results['uw_2016'].to_set
    uw_2015         = results['uw_2015'].to_set
    uw_2014         = results['uw_2014'].to_set
    uw_2013         = results['uw_2013'].to_set
    uw              = results['uw'].to_set
    waterloo_region = results['waterloo_region'].to_set
    all             = results['all'].to_set
    liked           = results['liked_page'].to_set

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
         liked: liked.to_a,
           all: all.sort_by{ |u| u['name'] }
    )
  end

  def self.get_groups_and_pages(graph)
    groups = graph.get_connections('me', 'groups').to_set
    pages  = graph.get_connections('me', 'accounts').to_set

    all = groups | pages

    OpenStruct.new(
      groups: groups.to_a,
       pages: pages.to_a,
         all: all.sort_by{ |g| g['name'] }
    )
  end

end
