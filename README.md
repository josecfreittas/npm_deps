[![Hex.pm Version](https://img.shields.io/hexpm/v/npm_deps.svg?color=blueviolet)](https://hex.pm/packages/npm_deps)
[![Hex docs](https://img.shields.io/badge/hex.pm-docs-blue.svg?style=flat)](https://hexdocs.pm/npm_deps)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)


# NpmDeps

<!-- MDOC !-->

### A tool to help you manage your NPM dependencies in Elixir projects without the need of Node.js or NPM in your environment.


## Setup

The package can be installed by adding `npm_deps` to your list of dependencies in `mix.exs`. And you should also add the `npm_deps` to your `project/0`, pointing to a list with your desired NPM dependencies.

```diff
  def project do
    [
      app: :your_app,
      version: "0.1.0",
      elixir: "~> 1.14",
      ...
+     npm_deps: npm_deps()
    ]
  end

  def deps do
    [
      ...
+     {:npm_deps, "~> 0.3.1", runtime: false}
    ]
  end

+ def npm_deps do
+   [
+     {:alpinejs, "3.11.1"},
+     {:topbar, "2.0.1"},
+     {"decimal.js", "10.4.3"}
+   ]
+ end
```

> ℹ️ Alpine.js, Topbar and decimal.js are used in the example above, but you can use any NPM package you want.

> ℹ️ NpmDeps will not fetch the sub-dependencies of the packages, so you will need to add them explicitly to your `npm_deps/0` function if you need them.

> ℹ️ Post-install scripts are not supported.

Once you have added it, you can run `mix npm_deps.get` to get your NPM dependencies.  

The NPM dependencies will be installed in the `deps/` directory of your project, side by side with the Elixir dependencies.  

If you are using Phoenix and ESBuild, the default setup will work out of the box. Allowing you to import the NPM dependencies in your JS files.

```javascript
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "topbar";
import Alpine from "alpinejs";

window.Alpine = Alpine;
Alpine.start();

...
```

To run `npm_deps.get` in your deployment pipeline, you can add it to your `assets.deploy` task, also in `mix.exs`.

```diff
  defp aliases do
    [
      ...
      "assets.deploy": [
+       "npm_deps.get",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
```

You can also add an alias to run `npm_deps.get` alongside `deps.get`:
```diff
  defp aliases do
    [
      ...
+     "deps.get": ["npm_deps.get", "deps.get"]
    ]
  end
```

<!-- MDOC !-->

## Acknowledgements
The base of this package is based on the [dart_sass](https://github.com/CargoSense/dart_sass) and [esbuild](https://github.com/phoenixframework/esbuild) packages.
