class Api::V1::TokensController  < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def create
    email = params[:email]
    password = params[:password]
  
    if request.format != :json
      render :status=>406, :json=>{:message=>"The request must be json"}
      return
    end

    if email.nil? or password.nil?
      render :status=>400,
             :json=>{:message=>"The request must contain the user email and password."}
      return
    end

    @user=User.find_by_email(email.downcase)

    if @user.nil?
      logger.info("User #{email} failed signin, user cannot be found.")
      render :status=>401, :json=>{:message=>"Invalid email or password."}
      return
    end

    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @user.ensure_authentication_token!

    if not @user.valid_password?(password)
      logger.info("User #{email} failed signin, password is invalid")
      render :status=>401, :json=>{:message=>"Invalid email or password."}
    else
      render :status=>200, :json=>{:id=>@user.id, :token=>@user.authentication_token}
    end
  end

  def destroy
    begin
      @user=User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.info("User not found.")
      render :status=>404, :json=>{:message=>"User id not found."}
      return
    end
    if @user.nil? or @user.authentication_token != params[:auth_token]
      logger.info("Invalid token.")
      render :status=>401, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{:token=>params[:auth_token]}
    end
  end
end