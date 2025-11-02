# Synchronize global tools by uv.
let tools = open settings.yaml | get uv-tools

for $tool in $tools {
  uv tool install $tool
}
