# AGENTS.md

Single source of truth for agents working on **range-filter**.

Ranges and filters with persisted variants - select-options generated from a table name or your data.

## What this repository is

A **source** repository in the abap2UI5 ecosystem: humans and agents edit here,
and CI gates every change. It is installed with abapGit and depends on the
[abap2UI5](https://github.com/abap2UI5/abap2UI5) core at runtime.

## Layout

| Path | Contents |
| --- | --- |
| `src/00/` | Samples (`z2ui5_cl_sel_sample_*`) |
| `src/01/` | The select-options (inline and as a popup), the range popup `z2ui5_cl_sel_range_pop`, the variant popups and their persistence, and the vendored utility copies `z2ui5_cl_sel_context` / `z2ui5_cx_sel_error` (see below) |
| `site/` | The GitHub Pages site (https://abap2ui5-addons.github.io/range-filter/), VitePress: `index.md`, `guide.md`, `which.md` (range-filter or abap-cloud-gui?), `.vitepress/` config and theme. `npm run site` builds it into `build/site`, `.github/workflows/deploy-pages.yaml` deploys it from `main`; the repository's Pages source is "GitHub Actions". The code on the pages follows the samples - change them together |

## The utility copy principle

`z2ui5_cl_sel_context` is a **renamed copy** of `zabaputil_cl_util_context`
from the [abap-util](https://github.com/abap-util/abap-util) master catalog,
**trimmed to the members this repository uses** (filters, ranges, RTTI, XML,
UUID) plus the private helpers, types and constants those need.
`z2ui5_cx_sel_error` is `zabaputil_cx_util_error`, renamed and copied as-is.
abapGit has no dependency management, so utilities are vendored, not referenced.

1. **Nothing from the core's frozen `src/99/01`.** `z2ui5_cl_util*` and
   `z2ui5_cx_util_error` are kept in abap2UI5 for compatibility only; every
   utility call goes through `z2ui5_cl_sel_context`, every utility exception
   is `z2ui5_cx_sel_error`.
2. **The filter types are part of the public API.** `ty_t_filter_multi` and
   `ty_s_filter_multi` of `z2ui5_cl_sel_context` appear in the signatures of the
   popups; they are built exactly like abap-util's, so another addon's own copy
   of the type (se16n) is compatible with them.
3. **New methods are added locally** to `z2ui5_cl_sel_context`; if abap-util
   already has the method, copy it from there with its private helpers.
4. **Periodic AI sync-back** merges what was added or fixed here into abap-util.
5. **Keep the copies close to the master.** `abaplint.jsonc` excludes both files
   from the style rules the master does not follow (`ambiguous_statement`,
   `max_one_statement`); do not reformat them.

`.github/abap-util.json` names the copies and their masters for abap-util's
`sync-check`: with abap-util checked out next to this repository,
`node ../abap-util/.github/scripts/sync-check.mjs --consumer . --report`
lists every method whose body or declaration differs from the master and
every method only this copy has. `commit` is the abap-util commit the copies
match: run the script without `--report` at that commit and it fails on any
difference that is not named under `settled` or `own`. After a refresh, set
`commit` to the commit the copies were taken from.

## Dependencies

- [abap2UI5](https://github.com/abap2UI5/abap2UI5) — the framework, its
  released API only (`z2ui5_if_app`, `z2ui5_if_client`,
  `z2ui5_cl_ui5_view_builder`), never its frozen `src/99`

There is no version pin on it — abaplint resolves it from its `main`
branch, named as `"branch": "main"` in `abaplint.jsonc` and
`.github/abaplint/abap_cloud.jsonc` rather than left to the default
(abap2UI5 CONVENTIONS §9). That is why `ci` also runs on a weekly schedule: a rename
upstream breaks this repository silently, and with no pull request open nothing
else would notice.

Nothing else - range-filter installs with abap2UI5 alone. The range popup
`z2ui5_cl_sel_range_pop` is a renamed copy of
[popups](https://github.com/abap2UI5-addons/popups)' `z2ui5_cl_popup_get_range`
(on `z2ui5_cl_sel_context` instead of `z2ui5_cl_popup_context`), not a
reference to it: popups pulls layout-management and that one abap2UI5-ext, a
chain abapGit cannot resolve for the user. It replaced the core's frozen
`z2ui5_cl_pop_get_range` (`src/99/02`), which goes when the core drops
`src/99`. A fix to one of the two popups belongs in the other as well.
Its test class came along unchanged: its roundtrip tests drive the popup
through the core's internals (`z2ui5_cl_ui5_handler`, `_action`, `_client`)
as the core's own app tests do; they run in a system and in `npm run unit`
(`.github/scripts/unit.mjs`: the package copied into a checkout of
abap2UI5's `main`, downported, transpiled, the tests of `Z2UI5_CL_SEL*` run
on the Node runtime), and when a core refactor turns `npm run lint` red
there, follow what the core's tests and popups' copy did.

## Build and verify

```sh
npm ci
npm run check
```

`npm run check` runs the lint, linter and rename gates of CI; the ABAP Unit
tests run separately with `npm run unit` (a few minutes: it builds abap2UI5's
transpiled runtime). See [CONTRIBUTING.md](CONTRIBUTING.md) for what each gate
proves and how the abap2UI5-linter baseline works.

CI comes from the shared CI template of abap2UI5-addons (reusable workflows in
[rap-ext](https://github.com/abap2UI5-addons/rap-ext/blob/main/.github/ci/README.md),
pinned by commit, moved by `bump-deps`): `ci` (abaplint Standard and Cloud,
unit, rename, the abap2UI5-linter and `npm run check:702` - one job each),
`ci-702` (writes and lints the downported branch `702`), `build-rename`,
`deploy-pages`, `bump-deps`. `npm run check:702` is the 7.02 gate of a pull
request: `.github/scripts/check-702.sh` downports a scratch copy of `src/` in
`build/702` and lints it with `.github/abaplint/abap_702.jsonc` (`src/` itself
is never rewritten).

## Views

Views are built with **`z2ui5_cl_ui5_view_builder`**, the core's generic builder
in `src/02`: `ele` (add a child and descend), `tag` (add a child and stay), `a`
(set an attribute on the element the chain points at), `end` (ascend),
`stringify` (render from the root).

Three rules that are easy to get wrong:

1. **`a( )` targets the last child** once a node has children, so a control's
   attributes belong immediately after the `ele( )`/`tag( )` that opened it.
2. **An ABAP boolean goes into `b =`.** Through `v =` an `abap_false` renders as
   an empty string, and UI5 reads an empty string as true.
3. **The root declares its own namespaces.** The frozen builder collected them
   and wrote the `xmlns` attributes itself; this one does not, and a prefix that
   is used but not declared makes the whole view fail to parse — a blank screen,
   not a bad layout. An aggregation tag takes the namespace of *its own control*:
   under `<form:SimpleForm>` it is `<form:content>`, never `<content>`.

The frozen `z2ui5_cl_xml_view` is gone from here and must not come back. It sits
in the core's `src/99`, outside the released API, and the view gate can read
nothing built with it.

## Conventions

- ABAP classes are named ``z2ui5_cl_sel_*``; the variant table keeps its old name
  `z2ui5_t_13` (it holds data - a rename would drop it on every installation).
  No check enforces the prefix: `allowed_object_naming` in `abaplint.jsonc` only
  checks length and characters, and `npm run rename` only proves
  that every `z2ui5_*` object still renames cleanly. Keep to it in review.
- English for code, comments, commit messages, pull requests and issues.
- All text files are LF-only (`.gitattributes`).
- The ecosystem-wide rules — workflow and npm-script naming, toolchain versions,
  which documentation files exist, commit style — live in
  [CONVENTIONS.md](https://github.com/abap2UI5/abap2UI5/blob/main/.github/shared/CONVENTIONS.md)
  and bind this repository too.

## Namespace rename

`npm run rename` (CI: the `rename` job of `ci`) and the manual `build-rename` workflow
are abap2UI5's namespace rename for this addon - `.github/scripts/rename.mjs`,
the same file in every addon that has one. Every `z2ui5_` object becomes
`<name>_...`, for a customer name such as `ZMYUI5` or a registered namespace
such as `/CA2UI5/` (at most 10 characters), and so does every reference to
abap2UI5 and to the addons this one builds on: the branch `rename_<name>` runs
on an abap2UI5 renamed with the same name by its own `build-rename`. What
follows from it:

- Every object name has at most 25 characters (a transparent table
  11, an ICF node 10) - 30 minus what the longest new name adds.
- No literal names a `z2ui5_` object: the rename rewrites references, never a
  literal. Derive the name - from a typed reference, or behind the prefix of
  the class's own name.
- A change that spans several repositories: `RENAME_DEPS_FROM=<dir> npm run
  rename` takes the dependencies from the clones in `<dir>`.
