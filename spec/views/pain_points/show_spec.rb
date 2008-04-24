require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe Views::PainPoints::Show do
  include ActionController::UrlWriter
  attr_reader :pain_point, :user, :html, :doc

  describe "Links" do
    before do
      @pain_point = pain_points(:software_complexity)
      @html = Views::PainPoints::Show.new(
        template,
        :pain_point => pain_point
      ).to_s
      @doc = Hpricot(html)
    end

    it "renders link to UpVoteSubmissionController#create" do
      doc.should have_link(
        pain_point_up_vote_index_path(:pain_point_id => pain_point.id),
        :method => :post
      )
    end

    it "renders link to DownVoteSubmissionController#create" do
      doc.should have_link(
        pain_point_down_vote_index_path(:pain_point_id => pain_point.id),
        :method => :post
      )
    end
  end

  describe "when there is no passed in User" do
    before do
      @pain_point = pain_points(:software_complexity)
      @html = Views::PainPoints::Show.new(
        template,
        :pain_point => pain_point
      ).to_s
      @doc = Hpricot(html)
    end

    it "does not render the up and down links with the selected class" do
      doc.at("a.up.selected").should be_nil
      doc.at("a.down.selected").should be_nil
    end
  end

  describe "when the User has not voted on the PainPoint" do
    before do
      @pain_point = pain_points(:software_complexity)
      @user = users(:quentin)
      user.votes.pain_points.should_not include(pain_point)
      
      @html = Views::PainPoints::Show.new(
        template,
        :user => user,
        :pain_point => pain_point
      ).to_s
      @doc = Hpricot(html)
    end

    it "does not render the up and down links with the selected class" do
      doc.at("a.up.selected").should be_nil
      doc.at("a.down.selected").should be_nil
    end
  end

  describe "when the User has voted on the PainPoint" do
    attr_reader :vote
    before(:each) do
      @vote = votes(:quentin_slow_tests)
      @pain_point = vote.pain_point
      @user = vote.user
    end

    describe "when the User has voted the PainPoint up" do
      before(:each) do
        vote.up_vote
        vote.state.should == 'up'
        @html = Views::PainPoints::Show.new(
          template,
          :user => user,
          :pain_point => pain_point
        ).to_s
        @doc = Hpricot(html)
      end

      it "renders the up link with a selected class" do
        doc.at("a.up.selected").should_not be_nil
        doc.at("a.down.selected").should be_nil
      end
    end

    describe "when the User has voted the PainPoint down" do
      before(:each) do
        vote.down_vote
        vote.state.should == 'down'
        @html = Views::PainPoints::Show.new(
          template,
          :user => user,
          :pain_point => pain_point
        ).to_s
        @doc = Hpricot(html)
      end

      it "renders the up link with a selected class" do
        doc.at("a.up.selected").should be_nil
        doc.at("a.down.selected").should_not be_nil
      end
    end
  end
end