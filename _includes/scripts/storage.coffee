###
  Store an object in `localStorage`, LZ compressed to Base 64. The key si the string {{ site.github.repository_url }}
  @example
  // Initialize storage in localStorage, called the first `get` or `set`
  storage.init()
  @example
  // Set a value for a key
  storage.set(key, value)
  @example
  // Get a key's value or whole object
  storage.get([key])
  @example
  // Remove a key value pair or clear whole object
  storage.clear([key])
  @example
  // Low level compression and storage
  storage.store(obj)
###
storage = {
  key: () ->
    return "{{ site.github.repository_nwo }}"
  init: () ->
    if !localStorage.getItem(storage.key())? then storage.store {
      "storage":
        "created": new Date()
      "repository":
        "url": "{{ site.github.repository_url }}"
        "updated": "{{ 'now' | date_to_xmlschema }}"
    }
    true
  clear: (key) ->
    obj = storage.get()
    if key?
      storage.prop key, null, obj
      storage.store obj
    else
      localStorage.removeItem storage.key()
      storage.init()
    true
  # https://stackoverflow.com/a/6394197
  set: (key, value) ->
    obj = storage.get()
    storage.prop key, value, obj
    storage.store obj
    return storage # for multiple storage
  prop: (key, value, obj) ->
    key_array = key.split "."
    final = key_array.pop()
    while k = key_array.shift()
      if !obj[k]? then obj[k] = {}
      obj = obj[k]
    return if typeof value isnt "undefined" then obj[final] = value else delete obj[final]
  get: (key) ->
    return if key?
      key.split(".").reduce (data, i) =>
        return if data?[i] then data[i] else false
      , storage.get()
    else
      JSON.parse LZString.decompressFromBase64 localStorage.getItem storage.key()
  store: (obj) ->
    localStorage.setItem storage.key(), LZString.compressToBase64 JSON.stringify obj
    return obj
}
storage.init()