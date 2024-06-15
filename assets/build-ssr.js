const esbuild = require("esbuild");
const vuePlugin = require("esbuild-plugin-vue3");

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
};

const plugins = [
  // Add and configure plugins here
  vuePlugin(),
];

// Define esbuild options
let opts = {
  entryPoints: ["js/ssr.js"],
  bundle: true,
  logLevel: "info",
  platform: "node",
  format: "cjs",
  outdir: "../priv",
  nodePaths: ["../deps"],
  loader: loader,
  plugins: plugins,
};

if (deploy) {
  opts = {
    ...opts,
    minify: true,
  };
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: "inline",
  };
  esbuild
    .context(opts)
    .then((ctx) => {
      ctx.watch();
    })
    .catch((_error) => {
      process.exit(1);
    });
} else {
  esbuild.build(opts);
}
