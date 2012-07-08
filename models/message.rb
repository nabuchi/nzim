class Message
  include Mongoid::Document

  store_in :message

  field :user_id
  field :text
  field :date, type: DateTime
  field :room_id
end
