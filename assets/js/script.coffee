---
---

# Includes
{% include scripts/storage.coffee %}
{% include scripts/login.coffee %}
{% include scripts/parse.coffee %}

# Get storage
console.log storage.get()

# Prevent default events on forms and links
$("a[data-prevent]").on "click", (e) -> e.preventDefault()
$("form[data-prevent]").on "submit", (e) -> e.preventDefault()