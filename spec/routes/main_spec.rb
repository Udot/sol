begin 
  require_relative '../spec_helper'
rescue NameError
  require File.expand_path('../spec_helper', __FILE__)
end

describe 'MyApp::main' do

  it 'should run a simple test' do
    get '/'
    last_response.status.should == 200
  end

end