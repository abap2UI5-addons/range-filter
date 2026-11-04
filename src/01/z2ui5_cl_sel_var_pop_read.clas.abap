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

    DATA mt_variant      TYPE ty_t_variant_out.

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

    CLEAR mt_variant.


    LOOP AT mt_variant_db REFERENCE INTO lr_var.

      CLEAR temp3.

      ls_var_out = temp3.
      ls_var_out-s_db = lr_var->*.
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
        )->a( n = `items` v = client->_bind_edit( mt_variant )
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
        DATA temp4 LIKE sy-subrc.
        DATA ls_variant LIKE LINE OF mt_variant.
        FIELD-SYMBOLS <temp2> LIKE LINE OF mt_variant.
        DATA temp3 LIKE sy-tabix.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      init( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `CONFIRM`.

        READ TABLE mt_variant WITH KEY selkz = abap_true TRANSPORTING NO FIELDS.
        temp4 = sy-subrc.
        IF NOT temp4 = 0.
          client->message_toast_display( `Select a variant first` ).
          RETURN.
        ENDIF.



        temp3 = sy-tabix.
        READ TABLE mt_variant WITH KEY selkz = abap_true ASSIGNING <temp2>.
        sy-tabix = temp3.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        ls_variant = <temp2>.
        ms_result-check_confirmed = abap_true.
        ms_result-s_variant       = ls_variant-s_db.
        client->popup_destroy( ).
        client->nav_app_leave( ).

    ENDCASE.
  ENDMETHOD.

  METHOD read_default.

    DATA ls_saved TYPE z2ui5_cl_sel_multisel=>ty_s_result.
        DATA temp5 TYPE z2ui5_t_13.

    TRY.

        " the default row of the user, else the shared one - db_read( ) fills
        " neither check_def nor t_filter of mt_variant, so reading the default
        " from there always came back empty

        CLEAR temp5.
        temp5-handle01 = var_handle1.
        temp5-handle02 = var_handle2.
        temp5-handle03 = var_handle3.
        result-s_variant = z2ui5_cl_sel_var_db=>db_read_default( temp5 ).
        IF result-s_variant IS INITIAL.
          RETURN.
        ENDIF.

        " the data is the selection z2ui5_cl_sel_var_pop_save stored, as XML
        z2ui5_cl_sel_context=>xml_parse( EXPORTING xml = result-s_variant-data
                                         IMPORTING any = ls_saved ).
        result-t_filter = ls_saved-t_filter.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
