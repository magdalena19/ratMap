class AdminConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = User.find(request.session[:user_id])
    user && user.is_admin?
  end
end

class MapAccessRestriction
  attr_reader :token

  def is_secret_link?
    Map.find_by(secret_token: token)
  end

  def can_access_as_guest?
    map = Map.find_by(public_token: token)
    map && map.is_public
  end

  def is_map_admin_ressource?(request:)
    ressource = request.env["action_dispatch.request.parameters"]
    ressource[:controller] == "maps" && ["edit", "update", "destroy"].include?(ressource[:action])
  end

  def matches?(request)
    @token = request[:map_token]

    # Conditionally permit route access
    if is_map_admin_ressource?(request: request)
      return true if is_secret_link?
    else
      return true if is_secret_link? || can_access_as_guest?
    end

    return false
  end
end

class PlacesAccessRestriction
  attr_reader :token

  def is_secret_link?
    Map.find_by(secret_token: token)
  end

  def can_commit_as_guest?
    map = Map.find_by(public_token: token)
    map && map.is_public && map.allow_guest_commits
  end

  def matches?(request)
    @token = request[:map_token]
    return true if is_secret_link? || can_commit_as_guest?
    false
  end
end

class CategoriesAccessRestriction
  attr_reader :token

  def is_secret_link?
    Map.find_by(secret_token: token)
  end

  def matches?(request)
    @token = request[:map_token]
    return true if is_secret_link?
    false
  end
end
