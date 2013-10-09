class User < ActiveRecord::Base
  has_many :services

  def fb_uid
    self.services.where(provider: :facebook).first.try(:uid)
  end
end
