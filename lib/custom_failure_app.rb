class CustomFailureApp < Devise::FailureApp
  def respond
    if request.format.to_sym == :html
      super
    else
      json_failure
    end
  end

  def json_failure
    self.status = 401
    self.content_type = 'json'
    self.response_body = "{'error' : 'authentication error'}"
  end
end