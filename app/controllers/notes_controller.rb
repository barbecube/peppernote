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
      @note.errors.add(:title, " has already been taken")
      respond_to do |format|
        format.html { is_from_ajax_render('new') }
        format.json {render :status=>400, :json => @note.errors }
      end
    else    
      if @note.save
        respond_to do |format|
          format.html {
            if params[:from] == "ajax"
              render :nothing => true
            else
              flash[:success] = "Note saved successfully!"
              redirect_to notebook_path(params[:notebook_id])
            end }            
          format.json {render :json => @note }        
        end      
      else
        @tile = "New Note"
        respond_to do |format|
          format.html { is_from_ajax_render('new') }
          format.json {render :status=>400, :json => @note.errors }
        end
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    if params.key?(:version) && @note.version > params[:version].to_i
      respond_to do |format|
        format.json { render :status=>409, :json => @note }
      end
    else
      @note.destroy
      respond_to do |format|
        format.html { redirect_to notebook_path(params[:notebook_id]) }
        format.json { render :json => @note }
      end 
    end   
  end

  def edit
    @title = "Edit note"
    @notebook = Note.find(params[:id]).notebook
    is_from_ajax()
  end

  def update    
    @note = Note.find(params[:id])
    @notes = current_user.notebooks.find(@note.notebook_id).notes
    @new_note = params[:note]
    if @note.title != @new_note['title'] && @notes.find_by_title(@new_note['title']) 
      @note.errors.add(:title, " has already been taken")
      respond_to do |format|
        format.html { is_from_ajax_render('new') }
        format.json {render :status=>400, :json => @note.errors }
      end
      return
    end
    
    if params.key?(:version) && @note.version > params[:version].to_i
      merged_content = "#{@note.content}\n\nSynchronization conflict, updating with older version:\n\n#{@new_note['content']}"
      @new_note["content"] = merged_content
    end 
    
    if @note.update_attributes(@new_note)
      @note.version += 1
      @note.save  
      respond_to do |format|
        format.html {
          if params[:from] == "ajax"
            render :nothing => true
          else
            flash[:success] = "Note updated."
            redirect_to note_path(@note.id)
          end }          
        format.json { render :json => @note }
      end
    else
      @title = "Edit note"
      respond_to do |format|
        format.html { is_from_ajax_render('edit') }
        format.json { render :status=>400, :json => @note.errors }
      end
    end
  end

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
        is_from_ajax_render("show")
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