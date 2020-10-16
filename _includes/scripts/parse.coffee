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
    f.find(":input").prop "disabled", true
    get_content = $.ajax api_url,
      headers: "Authorization": "token #{storage.get("login.token")}"
      method: "GET"
      cache: false
    get_content.fail (request, status, error) ->
      f.find(":input:not([checked])").prop "disabled", false
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
      put_content.done (data, status) ->
        alert "#{status}:\n#{load}"
        storage.set "parse.updated_at", f.find(".parse-update")[0].innerHTML
        return
      put_content.always -> f.find(":input:not([checked])").prop "disabled", false
      return
    return
  # Fetch page
  f.on "click", "a[start-parsing]", (e) =>
    f.find(".controls").text "Parsing..."
    get_content = $.ajax "https://afternoon-hollows-35729.herokuapp.com/" + $(@).data("parse-url"),
      cache: false
    get_content.fail (request, status, error) ->
      alert "#{status}: #{error}"
      console.log request.getAllResponseHeaders(), request.status
      return
    # Fetch callback
    get_content.done (data, status) =>
      f.find(".controls").remove()
      # Parse HTML
      parsed = $.parseHTML data
      # Print update
      updated = $($(@).data("parse-update"), parsed).text()
      if storage.get("parse.updated_at") is updated then updated += " *"
      $(@).find(".parse-update").text updated
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
    return
  true