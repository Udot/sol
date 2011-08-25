class Session
  include DataMapper::Resource

  belongs_to :project

  property :id, Serial
  property :user_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
end