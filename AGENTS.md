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
| `site/` | The GitHub Pages site (https://abap2ui5-addons.github.io/range-filter/), VitePress: `index.md`, `guide.md`, `which.md` (range-filter or abap-cloud-gui?), `.vitepress/` config and theme. `npm run site` builds it into `build/site`, `.github/workflows/deploy-pages.yaml` deploys it from `main`; the repository's Pages source is "GitHub Actions". The code on the pages follows the samples - change them together |
| `src/01/` | The select-options (inline and as a popup), the variant popups and their persistence, and the vendored utility copies `z2ui5_cl_sel_context` / `z2ui5_cx_sel_error` (see below) |

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

## Dependencies

- [abap2UI5](https://github.com/abap2UI5/abap2UI5) — the framework
- [layout-management](https://github.com/abap2UI5-addons/layout-management) — variant persistence

There is no version pin on any of them — abaplint resolves each from its `main`
branch. That is why the check workflows also run on a weekly schedule: a rename
upstream breaks this repository silently, and with no pull request open nothing
else would notice.

## Build and verify

```sh
npm ci
npm run check
```

`npm run check` runs exactly what CI runs. See [CONTRIBUTING.md](CONTRIBUTING.md)
for what each gate proves and how the abap2UI5-linter baseline works.

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

`npm run rename` (CI: `check-rename`) and the manual `build-rename` workflow
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
