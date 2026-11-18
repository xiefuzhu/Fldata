const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const plugins = JSON.parse(fs.readFileSync(path.join(root,'.flutter-plugins-dependencies'),'utf8'));
const base = path.join(root, 'windows/flutter/ephemeral/.plugin_symlinks');
fs.mkdirSync(base,{recursive:true});
for (const plugin of plugins.plugins.windows) {
  const target = path.join(base, plugin.name);
  if (!fs.existsSync(target)) fs.symlinkSync(plugin.path, target, 'junction');
  console.log(plugin.name);
}
