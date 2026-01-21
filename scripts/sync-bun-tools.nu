# Synchronize global tools by uv.
let tools = open settings.yaml | get bun-tools

for $tool in $tools {
  bun add -g $tool
}
