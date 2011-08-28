class MyApp < Sinatra::Application
    configure do
      LOGGER = Logger.new("sinatra.log")
    end

    helpers do
      def logger
        LOGGER
      end
    end

    Warden::Manager.serialize_into_session{|user| user.id }
    Warden::Manager.serialize_from_session{|id| User.get(id) }

    Warden::Manager.before_failure do |env,opts|
      # Sinatra is very sensitive to the request method
      # since authentication could fail on any type of method, we need
      # to set it for the failure app so it is routed to the correct block
      env['REQUEST_METHOD'] = "POST"
    end

    Warden::Strategies.add(:password) do

      def logger
        LOGGER
      end

      def valid?
        params["email"] || params["password"]
      end

      def authenticate!
        logger.info "#{params['email']}, #{params['password']}"
        u = User.authenticate(params["email"], params["password"])
        u.nil? ? fail!("Could not log in") : success!(u)
      end
    end

    use Rack::Session::Cookie
    use Rack::Flash
    use Warden::Manager do |manager|
      manager.default_strategies :password
      manager.failure_app = LoginManager
    end

    get "/" do
      root_dir = "public"
      if env['warden'].user
        redirect "/dashboard"
      end
      haml "public/index".to_sym
    end

    post '/unauthenticated/?' do
      status 401
      login
    end

    get '/login/?' do
      haml "public/login".to_sym
    end

    get '/protected' do
      env['warden'].authenticate!
      flash[:notice] = 'this is protected'
    end

    post '/login/?' do
      if env['warden'].authenticate
        redirect "/", :notice => "Logged in"
      else
        redirect "/login", :error => "Login failed"
      end
    end

    get '/logout/?' do
      env['warden'].logout
      redirect "/", :notice => "Logged out"
    end

    get '/error' do
      uri = params['uri']
      %$login error trying to access <a href="#{uri}">#{uri}</a>. Go <a href="/">home</a> instead.$
    end

    get '/test' do
      haml "public/index".to_sym
    end
  end

  class LoginManager < Sinatra::Base
    get "/" do
      haml :welcome
    end

    post '/unauthenticated/?' do
      status 401
      haml :login
    end

    get '/login/?' do
      haml :login
    end

    post '/login/?' do
      env['warden'].authenticate!
      redirect "/"
    end

    get '/logout/?' do
      env['warden'].logout
      redirect '/'
    end
end
