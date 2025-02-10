---
parse:
  file: "stones"
  # url: "https://necrologie.messaggeroveneto.gelocal.it/"
  url: "assets/necro.html"
  # get: ".item .died .picture a img"
  get: ".self-stretch.text-center > a[href*='/necrologi/20']"
  attribute: "alt"
  update: ".gnn-header_uptime"
---
# Stone

{% include parse.html schema=page.parse %}

- [workflows/fetch_html]({{ site.github.repository_url }}/blob/{{ site.github.public_repositories | where: "html_url", site.github.repository_url | first | map: "default_branch" | first }}/.github/workflows/fetch_html.yml)
- [assets/necro.html]({{ site.github.repository_url }}/blob/{{ site.github.public_repositories | where: "html_url", site.github.repository_url | first | map: "default_branch" | first }}/assets/necro.html)
- [necrologie.messaggeroveneto](https://necrologie.messaggeroveneto.gelocal.it)
