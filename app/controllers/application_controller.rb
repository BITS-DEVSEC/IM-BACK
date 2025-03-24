class ApplicationController < ActionController::API
  include Authentication
  include Authorization
  include PolicyScope
end
