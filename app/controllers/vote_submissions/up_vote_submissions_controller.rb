class VoteSubmissions::UpVoteSubmissionsController < VoteSubmissions::VoteSubmissionsController
  def create
    vote = current_user.votes.find_or_create_by_pain_point_id(params[:pain_point_id])
    vote.up_vote
    vote.save!
    @user = current_user
    @pain_point = vote.pain_point
    render :template => "pain_points/show"
  end
end
