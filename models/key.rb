# encoding : utf-8
class SshKey
  include DataMapper::Resource

  belongs_to :user
  has n, :eggs, :through => Resource

  property :id, Serial
  property :name, String, :required => true
  property :ssh_key, Text, :required => true
  property :user_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deploy, Boolean, :default => false

  # extract the login from the pasted key and insert it in the db
  def extract_login
    key_pieces = self.ssh_key.split(" ")
    return key_pieces[2] if key_pieces.size == 3
  end
  alias_method :login, :extract_login

  # return the ssh key (without the username@host)
  def short
    key_pieces = self.ssh_key.split(" ")
    return key_pieces[0] + " " + key_pieces[1]
  end

  def kind
    return "push (read-write, your side)" unless deploy
    return "pull (read-only, app server side)"
  end

  # split up the key in several 20 chars lines
  def ssh_key_nice
    nice_key = ""
    ssh_key.split("\n").each do |key_slice|
      if key_slice.size < 20
        nice_key += key_slice + "\n"
      else
        i = 0
        while i < key_slice.size
          nice_key += key_slice.slice(i..i+20) + "\n"
          i += 21
        end
      end
    end  
    return nice_key
  end

  # class method
  # export all stored keys
  def self.export
    auth_file = ""
    options = ["no-port-forwarding", "no-X11-forwarding", "no-agent-forwarding"].join(",")
    SshKey.each do |key|
      command = "command=\"#{Settings.shell.path} #{key.user.login}\""
      auth_file += "#{command},#{options} #{key.short}\n"
    end
    return auth_file
  end

  # send keys to git gate using the MercureApi
  def self.deploy
    return MercureApi.deploy_keys(SshKey.export)
  end
  
  # validity check
  def self.valid?(a_key)
    if a_key
      key_pieces = a_key.split(" ")
      if key_pieces.size < 3
        return false # we want a full three parts ssh key
      end

      # Test first element
      if !['ssh-dss', 'ssh-rsa'].include? key_pieces[0]
        return false # The key doesn't start with a valid identifier
      end

      # Test key format : first element need to match the start of the key
      # We can't have a ssh-rsa start with a ssh-dsa key ...
      ## ssh-rsa
      if key_pieces[1].start_with?("AAAAB3NzaC1yc2EA") and key_pieces[0] == "ssh-rsa"
        return true
      end
      ## ssh-dss
      if key_pieces[1].start_with?("AAAAB3NzaC1kc3MA") and key_pieces[0] == "ssh-dss"
        return true
      end

      # if no test return true, the key is invalid
      return false

    else
      return false # no ssh key
    end
  end
end
