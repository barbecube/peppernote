class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource)
    return notebooks_path
  end

  def is_from_ajax      
    if params[:from] == "ajax"
      render :layout => "for_ajax"
    else
      render :layout => "application"
    end    
  end

  def is_from_ajax_render(action)
    if params[:from] == "ajax"
      render action, :layout => "for_ajax"
    else
      render action, :layout => "application"
    end  
  end
end
