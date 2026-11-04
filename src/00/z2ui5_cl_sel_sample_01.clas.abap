CLASS z2ui5_cl_sel_sample_01 DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA mr_table       TYPE REF TO data.
    DATA mo_multiselect TYPE REF TO z2ui5_cl_sel_multisel.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA mv_expanded TYPE abap_bool VALUE abap_true.

    METHODS on_event.
    METHODS view_display.
    METHODS set_data.
    METHODS on_init.

  PROTECTED SECTION.
    DATA mv_tabname TYPE string VALUE `T100`.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_sel_sample_01 IMPLEMENTATION.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN `BUTTON_START`.
        set_data( ).
        client->view_model_update( ).

      WHEN `BACK`.
        client->nav_app_leave( ).

    ENDCASE.

  ENDMETHOD.

  METHOD set_data.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.

    " the select-options are bound to the view, so their names come back from
    " the browser - only a field of the table goes into the WHERE clause,
    " never a condition or a subquery on another table
    DATA lt_filter LIKE mo_multiselect->ms_result-t_filter.
    DATA lt_comp TYPE abap_component_tab.
    DATA ls_filter LIKE LINE OF mo_multiselect->ms_result-t_filter.
      DATA temp1 LIKE sy-subrc.
    DATA lv_where TYPE string.
    lt_comp = z2ui5_cl_sel_context=>rtti_get_t_attri_by_table_name( mv_tabname ).

    LOOP AT mo_multiselect->ms_result-t_filter INTO ls_filter.

      READ TABLE lt_comp WITH KEY name = ls_filter-name TRANSPORTING NO FIELDS.
      temp1 = sy-subrc.
      IF temp1 = 0.
        INSERT ls_filter INTO TABLE lt_filter.
      ENDIF.
    ENDLOOP.


    lv_where = z2ui5_cl_sel_context=>filter_get_sql_where( lt_filter ).
    ASSIGN mr_table->* TO <tab>.
    " ORDER BY keeps UP TO downportable: without it the 702 downport leaves
    " the statement half rewritten
    SELECT * FROM (mv_tabname) INTO CORRESPONDING FIELDS OF TABLE <tab>
      WHERE (lv_where)
      ORDER BY PRIMARY KEY

      UP TO 100 ROWS.

  ENDMETHOD.

  METHOD view_display.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA vbox TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA lo_panel TYPE REF TO z2ui5_cl_ui5_view_builder.
    FIELD-SYMBOLS <table> TYPE data.
    DATA tab TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA lo_columns TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA lo_cells TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory(
                     )->ele( n = `View` ns = `mvc`
                     )->a( n = `xmlns` v = `sap.m`
                     )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`
                     )->a( n = `displayBlock` v = `true`
                     )->a( n = `height` v = `100%` ).

    view = view->ele( `Shell`
               )->ele( `Page`
               )->a( n = `id` v = `page_main`
               )->a( n = `title` v = `abap2UI5 - Select-Options`
               )->a( n = `navButtonPress` v = client->_event( `BACK` )
               )->a( n = `showNavButton` b = client->check_app_prev_stack( ) ).


    vbox = view->ele( `VBox` ).


    lo_panel = vbox->ele( `Panel`
                         )->a( n = `expandable` b = abap_true
                         )->a( n = `expanded` v = client->_bind_edit( mv_expanded )
                         )->a( n = `headerText` v = `Selection Screen` ).

    mo_multiselect->set_output( client = client
                                view   = lo_panel ).


    ASSIGN mr_table->* TO <table>.

    tab = vbox->ele( `Table`
                    )->a( n = `items` v = client->_bind( <table> )
                    )->ele( `headerToolbar`
                    )->ele( `OverflowToolbar`
                    )->tag( `ToolbarSpacer`
                    )->tag( `Button`
                    )->a( n = `text` v = `Go`
                    )->a( n = `press` v = client->_event( `BUTTON_START` )
                    )->a( n = `type` v = `Emphasized`
                    )->end(
                    )->end( ).


    lo_columns = tab->ele( `columns` ).
    lo_columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `SPRSL` ).
    lo_columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `ARBGB` ).
    lo_columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `MSGNR` ).
    lo_columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `TEXT` ).


    lo_cells = tab->ele( `items`
                         )->ele( `ColumnListItem` ).
    lo_cells->tag( `Text`
        )->a( n = `text` v = `{SPRSL}` ).
    lo_cells->tag( `Text`
        )->a( n = `text` v = `{ARBGB}` ).
    lo_cells->tag( `Text`
        )->a( n = `text` v = `{MSGNR}` ).
    lo_cells->tag( `Text`
        )->a( n = `text` v = `{TEXT}` ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      on_init( ).
      RETURN.
    ENDIF.

    IF mo_multiselect->main( client ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF client->get( )-event IS NOT INITIAL.
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD on_init.
    DATA temp2 TYPE z2ui5_t_13.

    mr_table = z2ui5_cl_sel_context=>rtti_create_tab_by_name( mv_tabname ).

    CLEAR temp2.
    temp2-handle01 = `TEST`.
    mo_multiselect = z2ui5_cl_sel_multisel=>factory_by_name( val       = mv_tabname
                                                             s_variant = temp2 ).

    view_display( ).

  ENDMETHOD.

ENDCLASS.
