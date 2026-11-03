---
layout: home

hero:
  name: range-filter
  text: Select-options and variants for abap2UI5
  tagline: Pass a table name or your data - get one select-option per field, ranges entered in a popup, and the whole selection saved as a variant. Your app gets the filter back as a SQL WHERE clause or applies it to an internal table.
  image:
    src: /favicon.png
    alt: abap2UI5
  actions:
    - theme: brand
      text: Get started
      link: /guide
    - theme: alt
      text: range-filter or abap-cloud-gui?
      link: /which
    - theme: alt
      text: GitHub
      link: https://github.com/abap2UI5-addons/range-filter
    - theme: alt
      text: All addons
      link: https://abap2ui5-addons.github.io/

features:
  - title: Generated, not declared
    details: The fields are read via RTTI - from a database table name or an internal table. No field list to maintain; a table known only at runtime works the same way.
  - title: Inline or as a popup
    details: Render the select-options into your own page, or open them as a filter popup over a table the user already sees. Ranges are entered in a popup per field - including, excluding, patterns, intervals.
  - title: Variants built in
    details: Save and load the whole selection - per app, optionally per user, with a default variant. Kept in the table z2ui5_t_13; nothing else to set up.
  - title: The filter comes back
    details: Turn it into a dynamic WHERE clause for a SELECT, or filter an internal table with it - one call either way.
  - title: ABAP Cloud ready
    details: Released APIs only, checked with abaplint against ABAP Cloud and Standard ABAP 7.50, and with the abap2UI5 linter down to UI5 1.71.
  - title: Open source
    details: MIT licensed, installed with abapGit next to abap2UI5. Part of abap2UI5-addons - issues and pull requests welcome.
    link: https://github.com/abap2UI5-addons/range-filter
    linkText: GitHub
---
