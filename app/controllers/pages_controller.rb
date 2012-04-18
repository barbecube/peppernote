class PagesController < ApplicationController
  def home
  	@title = "Home"
  	if user_signed_in?
  		redirect_to notebooks_path
  	end
  end
end
