begin 
  require_relative 'spec_helper'
rescue NameError
  require File.expand_path('spec_helper', __FILE__)
end

class Logger
  def write(message)

  end  
end  

describe 'MyApp' do

  it 'should run a simple test' do
    puts app
    get '/'
    last_response.status.should == 200
  end

end