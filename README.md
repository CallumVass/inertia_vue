# Inertia.js with Phoenix and Vue 3 Setup

This project contains a sample project and guide that walks you through setting up a new Phoenix project with Inertia.js and Vue 3, using SQLite3 for the database, without LiveView and esbuild with SSR.

You can view this application at: https://inertia-vue.fly.dev/

## Create a New Phoenix Project

```sh
mix phx.new inertia_vue --database sqlite3 --no-live --no-esbuild
```

## Follow the Inertia Phoenix README

Follow the instructions in the Inertia Phoenix README to set up the base project (https://github.com/inertiajs/inertia-phoenix). Once done, make the following changes:

### Install Dependencies

Change directory to the `assets` folder and install the necessary dependencies:

```sh
cd assets
npm i -D esbuild esbuild-plugin-vue3
npm i @inertiajs/vue3 ../deps/phoenix ../deps/phoenix_html ../deps/phoenix_live_view @vue/server-renderer
```

### Create `assets/js/app.js`

```js
import "phoenix_html";
import { createSSRApp, h } from "vue";
import { createInertiaApp } from "@inertiajs/vue3";
import axios from "axios";
axios.defaults.xsrfHeaderName = "x-csrf-token";

createInertiaApp({
  resolve: async (name) => {
    const page = await import(`./Pages/${name}.vue`);
    return page;
  },
  setup({ el, App, props, plugin }) {
    createSSRApp({ render: () => h(App, props) })
      .use(plugin)
      .mount(el);
  },
});
```

### Create `assets/js/ssr.js`

```js
import { createInertiaApp } from "@inertiajs/vue3";
import { renderToString } from "@vue/server-renderer";
import { createSSRApp, h } from "vue";

export function render(page) {
  return createInertiaApp({
    page,
    render: renderToString,
    resolve: async (name) => {
      const page = await import(`./Pages/${name}.vue`);
      return page;
    },
    setup({ App, props, plugin }) {
      return createSSRApp({
        render: () => h(App, props),
      }).use(plugin);
    },
  });
}
```

### Create `assets/build.js`

```js
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
  entryPoints: ["js/app.js"],
  bundle: true,
  logLevel: "info",
  target: "es2020",
  outdir: "../priv/static/assets",
  external: ["*.css", "fonts/*", "images/*"],
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
```

### Create `assets/build-ssr.js`

```js
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
```

### Adjust `tailwind.config.js`

Add `"./js/**/*.vue",` to the `content` array in `tailwind.config.js`:

```js
module.exports = {
  content: [
    "./js/**/*.vue",
    // other paths
  ],
  // other config
};
```

### Update `config/config.exs`

```elixir
config :inertia,
  endpoint: InertiaVueWeb.Endpoint,
  static_paths: ["/assets/app.js"],
  default_version: "1",
  ssr: true,
  raise_on_ssr_failure: true
```

### Update `application.ex`

Add this to your registry in the `start` function in your `application.ex` file:

```elixir
{Inertia.SSR, path: Path.join([Application.app_dir(:inertia_vue), "priv"])}
```

### Update `config/dev.exs`

Add the following to the `watchers` under `config/dev.exs`:

```elixir
node: ["build.js", "--watch", cd: Path.expand("../assets", __DIR__)]
node: ["build-ssr.js", "--watch", cd: Path.expand("../assets", __DIR__)]
```

### Update `mix.exs`

Adjust `assets.setup` under `aliases` in `mix.exs`:

```elixir
"assets.setup": ["tailwind.install --if-missing", "cmd --cd assets npm install"]
```

Adjust `assets.deploy` under `aliases` in `mix.exs`:

```elixir
"assets.deploy": [
  "tailwind default --minify",
  "cmd --cd assets node build.js --deploy",
  "cmd --cd assets node build-ssr.js --deploy",
  "phx.digest"
]
```

### Create `Home.vue`

Create `Home.vue` under `assets/js/Pages/Home.vue`:

```ts
<script setup lang="ts">
import { Head } from "@inertiajs/vue3";

defineProps<{
  name: string;
}>();
</script>

<template>
  <Head title="Welcome to Inertia" />
  <h1 class="text-4xl">Welcome</h1>
  <p>Hello {{ name }}, welcome to your first Inertia app!</p>
</template>
```

### Clean Up Controllers (if you only plan on rendering inertia pages)

Delete the `pages_html` directory and `page_html.ex` file under the `controllers` directory in your `lib` web folder.

### Update `page_controller.ex`

```elixir
def home(conn, _params) do
  conn
  |> assign_prop(:name, "My Name (from Server)")
  |> render_inertia("Home")
end
```

This documentation provides a clear and structured guide for setting up Inertia.js with Phoenix and Vue 3, including the necessary steps and configurations.

#### Disclaimer

If I have missed anything, please feel free to reach out or create an issue.
