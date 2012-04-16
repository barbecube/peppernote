class NotesController < ApplicationController
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
    @notes = current_user.notebooks.find(params[:notebook_id]).notes
    @note = @notes.build(params[:note])
    if @notes.find_by_title(@note.title) 
      alert("fail")
    else    
      if @note.save
        respond_to do |format|
          format.html {
            flash[:success] = "Note saved successfully!"
            redirect_to notebook_path(params[:notebook_id]) }
          format.json {render :json => @note }        
        end      
      else
        @tile = "New Note"
        respond_to do |format|
          format.html { render 'new' }
          format.json {render :json => @note.errors }
        end
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notebook_path(params[:notebook_id]) }
      format.json { render :json => @note }
    end    
  end

  def edit
    @title = "Edit note"
    @notebook = Note.find(params[:id]).notebook
    is_from_ajax()
  end

  def update
    @note = Note.find(params[:id])
    if @note.update_attributes(params[:note])  
      respond_to do |format|
        format.html {
          flash[:success] = "Note updated."
          redirect_to note_path(@note.id) }
        format.json { render :json => @note }
      end
    else
      @title = "Edit note"
      respond_to do |format|
        format.html { render 'edit' }
        format.json { render :json => @note.errors }
      end
    end
  end

#  def index
#    @title = "Notes"
#  end
  
#  def notes_menu
#    @title = "Notes menu"

#  end

#  def notes_list
#    @title = "Notes list"
#    @notebook = current_user.notebooks.find_by_id(params[:nb_id])

#  end

  def new
    @note = Note.new
    @title = "New Note"    
    if params.key?(:notebook_id)
      @notebook = current_user.notebooks.find(params[:notebook_id])
      is_from_ajax()
    else
      flash[:error] = "Undefined notebook_id: Must be called from notebook"
      redirect_to notebooks_path
    end

  end

  def show
    @note = Note.find(params[:id])    
#    @notebook = @note.notebook
    @title = @note.title    
    respond_to do |format|
      format.html {
        if params[:from] == "ajax"
          render :action => "show", :layout => "for_ajax"
        else
          render :action => "show", :layout => "application"
        end
      }
      format.json { render :json => @note }
    end
  end

  private

    def authorized_user
      @note = Note.find(params[:id])
      if @note
        redirect_to root_path unless (current_user == @note.notebook.user)
      end
    end
end