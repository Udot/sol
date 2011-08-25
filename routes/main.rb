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
    use Warden::Manager do |manager|
      manager.default_strategies :password
      manager.failure_app = LoginManager
    end

    get "/" do
          login_greeting = if env['warden'].authenticated?
                      "welcome #{env['warden'].user}!"
                  else
                      "not logged in #{User.first.to_s} #{User.all.count}"
                  end

        <<eof
    #{login_greeting}
    <ul>
    <li><a href="/login">login</a></li>
    <li><a href="/logout">logout</a></li>
    <li><a href="/protected">protected</a></li>
    </ul>
eof
      end

      post '/unauthenticated/?' do
        status 401
        login
      end

      def login(failure = false)
          error_style = if failure
                            'style="background: red"'
                        else
                            ''
                        end

        <<eof
    <html>
    <body>
    <form action=/login method=post>
    username <input name="email" type="text"/>
    password <input name="password" type="password"/>
    <input name="Submit" type="Submit" />
    </form>
    </body>
    </html>
eof
    end

    get '/login/?' do
      login
    end

    get '/protected' do
        env['warden'].authenticate!
        'this is protected'
    end

    post '/login/?' do
      if env['warden'].authenticate
        redirect "/"
      else
        login(true)
      end
    end

    get '/logout/?' do
      env['warden'].logout
      redirect '/'
    end

    get '/error' do
        uri = params['uri']
        %$login error trying to access <a href="#{uri}">#{uri}</a>. Go <a href="/">home</a> instead.$
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
