---
---

# Includes
{% include scripts/storage.coffee %}
{% include scripts/login.coffee %}
{% include scripts/parse.coffee %}

# Get storage
console.log storage.get()

# Prevent default events on forms and links
$("body").on "submit", "form[data-prevent]", (e) -> e.preventDefault()
$("body").on "click", "a[data-prevent]", (e) -> e.preventDefault()