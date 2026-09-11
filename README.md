# bitcr_ui

Shared Flutter UI for the Bitcredit apps — wallet, dashboard and (later) ebills.

```
packages/bitcr_ui/   the library: design tokens + components. This is what apps depend on.
widgetbook/          the component catalog. A dev tool; never shipped.
```

The catalog is a separate package on purpose: `widgetbook`, `widgetbook_generator`
and `build_runner` stay out of the library's dependency graph, so consuming apps
never pull them in.

## How the library is laid out

```
lib/src/theme/        the design tokens
lib/src/core/         primitives with no domain knowledge — usable by any app
lib/src/navigation/   screen chrome: topbar, headers, back button, pagers
lib/src/overlays/     drawers, sheets and overlay menus
lib/src/patterns/     composed, Bitcredit-specific pieces (QR, recovery phrase, …)
```

Two rules keep components reusable across the wallet, dashboard and ebills:

- **No app state.** Nothing in here reads a provider or a router — values come
  in as parameters, changes go out as callbacks. A component that needs to know
  the selected wallet takes it as an argument.
- **No copy.** All strings are parameters, so translations stay in the app.
  Same reason illustrations do (see below).

Icons are the exception to "no dependencies": `lucide_icons_flutter` is a
dependency and is re-exported from `lib/bitcr_ui.dart`, so all three apps draw
from one pinned icon set. A component bakes its icon in when the icon *is* the
component (the back button's chevron); anything that varies per call site takes
an `IconData`.

## Working on a component

```bash
cd widgetbook
dart run build_runner watch          # regenerates main.directories.g.dart as you add @UseCase
flutter run -d chrome                # or -d linux
```

Hot reload covers edits to both the catalog and `packages/bitcr_ui` — only
*adding* or *renaming* a use case needs the generator to re-run, and `watch`
handles that.

`-d chrome` looks for a binary named `google-chrome` on `PATH` and nothing else,
so on a machine with Chromium or Brave instead, give it that name:

```bash
ln -sfn /usr/bin/brave-browser ~/.local/bin/google-chrome
```

`CHROME_EXECUTABLE=/usr/bin/brave-browser` does the same job, but only where the
variable is exported — an IDE run configuration or a script won't see it if it
lives in an interactive-only `.bashrc`, so the symlink is the fewer-surprises
option.

Prefer a deb-packaged browser over snap Chromium either way: snap confinement
can't read the profile directory Flutter creates under `/tmp`, so the debug
connection never comes up. `-d linux` needs none of this.

A one-off build instead of watching:

```bash
dart run build_runner build
```

## Adding a component

1. Put the widget in the matching folder under `packages/bitcr_ui/lib/src/`,
   export it from `lib/bitcr_ui.dart`.
2. Add `widgetbook/lib/use_cases/<component>_use_cases.dart` with one
   `@UseCase` per state worth reviewing, plus a knobbed `Playground` use case
   if the component has interesting edges. See
   `use_cases/empty_state_use_cases.dart` for the shape.

The navigation tree is derived from where the component lives in the library,
not from where the use case lives — so `src/components/empty_state.dart` shows
up under a `components` folder in the catalog.

## Design tokens

| | |
|---|---|
| `BitcrColors` | color tokens, registered as a `ThemeExtension`; read with `BitcrColors.of(context)` |
| `BitcrTextStyles` | the type scale; read with `context.bitcrText.textLgMedium()` |
| `BitcrRadius` | the corner-radius scale |
| `BitcrTheme` | `ThemeData` with the above wired up — `BitcrTheme.light` / `.dark` |

The Geist font ships inside `packages/bitcr_ui/fonts/`, so all three apps get
identical typography without their own copies. `BitcrTheme` addresses it as
`packages/bitcr_ui/Geist`.

## Consuming it from an app

While iterating locally, point straight at the checkout:

```yaml
dependency_overrides:
  bitcr_ui:
    path: ../ui-flutter/packages/bitcr_ui
```

Otherwise pin a tag:

```yaml
dependencies:
  bitcr_ui:
    git:
      url: git@github.com:BitcreditProtocol/ui-flutter.git
      path: packages/bitcr_ui
      ref: v0.1.0
```

Then in the app:

```dart
MaterialApp(
  theme: BitcrTheme.light,
  darkTheme: BitcrTheme.dark,
  // ...
)
```

Illustrations stay app-owned: components like `EmptyState` take an asset path
and resolve it against the host app's bundle. Pass `assetPackage: 'bitcr_ui'`
only for artwork that ships inside the library.

## Continuous integration

Pull requests and pushes to `main` run [Flutter CI](.github/workflows/ci.yml)
on the stable Flutter channel. It analyzes both packages, runs the library's
tests, checks that generated catalog entries are current, and builds the web
catalog. The catalog uses its committed lockfile. The workflow only validates;
it does not publish the library or deploy the catalog.

[Dependabot](.github/dependabot.yml) checks both Dart packages on Mondays at
08:30 Europe/Vienna, grouping patch and minor updates. Major updates remain
separate. GitHub Actions updates are grouped monthly, on the first day at the
same time. Assignments follow the [organization registry](https://github.com/BitcreditProtocol/.github/blob/master/dependabot-assignees.yml).

## License

Bitcredit code is covered by the [MIT license](LICENSE). The bundled Geist
fonts retain the SIL Open Font License 1.1. The [package license](packages/bitcr_ui/LICENSE)
includes both notices so consumers receive the font license with the library.
The font notice comes from [Geist's upstream license](https://github.com/vercel/geist-font/blob/10dc7658f13c38a474cde201bb09a4617267545b/OFL.txt).
