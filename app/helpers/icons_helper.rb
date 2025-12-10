# app/helpers/icons_helper.rb
module IconsHelper
  def icon(name, **locals)
    render partial: "shared/icons/#{name}",
           formats: [:svg],
           locals: locals
  end
end
