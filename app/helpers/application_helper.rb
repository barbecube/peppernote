module ApplicationHelper
  def logo
    image_tag("logo1.png", :alt => "PepperNote")
  end

  # Return a title on a per-page basis.
  def title
	base_title = "PepperNote"
	if @title.nil?
	  base_title
	else
	  "#{base_title} | #{@title}"
	end
  end

  def is_from_ajax      
    if params[:from] == "ajax"
      render :layout => "for_ajax"
    else
      render :layout => "application"
    end    
  end
end
