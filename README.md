[![Hex.pm Version](https://img.shields.io/hexpm/v/npm_deps.svg?color=blueviolet)](https://hex.pm/packages/npm_deps)
[![Hex docs](https://img.shields.io/badge/hex.pm-docs-blue.svg?style=flat)](https://hexdocs.pm/npm_deps)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)


# NpmDeps

<!-- MDOC !-->

### A tool to help you manage your NPM dependencies in Elixir projects without the need of Node.js or NPM in your project or in your machine.

⚠️ This project is very experimental, in early development and should be used with caution.


## Installation

The package can be installed by adding `npm_deps` to your list of dependencies in `mix.exs`.

You should also add `npm_deps` to your `project/0` in `mix.exs`.

```elixir
def project do
  [
    app: :your_app,
    version: "0.1.0",
    elixir: "~> 1.14",
    ...
    npm_deps: npm_deps()
  ]
end

def deps do
  [
    ...
    {:npm_deps, "~> 0.1.0", runtime: false}
  ]
end

def npm_deps do
  [
    {:topbar, "1.0.1"}
  ]
end
```

## Usage
Once you have added the dependency to your project, you can run `mix npm_deps.get` to get your NPM dependencies.  

The NPM dependencies will be installed in the `deps/` directory of your project, side by side with the Elixir dependencies.  

If you are using Phoenix and ESBuild, the default setup will work out of the box. Allowing you to import the NPM dependencies in your JS files.

```javascript
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "topbar";

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", info => topbar.show());
window.addEventListener("phx:page-loading-stop", info => topbar.hide());
```

<!-- MDOC !-->

## Acknowledgements
The base of this package is based on the [dart_sass](https://github.com/CargoSense/dart_sass) and [esbuild](https://github.com/phoenixframework/esbuild) packages.
