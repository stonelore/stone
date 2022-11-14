---
parse:
  file: "stones"
  # url: "https://necrologie.messaggeroveneto.gelocal.it/"
  url: "assets/necro.html"
  get: ".item .died .picture a img"
  attribute: "alt"
  update: ".gnn-header_uptime"
---
# Stone

{% include parse.html schema=page.parse %}
