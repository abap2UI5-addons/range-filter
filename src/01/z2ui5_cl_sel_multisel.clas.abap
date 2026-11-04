CLASS z2ui5_cl_sel_multisel DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.

    DATA mv_check_popup TYPE abap_bool.

    DATA ms_variant TYPE z2ui5_cl_sel_var_db=>ty_s_db.

    TYPES:
      BEGIN OF ty_s_result,
        tab_name        TYPE string,
        var_name        TYPE string,
        t_filter        TYPE z2ui5_cl_sel_context=>ty_t_filter_multi,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result     TYPE ty_s_result.
    DATA mv_popup_name TYPE string.

    TYPES:
      BEGIN OF ty_s_component,
        name             TYPE string,
        visible          TYPE abap_bool,
        check_value_help TYPE abap_bool,
      END OF ty_s_component.

    DATA mt_component TYPE STANDARD TABLE OF ty_s_component WITH DEFAULT KEY.

    CLASS-METHODS factory_by_filter
      IMPORTING
        val             TYPE z2ui5_cl_sel_context=>ty_t_filter_multi
        check_popup     TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_multisel.

    CLASS-METHODS factory_by_name
      IMPORTING
        val             TYPE clike
        s_variant       TYPE z2ui5_cl_sel_var_db=>ty_s_db OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_multisel.

    CLASS-METHODS factory_by_data
      IMPORTING
        val             TYPE any
        s_variant       TYPE z2ui5_cl_sel_var_db=>ty_s_db OPTIONAL
        check_popup     TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_multisel.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    METHODS set_output
      IMPORTING
        client TYPE REF TO z2ui5_if_client
        view   TYPE REF TO z2ui5_cl_ui5_view_builder.

    METHODS main
      IMPORTING
        client        TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS set_var_default.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_sel_multisel IMPLEMENTATION.

  METHOD factory_by_filter.
    DATA temp1 LIKE LINE OF r_result->ms_result-t_filter.
    DATA lr_filter LIKE REF TO temp1.
      DATA temp2 TYPE z2ui5_cl_sel_multisel=>ty_s_component.

    CREATE OBJECT r_result.
    r_result->mv_check_popup = check_popup.
    r_result->ms_result-t_filter = val.



    LOOP AT r_result->ms_result-t_filter REFERENCE INTO lr_filter.

      CLEAR temp2.
      temp2-name = lr_filter->name.
      temp2-visible = abap_true.
      INSERT temp2 INTO TABLE r_result->mt_component.
    ENDLOOP.

  ENDMETHOD.

  METHOD factory_by_data.

    r_result = factory_by_filter( z2ui5_cl_sel_context=>filter_get_multi_by_data( val ) ).
    r_result->mv_check_popup = check_popup.
    r_result->ms_variant = s_variant.
    r_result->set_var_default( ).

  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

  METHOD set_output.

    DATA tab TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA cells TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp3 TYPE string_table.
    DATA temp5 TYPE string_table.
    DATA temp7 TYPE string_table.
    tab = view->ele( `Table`
                    )->a( n = `items` v = client->_bind( ms_result-t_filter ) ).

    tab->ele( `headerToolbar`
        )->ele( `Toolbar`
        )->tag( `Title`
        )->a( n = `text` v = ms_result-tab_name
        )->tag( `ToolbarSpacer`
        )->tag( `Button`
        )->a( n = `text` v = `Clear`
        )->a( n = `icon` v = `sap-icon://delete`
        )->a( n = `type` v = `Transparent`
        )->a( n = `press` v = client->_event( val = `DELETE_ALL` )
        )->tag( `Button`
        )->a( n = `text` v = `Load`
        )->a( n = `icon` v = `sap-icon://download-from-cloud`
        )->a( n = `press` v = client->_event( `BUTTON_LOAD` )
        )->tag( `Button`
        )->a( n = `text` v = `Save`
        )->a( n = `icon` v = `sap-icon://save`
        )->a( n = `press` v = client->_event( `BUTTON_SAVE` ) ).

    tab->ele( `columns`
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Name`
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Options`
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Select`
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Clear`
        )->end( ).

    cells = tab->ele( `items`
                      )->ele( `ColumnListItem`
                      )->ele( `cells` ).
    cells->tag( `Text`
        )->a( n = `text` v = `{NAME}` ).

    CLEAR temp3.
    INSERT `${NAME}` INTO TABLE temp3.
    cells->ele( `MultiInput`
        )->a( n = `tokens` v = `{T_TOKEN}`
        )->a( n = `enabled` b = abap_false
        )->a( n = `valueHelpRequest` v = client->_event( val   = `LIST_OPEN`
                                                           t_arg = temp3 )
        )->ele( `tokens`
        )->tag( `Token`
        )->a( n = `key` v = `{KEY}`
        )->a( n = `text` v = `{TEXT}`
        )->a( n = `visible` v = `{VISIBLE}`
        )->a( n = `selected` v = `{SELKZ}`
        )->a( n = `editable` v = `{EDITABLE}` ).

    CLEAR temp5.
    INSERT `${NAME}` INTO TABLE temp5.
    cells->tag( `Button`
        )->a( n = `text` v = `Select`
        )->a( n = `press` v = client->_event( val   = `LIST_OPEN`
                                           t_arg = temp5 ) ).

    CLEAR temp7.
    INSERT `${NAME}` INTO TABLE temp7.
    cells->tag( `Button`
        )->a( n = `icon` v = `sap-icon://delete`
        )->a( n = `type` v = `Transparent`
        )->a( n = `text` v = `Clear`
        )->a( n = `press` v = client->_event( val   = `LIST_DELETE`
                                           t_arg = temp7 ) ).

  ENDMETHOD.

  METHOD main.
          DATA temp9 TYPE REF TO z2ui5_cl_pop_get_range.
          DATA lo_popup LIKE temp9.
            FIELD-SYMBOLS <tab> TYPE z2ui5_cl_sel_context=>ty_s_filter_multi.
          DATA temp10 TYPE REF TO z2ui5_cl_sel_var_pop_read.
          DATA ls_value TYPE z2ui5_cl_sel_var_pop_read=>ty_s_result.
          DATA temp11 TYPE REF TO z2ui5_cl_sel_var_pop_save.
        DATA ls_sql TYPE z2ui5_cl_sel_context=>ty_s_filter_multi.
        FIELD-SYMBOLS <temp1> LIKE LINE OF ms_result-t_filter.
        DATA temp2 LIKE sy-tabix.
        FIELD-SYMBOLS <ls_filter> LIKE LINE OF ms_result-t_filter.
        DATA lo_popup3 TYPE REF TO z2ui5_cl_sel_var_pop_read.
        DATA lo_popup4 TYPE REF TO z2ui5_cl_sel_var_pop_save.
        DATA temp12 LIKE LINE OF ms_result-t_filter.
        DATA lr_sql LIKE REF TO temp12.

    result = abap_true.

    IF client->check_on_navigated( ) IS NOT INITIAL.
      TRY.

          temp9 ?= client->get_app_prev( ).

          lo_popup = temp9.
          IF lo_popup->result( )-check_confirmed = abap_true.

            READ TABLE ms_result-t_filter WITH KEY name = mv_popup_name ASSIGNING <tab>.
            <tab>-t_range = lo_popup->result( )-t_range.
            <tab>-t_token = z2ui5_cl_sel_context=>filter_get_token_t_by_range_t( <tab>-t_range ).
            client->view_model_update( ).
          ENDIF.
          " handled on cancel too: the caller has to display its popup again,
          " and the range popup's BUTTON_CANCEL must not reach the caller's events
          RETURN.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

      TRY.

          temp10 ?= client->get_app_prev( ).

          ls_value = temp10->result( ).
          IF ls_value-check_confirmed = abap_true.

            z2ui5_cl_sel_context=>xml_parse( EXPORTING xml = ls_value-s_variant-data
                                      IMPORTING any = ms_result ).
            IF mv_check_popup = abap_false.
              client->view_model_update( ).
            ELSE.
              client->popup_model_update( ).
            ENDIF.

          ENDIF.
          RETURN.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

      TRY.

          temp11 ?= client->get_app_prev( ).
          temp11->result( ).
          RETURN.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDIF.

    CASE client->get( )-event.

      WHEN `LIST_OPEN`.
        mv_popup_name = client->get_event_arg( 1 ).



        temp2 = sy-tabix.
        READ TABLE ms_result-t_filter WITH KEY name = client->get_event_arg( 1 ) ASSIGNING <temp1>.
        sy-tabix = temp2.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        ls_sql = <temp1>.
        client->nav_app_call( z2ui5_cl_pop_get_range=>factory( ls_sql-t_range ) ).

      WHEN `LIST_DELETE`.
        mv_popup_name = client->get_event_arg( 1 ).
        " READ TABLE, not a table expression: the 702 downport cannot rewrite
        " CLEAR itab[ ... ]-component

        READ TABLE ms_result-t_filter ASSIGNING <ls_filter> WITH KEY name = mv_popup_name.
        IF sy-subrc = 0.
          CLEAR <ls_filter>-t_range.
          CLEAR <ls_filter>-t_token.
        ENDIF.
        IF mv_check_popup = abap_false.
          client->view_model_update( ).
        ELSE.
          client->popup_model_update( ).
        ENDIF.

      WHEN `BUTTON_LOAD`.

        lo_popup3 = z2ui5_cl_sel_var_pop_read=>factory( var_check_user = abap_true
                                                              var_handle1    = ms_variant-handle01
                                                              var_handle2    = ms_variant-handle02
                                                              var_handle3    = ms_variant-handle03 ).
        client->nav_app_call( lo_popup3 ).

      WHEN `BUTTON_SAVE`.

        lo_popup4 = z2ui5_cl_sel_var_pop_save=>factory( val            = ms_result
                                                              var_check_user = abap_true
                                                              var_handle1    = ms_variant-handle01
                                                              var_handle2    = ms_variant-handle02
                                                              var_handle3    = ms_variant-handle03 ).
        client->nav_app_call( lo_popup4 ).

      WHEN `DELETE_ALL`.


        LOOP AT ms_result-t_filter REFERENCE INTO lr_sql.
          CLEAR lr_sql->t_token.
          CLEAR lr_sql->t_range.
        ENDLOOP.
        IF mv_check_popup = abap_false.
          client->view_model_update( ).
        ELSE.
          client->popup_model_update( ).
        ENDIF.

      WHEN OTHERS.
        result = abap_false.

    ENDCASE.

  ENDMETHOD.

  METHOD factory_by_name.

    r_result = factory_by_data( val       = z2ui5_cl_sel_context=>rtti_create_tab_by_name( val )
                                s_variant = s_variant ).
    r_result->ms_result-tab_name = val.

  ENDMETHOD.

  METHOD set_var_default.

    DATA ls_default TYPE z2ui5_t_13.
    ls_default = z2ui5_cl_sel_var_db=>db_read_default( ms_variant ).

    IF ls_default-data IS NOT INITIAL.
      z2ui5_cl_sel_context=>xml_parse( EXPORTING xml = ls_default-data
                                IMPORTING any = ms_result ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
