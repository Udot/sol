# encoding : utf-8
class MyApp < Sinatra::Application
  get "/dashboard" do
    env['warden'].authenticate!
    @active_tab = "dashboard"
    @eggs = env['warden'].user.eggs
    @services = Array.new
    @services << {"name" => "Git gate", "description" => "Gateway to the trove", "status" => MercureApi.gate_status, "url" => "#"}
    haml "private/index".to_sym
  end

  get "/about" do
    @active = "about"
    haml :"public/about"
  end

  get "/contact" do
    @active = "contact"
    haml :"public/contact"
  end

  get "/builder" do
    env['warden'].authenticate!
    rand_string = ""
    @builder = User.first(:login => "pinpin")
    if @builder == nil
      42.times { rand_string += (0..9).to_a[rand(10)].to_s }
      pass_string = Digest::SHA1::hexdigest(Time.now.to_s + rand_string)
      @builder = User.create(:login => "pinpin", :email => "pinpin@no.where",
                  :role => "normal", :name => "pinpin",
                  :password => pass_string, :password_confirmation => pass_string)
      if @builder.save
        logger.info("builder user saved")
      else
        logger.error("could not save builder user")
        redirect "/", :error => "could not create builder user"
      end
    end
    @git = User.first(:login => "git")
    if @git == nil
      rand_string = ""
      42.times { rand_string += (0..9).to_a[rand(10)].to_s }
      pass_string = Digest::SHA1::hexdigest(Time.now.to_s + rand_string)
      @git = User.create(:login => "git", :email => "git@no.where",
                         :role => "normal", :name => "git",
                         :password => pass_string, :password_confirmation => pass_string)
      if @git.save
        logger.info("user git was saved")
      else
        logger.error("can't save git user\n#{@git.errors.each { |d| d.to_s } }")
        redirect "/", :error => "could not create git user"
      end
    end
    haml "private/builder".to_sym
  end

  post "/builder" do
    env['warden'].authenticate!
    builder = User.first(:login => "pinpin")
    if builder == nil
      redirect "/builder", :error => "could not find pinpin user"
    end
    ssh_key = SshKey.create(:name => "default", :ssh_key => params[:ssh_key], :deploy => true)
    builder.ssh_keys.each { |sk| sk.destroy }
    ssh_key.user = builder
    ssh_key.save
    git = User.first(:login => "git")
    if git == nil
      redirect "/builder", :error => "could not find git user"
    end
    # git key
    ssh_key = SshKey.create(:name => "default", :ssh_key => params[:ssh_key], :deploy => true)
    ssh_key.user = git
    ssh_key.save
    redirect "/builder".to_sym
  end
end
