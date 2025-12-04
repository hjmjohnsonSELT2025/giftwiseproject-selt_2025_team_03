# app/helpers/icons_helper.rb
module IconsHelper
  def icon(name, **locals)
    render partial: "shared/icons/#{name}",
           formats: [:svg],                 # tells Rails to look for .svg.erb
           locals: locals
  end
end
