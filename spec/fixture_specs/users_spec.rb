require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe "users.yml" do
  attr_reader :user

  describe "quentin" do
    before do
      @user = users(:quentin)
    end

    it "is active" do
      user.should be_active
    end
  end

  describe "aaron" do
    before do
      @user = users(:aaron)
    end

    it "is not active" do
      user.should_not be_active
    end
  end
end