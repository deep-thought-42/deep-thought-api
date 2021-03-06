require 'rails_helper'

RSpec.describe Auth::SessionsController, type: :controller do
  context "GET /auth/sessions/google_sign_in" do
    it "should redirect to google oauth" do
      expect_any_instance_of(GoogleOauth).to receive(:client_id) { 'CLIENT_ID' }

      get :google_sing_in
      expect(subject).to redirect_to("https://accounts.google.com/o/oauth2/v2/auth?access_type=offline&client_id=CLIENT_ID&include_granted_scopes=true&prompt=select_account&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fauth%2Fsessions%2Fgoogle_callback&response_type=code&scope=email")
    end
  end

  context "GET /auth/sessions/google_callback" do
    it "should create and authenticate user" do
      expect_any_instance_of(User).to receive(:jwt) { "1" }

      stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
        .to_return(status: 200, body: '{"access_token": "fake_access_token"}')

      stub_request(:get, "https://www.googleapis.com/oauth2/v1/userinfo?access_token=fake_access_token&alt=json")
        .to_return(status: 200, body: fixture('apis/google_oauth/userinfo.json'))

      expect(User.find_by(email: "allan@allanbatista.com.br")).to be_blank

      get :google_callback, params: { code: "123" }
      expect(subject).to redirect_to("http://localhost:8080/?jwt=1")
      
      expect(User.find_by(email: "allan@allanbatista.com.br")).to be_persisted
    end

    it "should create and authenticate user with custom redirect auth" do
      expect_any_instance_of(Auth::SessionsController).to receive(:endpoint_callback) { "https://custom.com/" }
      expect_any_instance_of(User).to receive(:jwt) { "1" }

      stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
        .to_return(status: 200, body: '{"access_token": "fake_access_token"}')

      stub_request(:get, "https://www.googleapis.com/oauth2/v1/userinfo?access_token=fake_access_token&alt=json")
        .to_return(status: 200, body: fixture('apis/google_oauth/userinfo.json'))

      expect(User.find_by(email: "allan@allanbatista.com.br")).to be_blank

      get :google_callback, params: { code: "123" }
      expect(subject).to redirect_to("https://custom.com/?jwt=1")

      expect(User.find_by(email: "allan@allanbatista.com.br")).to be_persisted
    end

    it "should fail authenticate with exception" do
      stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
        .to_return(status: 200, body: '{}')

      expect($google_oauth).to receive(:userinfo) { raise StandardError.new("UNK") }

      get :google_callback, params: { code: "123" }
      expect(subject).to redirect_to("http://localhost:8080/?code=106&message=Exception+error")
      
      expect(User.find_by(email: "allan@allanbatista.com.br")).to be_blank
    end

    it "should fail authenticate with not found a userinfo" do
      stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
        .to_return(status: 400, body: '{"message": "error"}')

      get :google_callback, params: { code: "123" }
      expect(subject).to redirect_to("http://localhost:8080/?code=103&message=Oauth+Refused")
      
      expect(User.find_by(email: "allan@allanbatista.com.br")).to be_blank
    end

    context "MATCH" do
      it "should refuse user when email not match" do
        expect(Auth::SessionsController).to receive(:email_match) { Regexp.new(".*@google.com") }
        
        stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
          .to_return(status: 200, body: '{"access_token": "fake_access_token"}')
  
        stub_request(:get, "https://www.googleapis.com/oauth2/v1/userinfo?access_token=fake_access_token&alt=json")
          .to_return(status: 200, body: fixture('apis/google_oauth/userinfo.json'))
  
        get :google_callback, params: { code: "123" }
        expect(subject).to redirect_to("http://localhost:8080/?code=104&message=E-mail+not+authorizated")
        
        expect(User.find_by(email: "allan@allanbatista.com.br")).to be_blank
      end

      it "should match email currect" do
        expect_any_instance_of(User).to receive(:jwt) { "1" }
        expect(Auth::SessionsController).to receive(:email_match) { Regexp.new(".*@allanbatista.com.br") }
        
        stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
          .to_return(status: 200, body: '{"access_token": "fake_access_token"}')
  
        stub_request(:get, "https://www.googleapis.com/oauth2/v1/userinfo?access_token=fake_access_token&alt=json")
          .to_return(status: 200, body: fixture('apis/google_oauth/userinfo.json'))
  
          expect(User.find_by(email: "allan@allanbatista.com.br")).to be_blank
  
        get :google_callback, params: { code: "123" }
        expect(subject).to redirect_to("http://localhost:8080/?jwt=1")
        
        expect(User.find_by(email: "allan@allanbatista.com.br")).to be_persisted
      end
    end
  end
end
