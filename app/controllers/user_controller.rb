class UserController < ApplicationController

  def activate
    user = User.find_by_username(params[:username])
    user.update_attributes!(:active => true) if user

    redirect_to user_show_url
  end

  def inactivate
    user = User.find_by_username(params[:username])
    user.update_attributes!(:active => false) if user

    redirect_to user_show_url
  end
end
