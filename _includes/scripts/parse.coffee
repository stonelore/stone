$(".parse").each ->
  f = $(@).find "form"
  presents = JSON.parse(f.find("script[type='application/json']")[0].innerHTML)
  # Form handler
  f.on "submit", (e) ->
    api_url = "{{ site.github.api_url }}/repos/{{ site.github.repository_nwo }}/contents/_data/#{f.data "file"}.csv"
    load = f.serializeArray().map (e) -> e.name
      .join "\n"
    if load is "" then return
    if !storage.get "login.permissions.push" then return alert "You need to login with 'push' permission"
    get_content = $.ajax api_url,
      headers: "Authorization": "token #{storage.get("login.token")}"
      method: "GET"
      cache: false
    get_content.fail (request, status, error) ->
      if error == 'Not Found'
        # File not found: create
        json =
          message: "Create"
          content: btoa("NAMES\n#{load}")
        put_content = $.ajax api_url,
          headers: "Authorization": "token #{storage.get("login.token")}"
          method: "PUT"
          data: JSON.stringify json
        put_content.fail (request, status, error) ->
          alert "#{status}: #{error}"
          console.log request.getAllResponseHeaders()
        put_content.done (data, status) ->
          alert "#{status}"
          console.log data
          return
      else alert "#{status}: #{error}"
      return
    get_content.done (data, status) ->
      json =
        message: "Append"
        sha: data.sha
        content: btoa(atob(data.content) + "\n#{load}")
      put_content = $.ajax api_url,
        headers: "Authorization": "token #{storage.get("login.token")}"
        method: "PUT"
        data: JSON.stringify json
      put_content.fail (request, status, error) ->
        alert "#{status}: #{error}"
        console.log request.getAllResponseHeaders()
        return
      put_content.done (data, status) -> alert "#{status}"
      return
    return
  # Fetch page
  get_content = $.ajax "https://cors-anywhere.herokuapp.com/" + $(@).data("parse-url"),
    cache: false
  get_content.fail (request, status, error) ->
    alert "#{status}: #{error}"
    console.log request.getAllResponseHeaders()
    return
  # Fetch callback
  get_content.done (data, status) =>
    # Parse HTML
    parsed = $.parseHTML data
    # Print update
    $(@).find(".parse-update").text $($(@).data("parse-update"), parsed).text()
    # Create elements array
    elements = []
    $($(@).data("parse-get"), parsed).attr $(@).data("parse-attribute"), (i, val) -> elements.push "#{val}".split(" ")
    # Loop elements
    elements.map (e, i) =>
      line = $("<div/>")
      # Loop element
      e.map (string, j) =>
        attributes =
          type: "checkbox"
          id: "#{string}-#{i}-#{j}"
          name: string
        if string in presents
          attributes.checked = ""
          attributes.disabled = ""
        line.append $("<input/>", attributes)
          .append $("<label/>",{
            for: "#{string}-#{i}-#{j}"
            text: string
          })
        return
      # Append checkbox
      $(@).find("form .buttons").before line
      return
    return
  true