class MessageWorker
  include Sidekiq::Worker

  def initialize(sender_uid, sender_token, receiver_uid, message_body, message_subject=nil)
    @sender_uid = sender_uid
    @sender_token = sender_token
    @receiver_uid = receiver_uid
    @message_body = message_body
    @message_subject = message_subject if message_subject

    flush 'Initialized MessageWorker instance'
  end

  def send
    message = create_message

    client = create_client
    client.send message
    client.close

    flush "Message sent"
  end

  def perform(*args)
    (new *args).send
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

  def create_message
    receiver_chat_id = "-#{@receiver_uid}@chat.facebook.com"

    message = Jabber::Message.new receiver_chat_id, @body
    message.subject = @subject if @subject

    flush "Message created: #{@body}"
    message
  end

  def flush(str)
    puts str
    $stdout.flush
  end

end
