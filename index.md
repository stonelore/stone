---
parse:
  file: "stones"
  url: "https://necrologie.messaggeroveneto.gelocal.it/"
  get: ".item .died .picture a img"
  attribute: "alt"
  update: ".gnn-header_uptime"
---
# Stone

{% include parse.html schema=page.parse %}