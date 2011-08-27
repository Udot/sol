class Egg
  include DataMapper::Resource

  belongs_to :user
  has n, :ssh_keys, :through => Resource
  has 1, :dragon
  has 1, :git_repository

  property :id, Serial
  property :name, Text
  property :user_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
end