class User
  include Mongoid::Document

  store_in :user

  field :id
  field :screen_name
  field :profile_image_url
end
