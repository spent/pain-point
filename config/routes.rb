ActionController::Routing::Routes.draw do |map|
  map.resources :pain_points do |pain_points|
    pain_points.namespace("vote_submissions") do |vote_submissions|
      vote_submissions.resources(:up_vote, :controller => "vote_submissions/up_vote_submissions") do |up_vote|
        map.create_pain_point_up_vote(
          "/pain_points/:pain_point_id/up_vote",
          :controller => "vote_submissions/up_vote_submissions", :action => "create"
        )
      end
      map.create_pain_point_up_vote(
        "/pain_points/:pain_point_id/up_vote",
        :controller => "vote_submissions/up_vote_submissions", :action => "create"
      )
      vote_submissions.resources :down_vote, :controller => "vote_submissions/down_vote_submissions"
    end
  end
  map.resource :session
  map.resources :users

  map.lobby '/', :controller => 'lobby', :action => 'show'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
end
