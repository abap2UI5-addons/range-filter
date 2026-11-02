---
title: Guide
description: Install range-filter and add select-options with variants to an abap2UI5 app - inline in the page or as a filter popup.
---

# Guide

range-filter is an addon of [abap2UI5](https://github.com/abap2UI5/abap2UI5)
for apps that read data on user-defined criteria. You pass a database table
name or an internal table; range-filter builds one select-option per field,
lets the user enter ranges in a popup, and saves and loads the whole selection
as a variant.

## Installation

Requirements: ABAP Cloud (S/4 Public Cloud, BTP ABAP Environment), S/4 Private
Cloud or On-Premise, or SAP NetWeaver AS ABAP 7.50 or higher.

With [abapGit](https://abapgit.org), in this order:

1. [abap2UI5](https://github.com/abap2UI5/abap2UI5)
2. [range-filter](https://github.com/abap2UI5-addons/range-filter), branch
   `main` - classes and the table `z2ui5_t_13` for the variants; nothing else
   to set up

Then run a sample like any abap2UI5 app:
`?app_start=z2ui5_cl_sel_sample_01` for select-options over table `T100`.

## Inline in your page

Select-options for every field of a database table, rendered into your own
view (condensed from `z2ui5_cl_sel_sample_01`):

```abap
" DATA mo_multiselect TYPE REF TO z2ui5_cl_sel_multisel.

METHOD z2ui5_if_app~main.

  IF client->check_on_init( ).
    mo_multiselect = z2ui5_cl_sel_multisel=>factory_by_name( val       = `T100`
                                                             s_variant = VALUE #( handle01 = `ZMY_APP` ) ).
    view_display( ).    " calls mo_multiselect->set_output( client = client view = lo_panel )
    RETURN.
  ENDIF.

  " range popups, Clear, Load and Save variant are handled here
  IF mo_multiselect->main( client ).
    RETURN.
  ENDIF.

  IF client->check_on_event( `GO` ).
    read_data( ).
    client->view_model_update( ).
  ENDIF.

ENDMETHOD.
```

![Select-options inline in the page](https://github.com/user-attachments/assets/47eb179e-c563-402d-907f-58ac77b43941)

## Reading the data

`ms_result-t_filter` holds the filter. Turn it into a dynamic `WHERE` clause:

```abap
METHOD read_data.

  " only a field of the table goes into the WHERE clause
  DATA lt_filter LIKE mo_multiselect->ms_result-t_filter.
  DATA(lt_comp) = z2ui5_cl_sel_context=>rtti_get_t_attri_by_table_name( `T100` ).
  LOOP AT mo_multiselect->ms_result-t_filter INTO DATA(ls_filter).
    IF line_exists( lt_comp[ name = ls_filter-name ] ).
      INSERT ls_filter INTO TABLE lt_filter.
    ENDIF.
  ENDLOOP.

  DATA(lv_where) = z2ui5_cl_sel_context=>filter_get_sql_where( lt_filter ).
  SELECT FROM t100 FIELDS * WHERE (lv_where) INTO TABLE @mt_t100 UP TO 100 ROWS.

ENDMETHOD.
```

::: warning Check the field names
The select-options are bound to the view, so the filter - field names
included - comes back from the browser. Before the names go into a dynamic
`WHERE`, keep only those that are fields of your table, as above: a forged
name could otherwise carry a condition or a subquery on another table.
:::

## As a filter popup

Over an internal table the user already sees (condensed from
`z2ui5_cl_sel_sample_02`):

```abap
" on init
mo_variant = z2ui5_cl_sel_multisel_pop=>factory_by_data( data        = mt_table
                                                         var_handle1 = `ZMY_APP` ).
" on the Filter button
client->nav_app_call( mo_variant ).

" back in your app
IF client->check_on_navigated( ).
  DATA(lo_filter) = CAST z2ui5_cl_sel_multisel_pop( client->get_app_prev( ) ).
  IF lo_filter->result( )-check_confirmed = abap_true.
    z2ui5_cl_sel_context=>filter_itab( EXPORTING filter = lo_filter->result( )-t_filter
                                       CHANGING  val    = mt_table ).
  ENDIF.
ENDIF.
```

![The filter popup](https://github.com/user-attachments/assets/f5c76993-9ad4-46a0-81df-2586ec2c21cf)

![Ranges of a field](https://github.com/user-attachments/assets/84c4fa61-a95a-4232-b7c1-0f9d3105e20d)

## What is there

| Class | Purpose |
|---|---|
| `z2ui5_cl_sel_multisel` | select-options for a table name (`factory_by_name`), for data (`factory_by_data`) or for a filter (`factory_by_filter`); renders into your view with `set_output( )`, handles its events in `main( )` |
| `z2ui5_cl_sel_multisel_pop` | the same as a popup app; returns the filter with `result( )` |
| `z2ui5_cl_sel_var_pop_read`, `z2ui5_cl_sel_var_pop_save` | popups to load and save a variant |
| `z2ui5_cl_sel_var_db` | variant persistence in table `z2ui5_t_13` |
| `z2ui5_cl_sel_context` | the helpers: `filter_get_sql_where( )`, `filter_itab( )`, RTTI |

## Samples

| Sample | Shows |
|---|---|
| `z2ui5_cl_sel_sample_01` | Select-options for table `T100` inline in the page, result read with a dynamic `WHERE` |
| `z2ui5_cl_sel_sample_02` | Filter popup over an internal table |
