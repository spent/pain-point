class Views::Layouts::Application < Erector::Widget
  def render
    html do
      head do
        title "Pain Point"
        js_files = [
          "jquery-1.2.3.js",
          "xmlbuilder",
          "json2",
          "models/pain_point",
          "views/pain_point_view",
          "views/pain_points_view"
        ]
        javascript_include_tag(*js_files)

        if ActionController::Base.allow_forgery_protection
          javascript "window._token = '#{helpers.form_authenticity_token}';"
        end

        stylesheet_link_tag 'typography', :cache => true
      end

      body do
        div flash[:notice], :class => "notice"
        div flash[:error], :class => "error"
        content
      end
    end
  end

  def content
    if @block
      instance_eval &block
    end
  end
end
