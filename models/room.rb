class Room
  include Mongoid::Document

  store_in :room

  field :_id, type: String
  field :title
  field :updated_at, type: DateTime
  embeds_many :users
end
