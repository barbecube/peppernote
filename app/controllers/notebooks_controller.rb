class NotebooksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorized_user, :only => [:edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound do |e|
    respond_to do |format|
      format.html {
        flash[:error] = e.message
        redirect_to root_path }
      format.json { render :status=>404, :json=>{:message=>e.message} }
    end
  end
  
  def create
  	@notebook = current_user.notebooks.build(params[:notebook])    
    if @notebook.save
      respond_to do |format|
        format.html {
          flash[:success] = "Notebook created!"
          redirect_to notebooks_path }
        format.json { render :json => @notebook }
      end
    else
      @title = "New Notebook"
      respond_to do |format|
        format.html { render 'notebooks/new' }
        format.json { render :json => @notebook.errors }
      end
    end  	
  end

  def destroy
	  @notebook.destroy
    respond_to do |format|
  	  format.html { redirect_to notebooks_path }
      format.json { render :json => @notebook }
    end
  end

  def edit
  	@title = "Edit notebook"
    is_from_ajax()
  end

  def update
    if @notebook.update_attributes(params[:notebook])
   	  respond_to do |format|
        format.html {
          flash[:success] = "Notebook updated."
     	    redirect_to notebooks_path }
        format.json { render :json => @notebook }
      end
   	else
   	  @title = "Edit notebook"
      respond_to do |format|
        format.html { render 'edit' }
        format.json { render :json => @notebook.errors }        
      end   	  
   	end
  end

  def index
  	@title = "Notebooks"
    @notebooks = current_user.notebooks
    respond_to do |format|
      format.html
      format.json { render :json => @notebooks }
    end
  end

  def new
  	@notebook = Notebook.new
  	@title = "New Notebook"
    is_from_ajax()
  end

  def show
    @notebook = Notebook.find(params[:id])
    @notes = @notebook.notes
    @title = "Notebook - #{@notebook.name}"
    respond_to do |format|
      format.html
      format.json {render :json => @notes}
    end
  end
  
  private

    def authorized_user
      @notebook = Notebook.find(params[:id])
      redirect_to notebooks_path unless (current_user == @notebook.user)
    end    
end