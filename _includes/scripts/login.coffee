###
  Need:
  - Login link with id="login-button"
###
login = {
  link: $ "#login-button"
  init: () ->
    if storage.get("login.token") and login.link.text() == "Login"
      login.link.text 'Logout'
        .off "click"
        .on "click", login.logout
        .attr "title", "Logged as #{storage.get('login.user')}"
    else
      login.link.on "click", login.serve
    login.link.show()
    true
  serve: (e) ->
    e.preventDefault()
    token = prompt "Paste a GitHub personal token"
    if token
      storage.set "login.token", token
      login.link.addClass "disabled"
      $.ajax "{{ site.github.api_url }}/user",
        method: "GET"
        headers: "Authorization": "token #{token}"
        success: login.success
        error: login.error
        complete: login.complete
    true
  success: (data, status) ->
    storage.set "login.user", data.login
      .set "login.created", new Date()
    login.link.text "Logout"
      .off "click"
      .on "click", login.logout
    login.permissions data.login
    true
  error: (request, status, error) ->
    storage.clear "login"
    login.link.removeClass "disabled"
    alert "Login #{status}: #{error}"
    true
  logout: (e) ->
    e.preventDefault()
    storage.clear()
    $(e.target).text "Login"
      .off "click"
      .on "click", login.serve
      .attr "alt", "Login button"
    alert "Logged out"
    true
  permissions: (user) ->
    $.ajax "{{ site.github.api_url }}/repos/{{ site.github.repository_nwo }}",
      method: "GET"
      headers: "Authorization": "token #{storage.get 'login.token'}"
      complete: (request, status) -> login.link.removeClass "disabled"
      error: (request, status, error) -> alert "Permissions #{status} #{error}"
      success: (data, status) ->
        storage.set "login.permissions", data.permissions
          .set "repository.fork", data.fork
          .set "repository.parent", data.parent?.full_name?
        role = if data.permissions.admin then "admin" else "guest"
        string = "Logged as #{user}, #{role}"
        login.link.attr "title", string
        alert string
        compare "{{ site.github.build_revision }}", data.updated_at
        true
    true
}
login.init()