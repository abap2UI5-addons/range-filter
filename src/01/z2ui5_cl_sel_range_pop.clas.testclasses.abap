
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory_empty       FOR TESTING RAISING cx_static_check.
    METHODS test_factory_w_range     FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial      FOR TESTING RAISING cx_static_check.
    METHODS test_factory_range_count FOR TESTING RAISING cx_static_check.
    METHODS test_factory_empty_row   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_multi_range FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory_empty.

    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    lo_pop = z2ui5_cl_sel_range_pop=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_w_range.

    DATA temp1 TYPE z2ui5_cl_sel_context=>ty_t_range.
    DATA temp2 LIKE LINE OF temp1.
    DATA lt_range LIKE temp1.
    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    DATA ls_result TYPE z2ui5_cl_sel_range_pop=>ty_s_result.
    CLEAR temp1.

    temp2-sign = `I`.
    temp2-option = `EQ`.
    temp2-low = `100`.
    INSERT temp2 INTO TABLE temp1.

    lt_range = temp1.


    lo_pop = z2ui5_cl_sel_range_pop=>factory( lt_range ).

    ls_result = lo_pop->result( ).

    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-t_range ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    DATA ls_result TYPE z2ui5_cl_sel_range_pop=>ty_s_result.
    lo_pop = z2ui5_cl_sel_range_pop=>factory( ).

    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_range_count.

    DATA temp3 TYPE z2ui5_cl_sel_context=>ty_t_range.
    DATA temp4 LIKE LINE OF temp3.
    DATA lt_range LIKE temp3.
    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    DATA ls_result TYPE z2ui5_cl_sel_range_pop=>ty_s_result.
    CLEAR temp3.

    CLEAR temp4.
    temp4-sign = `I`.
    temp4-option = `EQ`.
    temp4-low = `100`.
    INSERT temp4 INTO TABLE temp3.
    CLEAR temp4.
    temp4-sign = `I`.
    temp4-option = `BT`.
    temp4-low = `200`.
    temp4-high = `300`.
    INSERT temp4 INTO TABLE temp3.

    lt_range = temp3.


    lo_pop = z2ui5_cl_sel_range_pop=>factory( lt_range ).

    ls_result = lo_pop->result( ).

    " factory appends one empty row to the range for new entries
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_empty_row.

    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    DATA ls_result TYPE z2ui5_cl_sel_range_pop=>ty_s_result.
    lo_pop = z2ui5_cl_sel_range_pop=>factory( ).

    ls_result = lo_pop->result( ).

    " factory always inserts one empty row even for empty input
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_multi_range.

    DATA temp5 TYPE z2ui5_cl_sel_context=>ty_t_range.
    DATA temp6 LIKE LINE OF temp5.
    DATA lt_range LIKE temp5.
    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    DATA ls_result TYPE z2ui5_cl_sel_range_pop=>ty_s_result.
    CLEAR temp5.

    temp6-sign = `I`.
    temp6-option = `EQ`.
    temp6-low = `A`.
    INSERT temp6 INTO TABLE temp5.
    temp6-sign = `E`.
    temp6-option = `EQ`.
    temp6-low = `B`.
    INSERT temp6 INTO TABLE temp5.
    temp6-sign = `I`.
    temp6-option = `GE`.
    temp6-low = `C`.
    INSERT temp6 INTO TABLE temp5.

    lt_range = temp5.


    lo_pop = z2ui5_cl_sel_range_pop=>factory( lt_range ).

    ls_result = lo_pop->result( ).

    " 3 input rows + 1 empty row appended by factory
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    " what the roundtrip queued for the frontend, read off the response
    METHODS popup_xml
      RETURNING
        VALUE(result) TYPE string.
    METHODS popup_destroyed
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS popup_create
      IMPORTING
        it_range      TYPE z2ui5_cl_sel_context=>ty_t_range OPTIONAL
      RETURNING
        VALUE(ro_pop) TYPE REF TO z2ui5_cl_sel_range_pop.

    METHODS test_init_displays_popup FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_builds_range FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_skips_empty FOR TESTING RAISING cx_static_check.
    METHODS test_add_row             FOR TESTING RAISING cx_static_check.
    METHODS test_delete_row          FOR TESTING RAISING cx_static_check.
    METHODS test_cancel              FOR TESTING RAISING cx_static_check.
    METHODS test_roundtrip_keeps_sign FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_empty_value FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD popup_create.
    DATA temp1 TYPE REF TO z2ui5_cl_ui5_handler.

    ro_pop = z2ui5_cl_sel_range_pop=>factory( it_range ).

    CREATE OBJECT temp1 TYPE z2ui5_cl_ui5_handler EXPORTING VAL = ``.
    CREATE OBJECT mo_action EXPORTING VAL = temp1.
    mo_action->mo_app->mo_app = ro_pop.
    CREATE OBJECT mi_client TYPE z2ui5_cl_ui5_client EXPORTING ACTION = mo_action.

    " first roundtrip builds mt_filter and renders the dialog
    ro_pop->z2ui5_if_app~main( mi_client ).
    mo_action->mo_app->mv_check_initialized = abap_true.

  ENDMETHOD.

  METHOD test_init_displays_popup.

    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    lo_pop = popup_create( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_pop->mt_filter ) ).
    cl_abap_unit_assert=>assert_not_initial( popup_xml( ) ).

  ENDMETHOD.

  METHOD test_confirm_builds_range.

    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lo_pop->mt_filter.
    DATA temp8 LIKE sy-tabix.
    FIELD-SYMBOLS <temp9> LIKE LINE OF lo_pop->mt_filter.
    DATA temp10 LIKE sy-tabix.
    DATA ls_result TYPE z2ui5_cl_sel_range_pop=>ty_s_result.
    FIELD-SYMBOLS <temp11> LIKE LINE OF ls_result-t_range.
    DATA temp12 LIKE sy-tabix.
    FIELD-SYMBOLS <temp13> LIKE LINE OF ls_result-t_range.
    DATA temp14 LIKE sy-tabix.
    FIELD-SYMBOLS <temp15> LIKE LINE OF ls_result-t_range.
    DATA temp16 LIKE sy-tabix.
    lo_pop = popup_create( ).


    temp8 = sy-tabix.
    READ TABLE lo_pop->mt_filter INDEX 1 ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp7>-option = `EQ`.


    temp10 = sy-tabix.
    READ TABLE lo_pop->mt_filter INDEX 1 ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp9>-low    = `ABC`.

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).


    ls_result = lo_pop->result( ).
    cl_abap_unit_assert=>assert_true( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).


    temp12 = sy-tabix.
    READ TABLE ls_result-t_range INDEX 1 ASSIGNING <temp11>.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `I`
                                        act = <temp11>-sign ).


    temp14 = sy-tabix.
    READ TABLE ls_result-t_range INDEX 1 ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `EQ`
                                        act = <temp13>-option ).


    temp16 = sy-tabix.
    READ TABLE ls_result-t_range INDEX 1 ASSIGNING <temp15>.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = <temp15>-low ).
    cl_abap_unit_assert=>assert_true( popup_destroyed( ) ).

  ENDMETHOD.

  METHOD test_confirm_skips_empty.

    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    lo_pop = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->result( )-t_range ).
    cl_abap_unit_assert=>assert_true( lo_pop->result( )-check_confirmed ).

  ENDMETHOD.

  METHOD test_add_row.

    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    lo_pop = popup_create( ).

    mo_action->ms_actual-event = `POPUP_ADD`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_filter ) ).

  ENDMETHOD.

  METHOD test_delete_row.

    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    DATA lv_key TYPE z2ui5_cl_sel_range_pop=>ty_s_filter_pop-key.
    FIELD-SYMBOLS <temp2> LIKE LINE OF lo_pop->mt_filter.
    DATA temp3 LIKE sy-tabix.
    DATA temp17 TYPE string_table.
    lo_pop = popup_create( ).



    temp3 = sy-tabix.
    READ TABLE lo_pop->mt_filter INDEX 1 ASSIGNING <temp2>.
    sy-tabix = temp3.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_key = <temp2>-key.

    mo_action->ms_actual-event = `POPUP_DELETE`.

    CLEAR temp17.
    INSERT lv_key INTO TABLE temp17.
    mo_action->ms_actual-t_event_arg = temp17.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->mt_filter ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    lo_pop = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CANCEL`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( popup_destroyed( ) ).

  ENDMETHOD.

  METHOD test_roundtrip_keeps_sign.

    " an excluding row comes back excluding - and with an option and a value
    DATA temp19 TYPE z2ui5_cl_sel_context=>ty_t_range.
    DATA temp20 LIKE LINE OF temp19.
    DATA lt_range LIKE temp19.
    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    FIELD-SYMBOLS <temp21> LIKE LINE OF lo_pop->mt_filter.
    DATA temp22 LIKE sy-tabix.
    CLEAR temp19.

    CLEAR temp20.
    temp20-sign = `I`.
    temp20-option = `EQ`.
    temp20-low = `A`.
    INSERT temp20 INTO TABLE temp19.
    CLEAR temp20.
    temp20-sign = `E`.
    temp20-option = `EQ`.
    temp20-low = `B`.
    INSERT temp20 INTO TABLE temp19.
    CLEAR temp20.
    temp20-sign = `E`.
    temp20-option = `BT`.
    temp20-low = `C`.
    temp20-high = `D`.
    INSERT temp20 INTO TABLE temp19.

    lt_range = temp19.


    lo_pop = popup_create( lt_range ).


    temp22 = sy-tabix.
    READ TABLE lo_pop->mt_filter INDEX 2 ASSIGNING <temp21>.
    sy-tabix = temp22.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = <temp21>-sign ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    " the empty row factory( ) appends is left out
    cl_abap_unit_assert=>assert_equals( exp = lt_range
                                        act = lo_pop->result( )-t_range ).

  ENDMETHOD.

  METHOD test_confirm_empty_value.

    " <leer> and !<leer> are no options of a range - the empty value is
    " EQ or NE an empty LOW, and kept although it has no value
    DATA temp23 TYPE z2ui5_cl_sel_context=>ty_t_range.
    DATA temp24 LIKE LINE OF temp23.
    DATA lt_range LIKE temp23.
    DATA lo_pop TYPE REF TO z2ui5_cl_sel_range_pop.
    FIELD-SYMBOLS <temp25> LIKE LINE OF lo_pop->mt_filter.
    DATA temp26 LIKE sy-tabix.
    FIELD-SYMBOLS <temp27> LIKE LINE OF lo_pop->mt_filter.
    DATA temp28 LIKE sy-tabix.
    CLEAR temp23.

    temp24-sign = `I`.
    temp24-option = `EQ`.
    INSERT temp24 INTO TABLE temp23.
    temp24-sign = `E`.
    temp24-option = `NE`.
    INSERT temp24 INTO TABLE temp23.

    lt_range = temp23.


    lo_pop = popup_create( lt_range ).


    temp26 = sy-tabix.
    READ TABLE lo_pop->mt_filter INDEX 1 ASSIGNING <temp25>.
    sy-tabix = temp26.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `<leer>`
                                        act = <temp25>-option ).


    temp28 = sy-tabix.
    READ TABLE lo_pop->mt_filter INDEX 2 ASSIGNING <temp27>.
    sy-tabix = temp28.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `!<leer>`
                                        act = <temp27>-option ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_equals( exp = lt_range
                                        act = lo_pop->result( )-t_range ).

  ENDMETHOD.

  METHOD popup_xml.

    DATA ls_action LIKE LINE OF mo_action->ms_next-t_action_front.
    LOOP AT mo_action->ms_next-t_action_front INTO ls_action
         WHERE slot = z2ui5_if_client=>cs_view-popup AND method = `display`.
      result = ls_action-xml.
    ENDLOOP.

  ENDMETHOD.

  METHOD popup_destroyed.

    DATA temp29 LIKE sy-subrc.
    DATA temp1 TYPE xsdboolean.
    READ TABLE mo_action->ms_next-t_action_front WITH KEY slot = z2ui5_if_client=>cs_view-popup method = `destroy` TRANSPORTING NO FIELDS.
    temp29 = sy-subrc.

    temp1 = boolc( temp29 = 0 ).
    result = temp1.

  ENDMETHOD.

ENDCLASS.
