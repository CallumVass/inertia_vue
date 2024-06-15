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
