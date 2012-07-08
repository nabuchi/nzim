class Favorite
  include Mongoid::Document

  store_in :favorite

  field :user_id
  embeds_many :messages
end
