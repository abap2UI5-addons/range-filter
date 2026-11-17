CLASS z2ui5_cl_sel_range_pop DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_filter_pop,
        option TYPE string,
        low    TYPE string,
        high   TYPE string,
        key    TYPE string,
      END OF ty_s_filter_pop.

    DATA mt_filter TYPE STANDARD TABLE OF ty_s_filter_pop WITH DEFAULT KEY.

    CLASS-METHODS factory
      IMPORTING
        t_range         TYPE ANY TABLE OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_range_pop.

    TYPES:
      BEGIN OF ty_s_result,
        t_range         TYPE z2ui5_cl_sel_context=>ty_t_range,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    " abap2ui5lint-disable-next-line unbound-public-attribute -- a popup's attributes are its interface to the app that called it, which reads them once the popup returns
    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    DATA mt_mapping TYPE z2ui5_cl_sel_context=>ty_t_name_value.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_sel_range_pop IMPLEMENTATION.

  METHOD factory.
    DATA temp20 TYPE z2ui5_cl_sel_context=>ty_s_range.

    CREATE OBJECT r_result.

    z2ui5_cl_sel_context=>itab_corresponding( EXPORTING val = t_range
                                       CHANGING  tab             = r_result->ms_result-t_range ).


    CLEAR temp20.
    INSERT temp20 INTO TABLE r_result->ms_result-t_range.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD view_display.

    DATA lo_popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA vbox TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA item TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA grid TYPE REF TO z2ui5_cl_ui5_view_builder.
    lo_popup = z2ui5_cl_ui5_view_builder=>factory(
                         )->ele( n = `FragmentDefinition` ns = `core`
                         )->a( n = `xmlns` v = `sap.m`
                         )->a( n = `xmlns:core` v = `sap.ui.core`
                         )->a( n = `xmlns:layout` v = `sap.ui.layout` ).

    lo_popup = lo_popup->ele( `Dialog`
                   )->a( n = `afterClose` v = client->_event( `BUTTON_CANCEL` )
                   )->a( n = `contentHeight` v = `50%`
                   )->a( n = `contentWidth` v = `50%`
                   )->a( n = `title` v = `Define Filter Conditions` ).


    vbox = lo_popup->ele( `VBox`
                     )->a( n = `height` v = `100%`
                     )->a( n = `justifyContent` v = `SpaceBetween` ).


    item = vbox->ele( `List`
                     )->a( n = `noDataText` v = `No conditions defined`
                     )->a( n = `items` v = client->_bind( mt_filter )
                     )->ele( `CustomListItem` ).


    grid = item->ele( n = `Grid` ns = `layout` ).

    grid->ele( `ComboBox`
        )->a( n = `selectedKey` v = `{OPTION}`
        )->a( n = `items` v = client->_bind( mt_mapping )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = `{N}`
        )->a( n = `text` v = `{N}`
        )->end(
        )->tag( `Input`
        )->a( n = `value` v = `{LOW}`
        )->a( n = `submit` v = client->_event( `BUTTON_CONFIRM` )
        )->tag( `Input`
        )->a( n = `value` v = `{HIGH}`
        )->a( n = `visible` v = `{= ${OPTION} === 'BT' }`
        )->a( n = `submit` v = client->_event( `BUTTON_CONFIRM` )
        )->tag( `Button`
        )->a( n = `icon` v = `sap-icon://decline`
        )->a( n = `type` v = `Transparent`
        )->a( n = `tooltip` v = `Delete condition`
        )->a( n = `press` v = client->_event( val   = `POPUP_DELETE`
                                                arg   = `${KEY}` ) ).

    lo_popup->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = `Delete All`
        )->a( n = `icon` v = `sap-icon://delete`
        )->a( n = `type` v = `Transparent`
        )->a( n = `press` v = client->_event( `POPUP_DELETE_ALL` )
        )->tag( `Button`
        )->a( n = `text` v = `Add Item`
        )->a( n = `icon` v = `sap-icon://add`
        )->a( n = `press` v = client->_event( `POPUP_ADD` )
        )->tag( `Button`
        )->a( n = `text` v = `Cancel`
        )->a( n = `press` v = client->_event( `BUTTON_CANCEL` )
        )->tag( `Button`
        )->a( n = `text` v = `OK`
        )->a( n = `press` v = client->_event( `BUTTON_CONFIRM` )
        )->a( n = `type` v = `Emphasized` ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
      DATA temp21 LIKE LINE OF ms_result-t_range.
      DATA lr_range LIKE REF TO temp21.
        DATA temp22 TYPE z2ui5_cl_sel_range_pop=>ty_s_filter_pop.
        DATA temp23 LIKE LINE OF mt_filter.
        DATA lr_filter LIKE REF TO temp23.
          DATA temp24 TYPE z2ui5_cl_sel_context=>ty_s_range.
        DATA temp25 TYPE z2ui5_cl_sel_range_pop=>ty_s_filter_pop.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      mt_mapping = z2ui5_cl_sel_context=>filter_get_token_range_mapping( ).

      CLEAR mt_filter.


      LOOP AT ms_result-t_range REFERENCE INTO lr_range.

        CLEAR temp22.
        temp22-low = lr_range->low.
        temp22-high = lr_range->high.
        temp22-option = lr_range->option.
        temp22-key = z2ui5_cl_sel_context=>uuid_get_c32( ).
        INSERT temp22 INTO TABLE mt_filter.
      ENDLOOP.

      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `BUTTON_CONFIRM`.

        CLEAR ms_result-t_range.


        LOOP AT mt_filter REFERENCE INTO lr_filter.
          IF lr_filter->low IS INITIAL AND lr_filter->high IS INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR temp24.
          temp24-sign = `I`.
          temp24-option = lr_filter->option.
          temp24-low = lr_filter->low.
          temp24-high = lr_filter->high.
          INSERT temp24 INTO TABLE ms_result-t_range.
        ENDLOOP.

        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `POPUP_ADD`.

        CLEAR temp25.
        temp25-key = z2ui5_cl_sel_context=>uuid_get_c32( ).
        INSERT temp25 INTO TABLE mt_filter.

      WHEN `POPUP_DELETE`.
        DELETE mt_filter WHERE key = client->get_event_arg( ).

      WHEN `POPUP_DELETE_ALL`.
        CLEAR mt_filter.

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
