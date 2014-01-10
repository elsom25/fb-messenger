class MessageWorker
  include Sidekiq::Worker

  def perform(sender_uid, sender_token, receiver_uid, message_body, message_subject=nil)
    flush 'Initialized MessageWorker instance'

    message = create_message(receiver_uid, message_body, message_subject)

    client = create_client(sender_uid, sender_token)
    client.send message
    client.close

    flush "Message sent"
  end

protected

  def create_message(receiver_uid, message_body, message_subject)
    receiver_chat_id = "-#{receiver_uid}@chat.facebook.com"

    message = Jabber::Message.new receiver_chat_id, message_body
    message.subject = message_subject if message_subject

    flush "Message created: #{message_body}"
    message
  end

  def create_client(sender_uid, sender_token)
    sender_chat_id = "-#{sender_uid}@chat.facebook.com"
    client = Jabber::Client.new(Jabber::JID.new(sender_chat_id))

    client.connect
    client.auth_sasl(
      Jabber::SASL::XFacebookPlatform.new(
        client,
        CONFIG['fb_app_id'],
        sender_token,
        CONFIG['fb_secret_key']
      ),
      nil
    )

    client
  end

  def flush(str)
    puts str
    $stdout.flush
  end

end
