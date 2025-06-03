class ApplicationController < ActionController::API
  include Authentication
  include Authorization
  include PolicyScope
  include ActionController::Cookies
end
