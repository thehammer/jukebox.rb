module UserHelper
  def users
    User.find(:all).reject {|u| u.username == 'default'}
  end

  def active_toggle_link(user)
    if user.active?
      url = user_inactivate_url({:username => user.username})
      label = "disable"
    else
      url = user_activate_url({:username => user.username})
      label = "enable"
    end

    "<a style='color: gray; text-decoration: none' href='#{url}'>#{label}</a>"
  end
end

