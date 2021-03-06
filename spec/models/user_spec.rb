require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe User do
  attr_reader :user
  describe "Validations" do
    it 'requires login' do
      lambda do
        u = create_user(:login => nil)
        u.errors.on(:login).should_not be_nil
      end.should_not change(User, :count)
    end

    it 'requires password' do
      lambda do
        u = create_user(:password => nil)
        u.errors.on(:password).should_not be_nil
      end.should_not change(User, :count)
    end

    it 'requires password confirmation' do
      lambda do
        u = create_user(:password_confirmation => nil)
        u.errors.on(:password_confirmation).should_not be_nil
      end.should_not change(User, :count)
    end

    it 'requires email' do
      lambda do
        u = create_user(:email => nil)
        u.errors.on(:email).should_not be_nil
      end.should_not change(User, :count)
    end

    it 'resets password' do
      users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
      User.authenticate('quentin', 'new password').should == users(:quentin)
    end
  end

  describe "Life Cycle" do
    describe 'being created' do
      before do
        @user = nil
        @creating_user = lambda do
          @user = create_user
          violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
        end
      end

      it 'increments User#count' do
        @creating_user.should change(User, :count).by(1)
      end

      it 'initializes #activation_code' do
        @creating_user.call
        @user.reload
        @user.activation_code.should_not be_nil
      end

      it 'starts in pending state' do
        @creating_user.call
        @user.reload
        @user.should be_pending
      end
    end

    describe "after_save" do
      it 'does not rehash password' do
        users(:quentin).update_attributes(:login => 'quentin2')
        User.authenticate('quentin2', 'test').should == users(:quentin)
      end
    end    
  end

  describe "Associations" do
    describe "#votes.pain_points" do
      before do
        @user = users(:quentin)
        user.votes.should_not be_empty
      end

      it "returns the PainPoints of the Votes associated with the User" do
        user.votes.pain_points.should == user.votes.map do |vote|
          vote.pain_point
        end
      end
    end
  end

  describe "#authenticate" do
    it 'authenticates user' do
      User.authenticate('quentin', 'test').should == users(:quentin)
    end
  end

  describe "#remember_token" do
    it 'sets remember token' do
      users(:quentin).remember_me
      users(:quentin).remember_token.should_not be_nil
      users(:quentin).remember_token_expires_at.should_not be_nil
    end

    it 'remembers me for one week' do
      before = 1.week.from_now.utc
      users(:quentin).remember_me_for 1.week
      after = 1.week.from_now.utc
      users(:quentin).remember_token.should_not be_nil
      users(:quentin).remember_token_expires_at.should_not be_nil
      users(:quentin).remember_token_expires_at.between?(before, after).should be_true
    end

    it 'remembers me until one week' do
      time = 1.week.from_now.utc
      users(:quentin).remember_me_until time
      users(:quentin).remember_token.should_not be_nil
      users(:quentin).remember_token_expires_at.should_not be_nil
      users(:quentin).remember_token_expires_at.should == time
    end

    it 'remembers me default two weeks' do
      before = 2.weeks.from_now.utc
      users(:quentin).remember_me
      after = 2.weeks.from_now.utc
      users(:quentin).remember_token.should_not be_nil
      users(:quentin).remember_token_expires_at.should_not be_nil
      users(:quentin).remember_token_expires_at.between?(before, after).should be_true
    end
  end

  describe "#forget_me" do
    it 'unsets remember token' do
      users(:quentin).remember_me
      users(:quentin).remember_token.should_not be_nil
      users(:quentin).forget_me
      users(:quentin).remember_token.should be_nil
    end
  end

  describe "#register!" do
    it 'registers passive user' do
      user = create_user(:password => nil, :password_confirmation => nil)
      user.should be_passive
      user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
      user.register!
      user.should be_pending
    end
  end

  describe "#suspend!" do
    it 'suspends user' do
      users(:quentin).suspend!
      users(:quentin).should be_suspended
    end
  end

  describe "#authenticate" do
    it 'does not authenticate suspended user' do
      users(:quentin).suspend!
      User.authenticate('quentin', 'test').should_not == users(:quentin)
    end
  end

  describe "#delete!" do
    it 'deletes user' do
      users(:quentin).deleted_at.should be_nil
      users(:quentin).delete!
      users(:quentin).deleted_at.should_not be_nil
      users(:quentin).should be_deleted
    end
  end

  describe "#unsuspend!" do
    fixtures :users

    before do
      @user = users(:quentin)
      @user.suspend!
    end

    it 'reverts to active state' do
      @user.unsuspend!
      @user.should be_active
    end

    it 'reverts to passive state if activation_code and activated_at are nil' do
      User.update_all :activation_code => nil, :activated_at => nil
      @user.reload.unsuspend!
      @user.should be_passive
    end

    it 'reverts to pending state if activation_code is set and activated_at is nil' do
      User.update_all :activation_code => 'foo-bar', :activated_at => nil
      @user.reload.unsuspend!
      @user.should be_pending
    end
  end

  protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.register! if record.valid?
    record
  end
end
