CLASS z2ui5_cl_sel_var_pop_read DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_variant,
        uname   TYPE string,
        handle1 TYPE string,
        handle2 TYPE string,
        handle3 TYPE string,
      END OF ty_s_variant.

    TYPES:
      BEGIN OF ty_s_variant_out,
        s_variant  TYPE ty_s_variant,
        name       TYPE string,
        descr      TYPE string,
        selkz      TYPE abap_bool,
        check_user TYPE abap_bool,
        check_def  TYPE abap_bool,
        s_db       TYPE z2ui5_cl_sel_var_db=>ty_s_db,
        t_filter   TYPE z2ui5_cl_sel_context=>ty_t_filter_multi,
      END OF ty_s_variant_out.
    TYPES ty_t_variant_out TYPE STANDARD TABLE OF ty_s_variant_out WITH DEFAULT KEY.

    "! the variants on screen - bound to the browser, so it carries only what
    "! the list shows (s_db-name, -descr, -check_def, -uname) and the
    "! selection; the variant itself (its uuid and data) is taken from the
    "! server's own copy by the position of the selected row
    DATA mt_variant      TYPE ty_t_variant_out.

    " not used by the popup - deprecated, kept for callers that read it
    DATA ms_variant_save TYPE ty_s_variant_out.

    CLASS-METHODS factory
      IMPORTING
        var_check_user  TYPE abap_bool DEFAULT abap_true
        var_handle1     TYPE clike     DEFAULT sy-repid
        var_handle2     TYPE clike     OPTIONAL
        var_handle3     TYPE clike     OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_var_pop_read.

    TYPES:
      BEGIN OF ty_s_result,
        t_filter        TYPE z2ui5_cl_sel_context=>ty_t_filter_multi,
        s_variant       TYPE z2ui5_cl_sel_var_db=>ty_s_db,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    CLASS-METHODS read_default
      IMPORTING
        var_handle1   TYPE clike DEFAULT sy-repid
        var_handle2   TYPE clike OPTIONAL
        var_handle3   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA client        TYPE REF TO z2ui5_if_client.
    DATA ms_variant    TYPE ty_s_variant.
    DATA mt_variant_db TYPE z2ui5_cl_sel_var_db=>ty_t_db.
    DATA ms_result     TYPE ty_s_result.

    METHODS popup_variant_read.
    METHODS init.
    METHODS db_read.

  PRIVATE SECTION.
    "! the selection of a variant - the XML z2ui5_cl_sel_var_pop_save stored
    CLASS-METHODS get_filter
      IMPORTING
        s_variant     TYPE z2ui5_cl_sel_var_db=>ty_s_db
      RETURNING
        VALUE(result) TYPE z2ui5_cl_sel_context=>ty_t_filter_multi.

    METHODS on_event_confirm.

    "! the selected variant from mt_variant_db - by the position of the
    "! row the browser selected, initial without a selection
    METHODS get_selected
      RETURNING
        VALUE(result) TYPE z2ui5_cl_sel_var_db=>ty_s_db.

    "! deletes the selected variant - one of the current user only
    METHODS on_event_delete.

ENDCLASS.


CLASS z2ui5_cl_sel_var_pop_read IMPLEMENTATION.

  METHOD db_read.

    DATA temp1 TYPE z2ui5_t_13.
    DATA temp2 LIKE LINE OF mt_variant_db.
    DATA lr_var LIKE REF TO temp2.
      DATA temp3 TYPE ty_s_variant_out.
      DATA ls_var_out LIKE temp3.
    CLEAR temp1.
    temp1-uname = ms_variant-uname.
    temp1-handle01 = ms_variant-handle1.
    temp1-handle02 = ms_variant-handle2.
    temp1-handle03 = ms_variant-handle3.
    mt_variant_db = z2ui5_cl_sel_var_db=>db_read( temp1 ).

    " the list without each variant's selection XML: every row went to the
    " browser with it, writable, and CONFIRM took the variant from there
    CLEAR mt_variant.


    LOOP AT mt_variant_db REFERENCE INTO lr_var.

      CLEAR temp3.

      ls_var_out = temp3.
      ls_var_out-s_db-name      = lr_var->name.
      ls_var_out-s_db-descr     = lr_var->descr.
      ls_var_out-s_db-check_def = lr_var->check_def.
      ls_var_out-s_db-uname     = lr_var->uname.
      INSERT ls_var_out INTO TABLE mt_variant.
    ENDLOOP.

  ENDMETHOD.

  METHOD factory.
    DATA temp1 TYPE z2ui5_cl_sel_var_pop_read=>ty_s_variant-uname.

    CREATE OBJECT r_result.
    CLEAR r_result->ms_variant.

    IF var_check_user = abap_true.
      temp1 = sy-uname.
    ELSE.
      CLEAR temp1.
    ENDIF.
    r_result->ms_variant-uname = temp1.
    r_result->ms_variant-handle1 = var_handle1.
    r_result->ms_variant-handle2 = var_handle2.
    r_result->ms_variant-handle3 = var_handle3.

  ENDMETHOD.

  METHOD init.

    db_read( ).
    popup_variant_read( ).

  ENDMETHOD.

  METHOD popup_variant_read.

    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.
    popup = z2ui5_cl_ui5_view_builder=>factory(
                      )->ele( n = `FragmentDefinition` ns = `core`
                      )->a( n = `xmlns` v = `sap.m`
                      )->a( n = `xmlns:core` v = `sap.ui.core` ).


    dialog = popup->ele( `Dialog`
                       )->a( n = `title` v = `Load Variant`
                       )->a( n = `contentHeight` v = `50%`
                       )->a( n = `contentWidth` v = `50%`
                       )->a( n = `afterClose` v = client->_event( `CANCEL` ) ).

    dialog->ele( `Table`
        )->a( n = `mode` v = `SingleSelectLeft`
        )->a( n = `items` v = client->_bind( mt_variant )
        )->ele( `columns`
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Variant`
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Description`
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Default`
        )->end(
        )->end(
        )->ele( `items`
        )->ele( `ColumnListItem`
        )->a( n = `selected` v = `{SELKZ}`
        )->ele( `cells`
        )->tag( `Text`
        )->a( n = `text` v = `{S_DB/NAME}`
        )->tag( `Text`
        )->a( n = `text` v = `{S_DB/DESCR}`
        )->tag( `Text`
        )->a( n = `text` v = `{S_DB/CHECK_DEF}` ).

    dialog->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = `Cancel`
        )->a( n = `icon` v = `sap-icon://sys-cancel`
        )->a( n = `press` v = client->_event( `CANCEL` )
        )->tag( `Button`
        )->a( n = `text` v = `Delete`
        )->a( n = `icon` v = `sap-icon://delete`
        )->a( n = `press` v = client->_event( `DELETE` )
        )->tag( `Button`
        )->a( n = `text` v = `Open`
        )->a( n = `icon` v = `sap-icon://accept`
        )->a( n = `press` v = client->_event( `CONFIRM` )
        )->a( n = `type` v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      init( ).
      RETURN.
    ELSEIF client->check_on_navigated( ) IS NOT INITIAL.
      " a restored draft (browser Forward, a reload): the popup went with
      " the page - show it again
      popup_variant_read( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `CONFIRM`.
        on_event_confirm( ).

      WHEN `DELETE`.
        on_event_delete( ).

    ENDCASE.
  ENDMETHOD.

  METHOD on_event_confirm.

    DATA ls_variant TYPE z2ui5_cl_sel_var_db=>ty_s_db.
    ls_variant = get_selected( ).
    IF ls_variant IS INITIAL.
      client->message_toast_display( `Select a variant first` ).
      RETURN.
    ENDIF.
    ms_result-check_confirmed = abap_true.
    ms_result-s_variant       = ls_variant.
    " the selection of the variant as well - result( )-t_filter was empty
    ms_result-t_filter        = get_filter( ls_variant ).
    client->popup_destroy( ).
    client->nav_app_leave( ).

  ENDMETHOD.

  METHOD on_event_delete.

    DATA ls_variant TYPE z2ui5_cl_sel_var_db=>ty_s_db.
    ls_variant = get_selected( ).
    IF ls_variant IS INITIAL.
      client->message_toast_display( `Select a variant first` ).
      RETURN.
    ENDIF.

    IF ls_variant-uname IS INITIAL.
      client->message_toast_display( `A variant for all users cannot be deleted here` ).
      RETURN.
    ENDIF.

    IF z2ui5_cl_sel_var_db=>db_delete( ls_variant-uuid ) = abap_false.
      client->message_toast_display( `The variant could not be deleted` ).
      RETURN.
    ENDIF.

    " the list anew - the popup shares the model, which goes out with the
    " response
    db_read( ).

  ENDMETHOD.

  METHOD get_selected.

    DATA lv_index TYPE i.
    DATA temp2 LIKE sy-subrc.
    FIELD-SYMBOLS <ls_db> TYPE z2ui5_t_13.
    READ TABLE mt_variant WITH KEY selkz = abap_true TRANSPORTING NO FIELDS.
    temp2 = sy-tabix.
    lv_index = temp2.
    IF lv_index <= 0.
      RETURN.
    ENDIF.

    READ TABLE mt_variant_db INDEX lv_index ASSIGNING <ls_db>.
    IF <ls_db> IS ASSIGNED.
      result = <ls_db>.
    ENDIF.

  ENDMETHOD.

  METHOD get_filter.

    DATA ls_saved TYPE z2ui5_cl_sel_multisel=>ty_s_result.

    TRY.
        z2ui5_cl_sel_context=>xml_parse( EXPORTING xml = s_variant-data
                                         IMPORTING any = ls_saved ).
        result = ls_saved-t_filter.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD read_default.
        DATA temp4 TYPE z2ui5_t_13.

    TRY.

        " the default row of the user, else the shared one - db_read( ) fills
        " neither check_def nor t_filter of mt_variant, so reading the default
        " from there always came back empty

        CLEAR temp4.
        temp4-handle01 = var_handle1.
        temp4-handle02 = var_handle2.
        temp4-handle03 = var_handle3.
        result-s_variant = z2ui5_cl_sel_var_db=>db_read_default( temp4 ).
        IF result-s_variant IS INITIAL.
          RETURN.
        ENDIF.

        " the data is the selection z2ui5_cl_sel_var_pop_save stored, as XML
        result-t_filter = get_filter( result-s_variant ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
