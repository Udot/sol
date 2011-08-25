class Project
  include DataMapper::Resource

  has n, :sessions

  property :id, Serial
  property :name, Text
  property :user_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
end