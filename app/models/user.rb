class User < ActiveRecord::Base
  def self.gravatar_for(username, size = nil)
    user = find_by_username(username.downcase) || find_by_username("default")
    "http://www.gravatar.com/avatar/#{user.gravatar_id}#{size ? "?s=#{size}" : ""}"
  end
end
