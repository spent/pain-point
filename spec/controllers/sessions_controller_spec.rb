require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe SessionsController do
  describe "POST #create" do
    describe "when passed a correct login and password" do
      it 'logins and redirects' do
        post :create, :login => 'quentin', :password => 'test'
        session[:user_id].should_not be_nil
        response.should be_redirect
      end
  
      it 'remembers me' do
        post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
        response.cookies["auth_token"].should_not be_nil
      end
  
      it 'does not remember me' do
        post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
        response.cookies["auth_token"].should be_nil
      end
    end
    
    describe "when passed an incorrect login and password" do
      before do
        post :create, :login => 'quentin', :password => 'bad password'
      end

      it 'fails login and does not redirect' do
        session[:user_id].should be_nil
        response.should be_success
      end

      it "notifies the user that the login is incorrect" do
        error_message = "The username and password did not match"
        flash[:error].should == error_message
        response.body.should include(error_message)
      end
    end
  end

  describe "GET #destroy" do
    it 'logs out' do
      login_as :quentin
      get :destroy
      session[:user_id].should be_nil
      response.should be_redirect
    end

    it 'deletes token on logout' do
      login_as :quentin
      get :destroy
      response.cookies["auth_token"].should == []
    end
  end

  describe "GET #new" do
    it 'logs in with cookie' do
      users(:quentin).remember_me
      request.cookies["auth_token"] = cookie_for(:quentin)
      get :new
      controller.send(:logged_in?).should be_true
    end

    it 'fails expired cookie login' do
      users(:quentin).remember_me
      users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
      request.cookies["auth_token"] = cookie_for(:quentin)
      get :new
      controller.send(:logged_in?).should_not be_true
    end

    it 'fails cookie login' do
      users(:quentin).remember_me
      request.cookies["auth_token"] = auth_token('invalid_auth_token')
      get :new
      controller.send(:logged_in?).should_not be_true
    end    
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(user)
    auth_token users(user).remember_token
  end
end
