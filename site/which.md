---
title: range-filter or abap-cloud-gui?
description: When to use range-filter and when abap-cloud-gui - two addons of abap2UI5 that both have select-options.
---

# range-filter or abap-cloud-gui?

Both addons have select-options and variants. They are built for different
apps.

**range-filter** is a building block for an abap2UI5 app you build yourself:
your own view, your own table - and a filter for it. The filter fields come
from a table or your data, at runtime; your app does the rest.

**[abap-cloud-gui](https://abap2ui5-addons.github.io/abap-cloud-gui/)** is an
app that works like a classic report: a selection screen with `PARAMETERS`,
`SELECT-OPTIONS`, radio buttons, blocks and event blocks, then a list or an
ALV - written like a report, or converted from one with report2UI5.

| Question | Use |
|---|---|
| Do I build the UI5 app myself and only need filters? | range-filter |
| Are the filter fields known only at runtime (any table)? | range-filter |
| Do I filter a table the user already sees? | range-filter, as a popup |
| Does the app work like a report (selection, then output)? | abap-cloud-gui |
| Do I need `MODIF ID`, `AT SELECTION-SCREEN`, radio buttons, F4? | abap-cloud-gui |
| Does the report exist already in SAP GUI? | abap-cloud-gui, converted with report2UI5 |

Typical for range-filter: data browsers, generic table apps, list apps with a
Filter button. Typical for abap-cloud-gui: evaluations, mass changes, admin and
tool reports - whatever is a Z report with a transaction today.

::: info Formerly selection-screen
range-filter was called `selection-screen` until it was renamed to say what it
is. GitHub forwards the old address; the ABAP objects keep their names
(`z2ui5_cl_sel_*`, table `z2ui5_t_13`), so an installation pulls on as before.
:::
