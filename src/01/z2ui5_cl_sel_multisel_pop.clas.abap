CLASS z2ui5_cl_sel_multisel_pop DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA mo_multiselect TYPE REF TO z2ui5_cl_sel_multisel.

    CLASS-METHODS factory_by_data
      IMPORTING
        data            TYPE any
        check_db_active TYPE abap_bool DEFAULT abap_true
        var_check_user  TYPE abap_bool DEFAULT abap_true
        var_handle1     TYPE clike     DEFAULT sy-repid
        var_handle2     TYPE clike     OPTIONAL
        var_handle3     TYPE clike     OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_multisel_pop.

    TYPES:
      BEGIN OF ty_s_result,
        t_filter        TYPE z2ui5_cl_sel_context=>ty_t_filter_multi,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA client     TYPE REF TO z2ui5_if_client.
    DATA ms_variant TYPE z2ui5_cl_sel_var_db=>ty_s_db.
    DATA ms_result  TYPE ty_s_result.

    METHODS popup_display.

    METHODS init.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_sel_multisel_pop IMPLEMENTATION.

  METHOD factory_by_data.
    DATA temp1 LIKE r_result->ms_variant-uname.

    CREATE OBJECT r_result.

    CLEAR r_result->ms_variant.

    IF var_check_user = abap_true.
      temp1 = sy-uname.
    ELSE.
      CLEAR temp1.
    ENDIF.
    r_result->ms_variant-uname = temp1.
    r_result->ms_variant-handle01 = var_handle1.
    r_result->ms_variant-handle02 = var_handle2.
    r_result->ms_variant-handle03 = var_handle3.

    r_result->mo_multiselect = z2ui5_cl_sel_multisel=>factory_by_data( val         = data
                                                                       s_variant   = r_result->ms_variant
                                                                       check_popup = abap_true ).

  ENDMETHOD.

  METHOD init.

    popup_display( ).

  ENDMETHOD.

  METHOD popup_display.

    DATA lo_popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    lo_popup = z2ui5_cl_ui5_view_builder=>factory(
                         )->ele( n = `FragmentDefinition` ns = `core`
                         )->a( n = `xmlns` v = `sap.m`
                         )->a( n = `xmlns:core` v = `sap.ui.core` ).
    lo_popup = lo_popup->ele( `Dialog`
                   )->a( n = `afterClose` v = client->_event( `BUTTON_CANCEL` )
                   )->a( n = `contentHeight` v = `50%`
                   )->a( n = `contentWidth` v = `50%`
                   )->a( n = `title` v = `Define Filter Conditions` ).

    mo_multiselect->set_output( client = client
                                view   = lo_popup ).

    lo_popup->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = `Cancel`
        )->a( n = `icon` v = `sap-icon://sys-cancel`
        )->a( n = `press` v = client->_event( `BUTTON_CANCEL` )
        )->tag( `Button`
        )->a( n = `text` v = `OK`
        )->a( n = `press` v = client->_event( `BUTTON_CONFIRM` )
        )->a( n = `type` v = `Emphasized` ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      init( ).
      RETURN.
    ENDIF.

    IF mo_multiselect->main( client ) IS NOT INITIAL.
      IF client->get( )-check_on_navigated = abap_true.
        popup_display( ).
      ENDIF.
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `BUTTON_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        ms_result-t_filter = mo_multiselect->ms_result-t_filter.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
