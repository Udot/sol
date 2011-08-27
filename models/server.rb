class Dragon
  include DataMapper::Resource

  belongs_to :user
  belongs_to :egg

  has n, :ssh_keys, :through => Resource

  property :id, Serial
  property :name, Text
  property :public_address, Text
  property :private_address, Text
  property :user_id, Integer
  property :egg_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
end