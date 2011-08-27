class SshKey
  include DataMapper::Resource

  belongs_to :user
  has n, :eggs, :through => Resource

  property :id, Serial
  property :ssh_key, Text
  property :user_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
end