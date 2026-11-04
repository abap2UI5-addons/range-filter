CLASS z2ui5_cl_sel_context DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Environment-abstracted character/format constants. Callers must read
    " these from z2ui5_cl_util instead of referencing cl_abap_char_utilities /
    " cl_abap_format directly, so the dependency on those SAP standard classes
    " lives in exactly one place (this class' class_constructor) and can be
    " ported once for non-ABAP runtimes (e.g. transpiled JS).
    CLASS-DATA cv_char_util_newline        TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_char_util_cr_lf          TYPE c LENGTH 2 READ-ONLY.

    CLASS-DATA cv_char_util_horizontal_tab TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_char_util_charsize       TYPE i          READ-ONLY.

    CLASS-DATA cv_format_e_xml_attr             TYPE i          READ-ONLY.

    " RTTI type-kind / kind / visibility constants, so callers can branch on
    " stored type_kind/kind fields without referencing cl_abap_typedescr /
    " cl_abap_objectdescr directly.
    CLASS-DATA cv_typedescr_typekind_table   TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_dref    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_oref    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_struct1 TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_struct2 TYPE c LENGTH 1 READ-ONLY.

    " the three elementary kinds whose JSON form is not their ABAP form
    " (ISO date/time strings, ISO timestamps) - what a caller converting a
    " scalar between the two representations has to branch on
    CLASS-DATA cv_typedescr_typekind_date    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_time    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_packed  TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_struct      TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_elem        TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_ref         TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_objectdescr_public         TYPE c LENGTH 1 READ-ONLY.

    CLASS-METHODS class_constructor.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.

    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_s_token.

    TYPES ty_t_token TYPE STANDARD TABLE OF ty_s_token WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_range,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_s_range.

    TYPES ty_t_range TYPE STANDARD TABLE OF ty_s_range WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_filter_multi,
        name            TYPE string,
        t_range         TYPE ty_t_range,
        t_token         TYPE ty_t_token,
        t_token_added   TYPE ty_t_token,
        t_token_removed TYPE ty_t_token,
      END OF ty_s_filter_multi.

    TYPES ty_t_filter_multi TYPE STANDARD TABLE OF ty_s_filter_multi WITH DEFAULT KEY.

    " depth guards the mutual recursion between these two (an include whose
    " expansion reaches itself would otherwise be an unbounded stack).
    " Optional and last in the list, so every existing caller is unaffected
    CLASS-METHODS rtti_get_t_attri_by_include
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS expand_components
      IMPORTING
        val           TYPE abap_component_tab
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS filter_itab
      IMPORTING
        filter TYPE ty_t_filter_multi
      CHANGING
        val     TYPE STANDARD TABLE.

    CLASS-METHODS filter_get_multi_by_data
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS filter_get_sql_where
      IMPORTING
        val           TYPE ty_t_filter_multi
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_parse
      IMPORTING
        !xml TYPE clike
      EXPORTING
        !any TYPE any.

    CLASS-METHODS xml_stringify
      IMPORTING
        !any          TYPE any
      RETURNING
        VALUE(result) TYPE string
      RAISING
        cx_xslt_serialization_error.

    CLASS-METHODS c_trim
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_t_attri_by_any
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_get_t_attri_by_table_name
      IMPORTING
        table_name    TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_create_tab_by_name
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS rtti_get_type_kind
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS filter_get_token_t_by_range_t
      IMPORTING
        val           TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE ty_t_token ##NEEDED.

    CLASS-METHODS filter_get_token_range_mapping
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS itab_corresponding
      IMPORTING
        val  TYPE STANDARD TABLE
      CHANGING
        !tab TYPE STANDARD TABLE.

    CLASS-METHODS uuid_get_c32
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    "! Any elementary value as its text, and never an exception.
    CLASS-METHODS data_get_string
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_s_attri_cache,
        absolute_name TYPE string,
        o_struct      TYPE REF TO cl_abap_structdescr,
        t_attri       TYPE cl_abap_structdescr=>component_table,
      END OF ty_s_attri_cache.

    CLASS-DATA mt_attri_cache TYPE HASHED TABLE OF ty_s_attri_cache WITH UNIQUE KEY absolute_name.

    CLASS-METHODS filter_get_sql_cond_by_range
      IMPORTING
        fieldname     TYPE clike
        range         TYPE ty_s_range
      RETURNING
        VALUE(result) TYPE string.

    " Guards the cycle z2ui5_cx_sel_error=>constructor -> uuid_get_c32 ->
    " RAISE z2ui5_cx_sel_error -> ... see uuid_get_c32.
    CLASS-DATA gv_uuid_failed TYPE abap_bool.

    " a token template of filter_get_token_range_mapping with {LOW} and
    " {HIGH} filled in as written
    CLASS-METHODS filter_token_fill
      IMPORTING
        template      TYPE string
        low           TYPE string
        high          TYPE string
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS z2ui5_cl_sel_context IMPLEMENTATION.

  METHOD class_constructor.

    cv_char_util_newline        = cl_abap_char_utilities=>newline.
    cv_char_util_cr_lf          = cl_abap_char_utilities=>cr_lf.
    cv_char_util_horizontal_tab = cl_abap_char_utilities=>horizontal_tab.
    cv_char_util_charsize       = cl_abap_char_utilities=>charsize.
    cv_format_e_xml_attr        = cl_abap_format=>e_xml_attr.

    cv_typedescr_typekind_table      = cl_abap_typedescr=>typekind_table.
    cv_typedescr_typekind_dref       = cl_abap_typedescr=>typekind_dref.
    cv_typedescr_typekind_oref       = cl_abap_typedescr=>typekind_oref.
    cv_typedescr_typekind_struct1    = cl_abap_typedescr=>typekind_struct1.
    cv_typedescr_typekind_struct2    = cl_abap_typedescr=>typekind_struct2.
    cv_typedescr_typekind_date       = cl_abap_typedescr=>typekind_date.
    cv_typedescr_typekind_time       = cl_abap_typedescr=>typekind_time.
    cv_typedescr_typekind_packed     = cl_abap_typedescr=>typekind_packed.
    cv_typedescr_kind_struct         = cl_abap_typedescr=>kind_struct.
    cv_typedescr_kind_elem           = cl_abap_typedescr=>kind_elem.
    cv_typedescr_kind_ref            = cl_abap_typedescr=>kind_ref.
    cv_objectdescr_public            = cl_abap_objectdescr=>public.

  ENDMETHOD.

  METHOD c_trim.
      DATA lv_before LIKE result.

    result = val.
    " spaces and tabs alternate at either end (`\t \tx`) - one pass of each
    " leaves the inner layer standing, so strip until nothing changes. No
    " fixed number of passes: ten left the eleventh layer of a padded value
    " standing. Every pass that changes something shortens the string, so
    " the loop ends
    DO.

      lv_before = result.
      result = shift_left( shift_right( result ) ).
      result = shift_right( val = result
                            sub = cv_char_util_horizontal_tab ).
      result = shift_left( val = result
                           sub = cv_char_util_horizontal_tab ).
      IF result = lv_before.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD filter_itab.

    DATA ref TYPE REF TO data.
      DATA ls_filter LIKE LINE OF filter.
        FIELD-SYMBOLS <field> TYPE any.

    LOOP AT val REFERENCE INTO ref.


      LOOP AT filter INTO ls_filter.


        ASSIGN ref->(ls_filter-name) TO <field>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF <field> NOT IN ls_filter-t_range.
          DELETE val.
          EXIT.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_multi_by_data.

    DATA temp1 TYPE abap_component_tab.
    DATA temp3 LIKE LINE OF temp1.
    DATA lr_comp LIKE REF TO temp3.
      DATA temp2 TYPE z2ui5_cl_sel_context=>ty_s_filter_multi.
    temp1 = rtti_get_t_attri_by_any( val ).


    LOOP AT temp1 REFERENCE INTO lr_comp.

      CLEAR temp2.
      temp2-name = lr_comp->name.
      INSERT temp2 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_token_range_mapping.

    DATA temp3 TYPE z2ui5_cl_sel_context=>ty_t_name_value.
    DATA temp4 LIKE LINE OF temp3.
    CLEAR temp3.

    temp4-n = `EQ`.
    temp4-v = `={LOW}`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `LT`.
    temp4-v = `<{LOW}`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `LE`.
    temp4-v = `<={LOW}`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `GT`.
    temp4-v = `>{LOW}`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `GE`.
    temp4-v = `>={LOW}`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `CP`.
    temp4-v = `*{LOW}*`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `BT`.
    temp4-v = `{LOW}...{HIGH}`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `NB`.
    temp4-v = `!({LOW}...{HIGH})`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `NE`.
    temp4-v = `!(={LOW})`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `NP`.
    temp4-v = `!(*{LOW}*)`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `!<leer>`.
    temp4-v = `!(<leer>)`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `<leer>`.
    temp4-v = `<leer>`.
    INSERT temp4 INTO TABLE temp3.
    result = temp3.

  ENDMETHOD.

  METHOD filter_get_token_t_by_range_t.

    DATA lt_mapping TYPE z2ui5_cl_sel_context=>ty_t_name_value.
    DATA lt_tab TYPE ty_t_range.
    FIELD-SYMBOLS <lt_source> TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_range> TYPE ty_s_range.
    FIELD-SYMBOLS <lv_part> TYPE any.
      DATA lv_index TYPE i.
      FIELD-SYMBOLS <ls_source> TYPE ANY.
    DATA temp5 LIKE LINE OF lt_tab.
    DATA lr_row LIKE REF TO temp5.
      DATA lv_option TYPE string.
      DATA lv_value TYPE string.
      DATA temp6 TYPE string.
      DATA temp7 TYPE z2ui5_cl_sel_context=>ty_s_name_value.
        FIELD-SYMBOLS <temp8> LIKE LINE OF lt_mapping.
        DATA temp9 LIKE sy-tabix.
      DATA temp10 TYPE z2ui5_cl_sel_context=>ty_s_token.
    lt_mapping = filter_get_token_range_mapping( ).



    itab_corresponding( EXPORTING val = val
                        CHANGING  tab = lt_tab ).

    " LOW / HIGH again from the source row, through data_get_string: the
    " move into the string fields above wrote a number the way a MOVE does
    " - sign behind it and padded (`5- `), so a select-option on an integer
    " field showed `=42 ` and `5-...10 `
    " UNASSIGN + IS ASSIGNED, not sy-subrc, in the loop (#1937)



    ASSIGN val TO <lt_source>.
    IF <lt_source> IS ASSIGNED.

      lv_index = 0.

      LOOP AT <lt_source> ASSIGNING <ls_source>.
        lv_index = lv_index + 1.
        READ TABLE lt_tab INDEX lv_index ASSIGNING <ls_range>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        UNASSIGN <lv_part>.
        ASSIGN COMPONENT `LOW` OF STRUCTURE <ls_source> TO <lv_part>.
        IF <lv_part> IS ASSIGNED.
          <ls_range>-low = data_get_string( <lv_part> ).
        ENDIF.
        UNASSIGN <lv_part>.
        ASSIGN COMPONENT `HIGH` OF STRUCTURE <ls_source> TO <lv_part>.
        IF <lv_part> IS ASSIGNED.
          <ls_range>-high = data_get_string( <lv_part> ).
        ENDIF.
      ENDLOOP.
    ENDIF.



    LOOP AT lt_tab REFERENCE INTO lr_row.

      " an option the mapping does not know - initial (a row appended with
      " sign and low only) or lower-case - used to raise a raw
      " CX_SY_ITAB_LINE_NOT_FOUND out of the whole call; it renders as the
      " equality token, which is what a range row without an option means


      lv_option = to_upper( lr_row->option ).

      CLEAR temp6.

      READ TABLE lt_mapping INTO temp7 WITH KEY n = lv_option.
      IF sy-subrc = 0.
        temp6 = temp7-v.
      ENDIF.
      lv_value = temp6. "#EC CI_SORTSEQ
      IF lv_value IS INITIAL.


        temp9 = sy-tabix.
        READ TABLE lt_mapping WITH KEY n = `EQ` ASSIGNING <temp8>.
        sy-tabix = temp9.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_value = <temp8>-v. "#EC CI_SORTSEQ
      ENDIF.
      lv_value = filter_token_fill( template = lv_value
                                    low      = lr_row->low
                                    high     = lr_row->high ).

      " an excluding row must not render like its including twin - negate the
      " token so the MultiInput shows the filter's real meaning
      IF lr_row->sign = `E`.
        lv_value = |!({ lv_value })|.
      ENDIF.


      CLEAR temp10.
      temp10-key = lv_value.
      temp10-text = lv_value.
      temp10-visible = abap_true.
      temp10-editable = abap_true.
      INSERT temp10 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_include.

    " `type` IS the include's descriptor - the component the caller took it
    " from (as_include = abap_true) carries the structure descriptor, and
    " RTTI descriptors are singletons. It used to be re-described by name,
    " an RTTI lookup per include on the binding path that could only hand
    " back the object already in hand - or fail for a local include type
    " whose absolute name does not resolve, where the direct cast cannot
    DATA sdescr TYPE REF TO cl_abap_structdescr.
        DATA lx_cast TYPE REF TO cx_sy_move_cast_error.
    TRY.
        sdescr ?= type.

      CATCH cx_sy_move_cast_error INTO lx_cast.
        RAISE EXCEPTION TYPE z2ui5_cx_sel_error
          EXPORTING
            val      = |Include type '{ type->absolute_name }' is not a structure|
            previous = lx_cast.
    ENDTRY.
    result = expand_components( val   = sdescr->get_components( )
                                depth = depth ).

  ENDMETHOD.

  METHOD expand_components.
    DATA temp11 LIKE LINE OF val.
    DATA lr_comp LIKE REF TO temp11.
        DATA lt_include TYPE abap_component_tab.
          DATA temp12 LIKE LINE OF lt_include.
          DATA lr_include LIKE REF TO temp12.

    " see the declaration: bounded so a cyclic include chain surfaces as a
    " readable error instead of a stack-overflow dump. 16 nested include
    " levels is far beyond any real DDIC structure
    IF depth > 16.
      RAISE EXCEPTION TYPE z2ui5_cx_sel_error
        EXPORTING
          val = `RTTI_INCLUDE_RECURSION - include expansion exceeded 16 levels (cyclic include?)`.
    ENDIF.



    LOOP AT val REFERENCE INTO lr_comp.
      IF lr_comp->as_include = abap_true.
        " INCLUDE ... RENAMING WITH SUFFIX: the structure's components are
        " named <component><suffix>, and every nested level adds its own -
        " the bare include names do not exist on the structure, so a
        " binding path or ASSIGN COMPONENT built from them fails

        lt_include = rtti_get_t_attri_by_include( type  = lr_comp->type
                                                        depth = depth + 1 ).
        IF lr_comp->suffix IS NOT INITIAL.


          LOOP AT lt_include REFERENCE INTO lr_include.
            lr_include->name = lr_include->name && lr_comp->suffix.
          ENDLOOP.
        ENDIF.
        INSERT LINES OF lt_include INTO TABLE result.
      ELSE.
        INSERT lr_comp->* INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct        TYPE REF TO cl_abap_structdescr.
    DATA lo_type          TYPE REF TO cl_abap_typedescr.
    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_absolute_name TYPE string.
        DATA temp13 TYPE REF TO cl_abap_structdescr.
        DATA temp14 TYPE REF TO cl_abap_structdescr.
        DATA temp4 TYPE REF TO cl_abap_tabledescr.
    DATA lr_cache TYPE REF TO z2ui5_cl_sel_context=>ty_s_attri_cache.
      DATA temp15 TYPE z2ui5_cl_sel_context=>ty_s_attri_cache.

    " describe_by_data never fails for a data object, and the reference case
    " is the one branch. The fallback chain that used to sit here - a second
    " describe_by_data_ref, then describe_by_name( val ) - could rescue no
    " input: the first only re-raised what the branch above had raised, and
    " a data object is no type name
    lo_type = cl_abap_typedescr=>describe_by_data( val ).
    IF lo_type->kind = cl_abap_typedescr=>kind_ref.
      lo_type = cl_abap_typedescr=>describe_by_data_ref( val ).
    ENDIF.

    CASE lo_type->kind.
      WHEN cl_abap_typedescr=>kind_struct.

        temp13 ?= lo_type.
        lo_struct = temp13.
      WHEN cl_abap_typedescr=>kind_table.


        temp4 ?= lo_type.
        temp14 ?= temp4->get_table_line_type( ).
        lo_struct = temp14.
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    " descriptor instances are singletons per type, so the identity check
    " guards against absolute names reused by other (local/anonymous) types
    lv_absolute_name = lo_struct->absolute_name.

    READ TABLE mt_attri_cache REFERENCE INTO lr_cache
         WITH TABLE KEY absolute_name = lv_absolute_name.
    IF sy-subrc = 0 AND lr_cache->o_struct = lo_struct.
      result = lr_cache->t_attri.
      RETURN.
    ENDIF.

    result = expand_components( lo_struct->get_components( ) ).

    IF lr_cache IS BOUND.
      lr_cache->o_struct = lo_struct.
      lr_cache->t_attri  = result.
    ELSE.

      CLEAR temp15.
      temp15-absolute_name = lv_absolute_name.
      temp15-o_struct = lo_struct.
      temp15-t_attri = result.
      INSERT temp15 INTO TABLE mt_attri_cache.
    ENDIF.

  ENDMETHOD.

  METHOD xml_parse.

    IF xml IS INITIAL.
      CLEAR any.
      RETURN.
    ENDIF.

    CALL TRANSFORMATION id
         SOURCE XML xml
         RESULT data = any.

  ENDMETHOD.

  METHOD xml_stringify.

    CALL TRANSFORMATION id
         SOURCE data = any
         RESULT XML result
         OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_table_name.
        DATA lo_obj TYPE REF TO cl_abap_typedescr.
        DATA temp16 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp16.
            DATA temp17 TYPE REF TO cl_abap_tabledescr.
            DATA lo_tab LIKE temp17.
            DATA temp18 TYPE REF TO cl_abap_structdescr.
    DATA lt_comps TYPE abap_component_tab.
    DATA temp19 LIKE LINE OF lt_comps.
    DATA lr_comp LIKE REF TO temp19.
        DATA lt_attri TYPE abap_component_tab.

    IF table_name IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_sel_error
        EXPORTING
          val = `TABLE_NAME_INITIAL_ERROR`.
    ENDIF.

    TRY.

        cl_abap_structdescr=>describe_by_name( EXPORTING  p_name         = table_name
                                               RECEIVING  p_descr_ref    = lo_obj
                                               EXCEPTIONS type_not_found = 1
                                                          OTHERS         = 2
            ).

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_sel_error
            EXPORTING
              val = |TABLE_NOT_FOUND_NAME___{ table_name }|.
        ENDIF.

        temp16 ?= lo_obj.

        lo_struct = temp16.

      CATCH cx_root.

        TRY.
            cl_abap_structdescr=>describe_by_name( EXPORTING  p_name         = table_name
                                                   RECEIVING  p_descr_ref    = lo_obj
                                                   EXCEPTIONS type_not_found = 1
                                                              OTHERS         = 2
            ).
            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE z2ui5_cx_sel_error
                EXPORTING
                  val = |TABLE_NOT_FOUND_NAME___{ table_name }|.
            ENDIF.


            temp17 ?= lo_obj.

            lo_tab = temp17.

            temp18 ?= lo_tab->get_table_line_type( ).
            lo_struct = temp18.
          CATCH cx_root.
            RETURN.
        ENDTRY.

    ENDTRY.


    lt_comps = lo_struct->get_components( ).



    LOOP AT lt_comps REFERENCE INTO lr_comp.
      IF lr_comp->as_include = abap_true.

        lt_attri = rtti_get_t_attri_by_include( lr_comp->type ).
        INSERT LINES OF lt_attri INTO TABLE result.
      ELSE.
        INSERT lr_comp->* INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_corresponding.

    FIELD-SYMBOLS <row_in>  TYPE any.
    FIELD-SYMBOLS <row_out> TYPE any.

    LOOP AT val ASSIGNING <row_in>.
      APPEND INITIAL LINE TO tab ASSIGNING <row_out>.
      MOVE-CORRESPONDING <row_in> TO <row_out>.
    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_sql_where.

    DATA ls_filter LIKE LINE OF val.
      DATA lv_include TYPE string.
      DATA lv_exclude TYPE string.
      DATA ls_range LIKE LINE OF ls_filter-t_range.
        DATA lv_cond TYPE string.
          DATA temp20 TYPE string.
          DATA temp21 TYPE string.
      DATA temp22 TYPE string.
      DATA lv_field_where LIKE temp22.
    LOOP AT val INTO ls_filter.

      IF ls_filter-t_range IS INITIAL.
        CONTINUE.
      ENDIF.

      " the select-options are bound to the view, so the name comes back from
      " the browser - only a plain field name goes into the WHERE clause, never
      " a condition or a subquery on another table
      " a character set instead of a regex: PCRE is not on 7.02, POSIX not
      " on ABAP Cloud
      IF ls_filter-name IS INITIAL
          OR ls_filter-name CN `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_/`.
        CONTINUE.
      ENDIF.

      " select-option semantics: a row matches one of the including ranges
      " and none of the excluding ones. An excluding range arrives here
      " already negated (filter_get_sql_cond_by_range), so the includes are
      " joined with OR and the excludes with AND - OR-ing them too let
      " every row through that missed a single exclude

      lv_include = ``.

      lv_exclude = ``.

      LOOP AT ls_filter-t_range INTO ls_range.

        lv_cond = filter_get_sql_cond_by_range( fieldname = ls_filter-name
                                                      range     = ls_range ).
        IF lv_cond IS INITIAL.
          CONTINUE.
        ENDIF.
        IF ls_range-sign = `E`.

          IF lv_exclude IS INITIAL.
            temp20 = lv_cond.
          ELSE.
            temp20 = |{ lv_exclude } AND { lv_cond }|.
          ENDIF.
          lv_exclude = temp20.
        ELSE.

          IF lv_include IS INITIAL.
            temp21 = lv_cond.
          ELSE.
            temp21 = |{ lv_include } OR { lv_cond }|.
          ENDIF.
          lv_include = temp21.
        ENDIF.
      ENDLOOP.


      IF lv_include IS NOT INITIAL AND lv_exclude IS NOT INITIAL.
        temp22 = |( { lv_include } ) AND { lv_exclude }|.
      ELSEIF lv_include IS NOT INITIAL.
        temp22 = lv_include.
      ELSE.
        temp22 = lv_exclude.
      ENDIF.

      lv_field_where = temp22.

      IF lv_field_where IS INITIAL.
        CONTINUE.
      ENDIF.

      IF result IS INITIAL.
        result = |( { lv_field_where } )|.
      ELSE.
        result = |{ result } AND ( { lv_field_where } )|.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_sql_cond_by_range.

    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lv_option LIKE range-option.
    DATA lv_like TYPE string.
    lv_low = replace( val  = range-low
                            sub  = `'`
                            with = `''`
                            occ  = 0 ).

    lv_high = replace( val  = range-high
                             sub  = `'`
                             with = `''`
                             occ  = 0 ).

    lv_option = range-option.

    IF range-sign = `E`.
      CASE lv_option.
        WHEN `EQ`. lv_option = `NE`.
        WHEN `NE`. lv_option = `EQ`.
        WHEN `LT`. lv_option = `GE`.
        WHEN `LE`. lv_option = `GT`.
        WHEN `GT`. lv_option = `LE`.
        WHEN `GE`. lv_option = `LT`.
        WHEN `CP`. lv_option = `NP`.
        WHEN `NP`. lv_option = `CP`.
        WHEN `BT`. lv_option = `NB`.
        WHEN `NB`. lv_option = `BT`.
      ENDCASE.
    ENDIF.

    " CP: only * and + are wildcards - a _ or % the user typed is a plain
    " character, as in an IN range, so it is escaped

    lv_like = replace( val  = lv_low
                             sub  = `#`
                             with = `##`
                             occ  = 0 ).
    lv_like = replace( val  = lv_like
                       sub  = `%`
                       with = `#%`
                       occ  = 0 ).
    lv_like = replace( val  = lv_like
                       sub  = `_`
                       with = `#_`
                       occ  = 0 ).
    lv_like = replace( val  = lv_like
                       sub  = `*`
                       with = `%`
                       occ  = 0 ).
    lv_like = replace( val  = lv_like
                       sub  = `+`
                       with = `_`
                       occ  = 0 ).

    CASE lv_option.
      WHEN `EQ`.
        result = |{ fieldname } = '{ lv_low }'|.
      WHEN `NE`.
        result = |{ fieldname } <> '{ lv_low }'|.
      WHEN `LT`.
        result = |{ fieldname } < '{ lv_low }'|.
      WHEN `LE`.
        result = |{ fieldname } <= '{ lv_low }'|.
      WHEN `GT`.
        result = |{ fieldname } > '{ lv_low }'|.
      WHEN `GE`.
        result = |{ fieldname } >= '{ lv_low }'|.
      WHEN `CP`.
        result = |{ fieldname } LIKE '{ lv_like }' ESCAPE '#'|.
      WHEN `NP`.
        result = |{ fieldname } NOT LIKE '{ lv_like }' ESCAPE '#'|.
      WHEN `BT`.
        result = |{ fieldname } BETWEEN '{ lv_low }' AND '{ lv_high }'|.
      WHEN `NB`.
        result = |{ fieldname } NOT BETWEEN '{ lv_low }' AND '{ lv_high }'|.
    ENDCASE.

  ENDMETHOD.

  METHOD rtti_create_tab_by_name.

    " type_not_found is a classic exception: called functionally, an unknown
    " name ends in a short dump no CATCH stops - so it is handled here and
    " the caller gets an unbound reference instead
    DATA lo_type TYPE REF TO cl_abap_typedescr.
    DATA temp23 TYPE REF TO cl_abap_datadescr.
    DATA data_desc LIKE temp23.
    DATA gr_dyntable_typ TYPE REF TO cl_abap_tabledescr.
    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = val
                                         RECEIVING  p_descr_ref    = lo_type
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    " a class or an interface of that name is no data type - the kind, not
    " IS INSTANCE OF, which the 7.02 downport cannot express
    IF lo_type->kind = cl_abap_typedescr=>kind_class OR lo_type->kind = cl_abap_typedescr=>kind_intf.
      RETURN.
    ENDIF.

    temp23 ?= lo_type.

    data_desc = temp23.

    gr_dyntable_typ = cl_abap_tabledescr=>create( data_desc ).
    CREATE DATA result TYPE HANDLE gr_dyntable_typ.

  ENDMETHOD.

  METHOD data_get_string.

    " the plain assignment is what turns an elementary value into its text
    " - the same trick get_comp_str( ) uses. A value the runtime refuses to
    " convert must not be the reason a box does not appear
    TRY.
        " a number through a string template: the assignment puts the sign
        " BEHIND it - -5 came out as `5-`, a packed -12.50 as `12.50-`
        CASE rtti_get_type_kind( val ).
          WHEN cl_abap_datadescr=>typekind_int OR
              cl_abap_datadescr=>typekind_int1 OR
              cl_abap_datadescr=>typekind_int2 OR
              cl_abap_datadescr=>typekind_packed OR
              cl_abap_datadescr=>typekind_float OR
              cl_abap_datadescr=>typekind_decfloat16 OR
              cl_abap_datadescr=>typekind_decfloat34 OR
              `8`.
            " `8`: typekind_int8, a constant lower releases do not have
            result = |{ val }|.
          WHEN OTHERS.
            result = val.
        ENDCASE.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " a number reaches a character target right-aligned in the length its
    " type needs (` 12` for an i on some runtimes), and a CHAR field brings
    " its padding along - neither is what the value says
    result = c_trim( result ).

  ENDMETHOD.

  METHOD uuid_get_c32.
    DATA lv_uuid      TYPE c LENGTH 32.
    DATA lv_classname TYPE string.
    DATA lv_fm        TYPE string.
        DATA lx_uuid TYPE REF TO cx_root.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = lv_uuid.

          CATCH cx_root.

            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32 = lv_uuid.

        ENDTRY.

        result = lv_uuid.


      CATCH cx_root INTO lx_uuid.
        " both UUID mechanisms failed - raise the framework exception so the
        " consumer's single top-level catch can turn it into a handled error.
        " ASSERT would raise the uncatchable ASSERTION_FAILED and bypass that
        " catch (short dump instead of a handled error response).
        " z2ui5_cx_sel_error=>constructor itself calls uuid_get_c32, so the
        " raise below re-enters this method. gv_uuid_failed makes that nested
        " call return an empty UUID instead of raising again (endless recursion
        " until the stack overflows, which would defeat the handled error above).
        IF gv_uuid_failed = abap_true.
          RETURN.
        ENDIF.
        gv_uuid_failed = abap_true.
        TRY.
            RAISE EXCEPTION TYPE z2ui5_cx_sel_error
              EXPORTING
                val = lx_uuid.
          CLEANUP.
            CLEAR gv_uuid_failed.
        ENDTRY.
    ENDTRY.
  ENDMETHOD.

  METHOD filter_token_fill.

    " built by concatenation, not REPLACE ... WITH: LOW and HIGH are data,
    " and the transpiled runtime reads a WITH text like a regex replacement
    " ( `$&`, `$$`, `\{` change - backlog item runtime-replace-with-literal ).
    " HIGH first: a LOW that spells `{HIGH}` is then never substituted a
    " second time ( {LOW} stands before {HIGH} in every template )
    DATA lv_off  TYPE i.
    DATA lv_rest TYPE i.

    result = template.
    lv_off = find( val = result
                   sub = `{HIGH}` ).
    IF lv_off >= 0.
      lv_rest = lv_off + 6.
      result = substring( val = result
                          len = lv_off ) && high && substring( val = result
                                                               off = lv_rest ).
    ENDIF.
    lv_off = find( val = result
                   sub = `{LOW}` ).
    IF lv_off >= 0.
      lv_rest = lv_off + 5.
      result = substring( val = result
                          len = lv_off ) && low && substring( val = result
                                                              off = lv_rest ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
