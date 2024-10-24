CLASS lhc_PO_HD DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR po_hd RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE po_hd.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE po_hd.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE po_hd.

    METHODS read FOR READ
      IMPORTING keys FOR READ po_hd RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK po_hd.

    METHODS rba_Po_items FOR READ
      IMPORTING keys_rba FOR READ po_hd\_Po_items FULL result_requested RESULT result LINK association_links.

    METHODS cba_Po_items FOR MODIFY
      IMPORTING entities_cba FOR CREATE po_hd\_Po_items.

    METHODS Change_status FOR MODIFY
      IMPORTING keys FOR ACTION po_hd~Change_status RESULT result.

ENDCLASS.

CLASS lhc_PO_HD IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zi_po_head IN LOCAL MODE
     ENTITY po_hd
        FIELDS (  PoNum Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_po_result)
      FAILED failed.

    result =
      VALUE #( FOR ls_po IN lt_po_result
        ( %key = ls_po-%key
          %features-%action-Change_status = COND #( WHEN ls_po-status = 'B'
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled )
         ) ).

  ENDMETHOD.

  METHOD create.

    DATA :  ls_po_hd TYPE ztb_po_head.


    READ TABLE entities ASSIGNING FIELD-SYMBOL(<lfs_po_hd>) INDEX 1.
    IF sy-subrc EQ 0.
      ls_po_hd = CORRESPONDING #( <lfs_po_hd> MAPPING FROM ENTITY USING CONTROL ).
    ENDIF.

    INSERT ztb_po_head FROM @ls_po_hd.
    IF sy-subrc IS INITIAL.
      mapped-po_hd = VALUE #( BASE mapped-po_hd
                              ( %cid = <lfs_po_hd>-%cid
                                PoNum = ls_po_hd-po_num
                              ) ).
    ELSE.

      APPEND VALUE #( %cid = <lfs_po_hd>-%cid
          PoNum = <lfs_po_hd>-PoNum )
          TO failed-po_hd.

      APPEND VALUE #( %msg = new_message( id       = '00'
                                          number   = '001'
                                          v1       = 'Invalid Details'
                                          severity = if_abap_behv_message=>severity-error )
                      %key-PoNum = <lfs_po_hd>-PoNum
                      %cid =  <lfs_po_hd>-%cid
                      %create = 'X'
                      PoNum = <lfs_po_hd>-PoNum )
                      TO reported-po_hd.

    ENDIF.

  ENDMETHOD.

  METHOD update.

    DATA : ls_po    TYPE zi_po_head,
           ls_po_hd TYPE ztb_po_head.


    READ TABLE entities ASSIGNING FIELD-SYMBOL(<lfs_po_hd>) INDEX 1.
    IF sy-subrc EQ 0.
      SELECT SINGLE * FROM ztb_po_head WHERE po_num EQ @<lfs_po_hd>-PoNum INTO @ls_po_hd.
*     ls_po_hd = CORRESPONDING #( <lfs_po_hd> MAPPING FROM ENTITY USING CONTROL ).
      IF <lfs_po_hd>-CompCode IS NOT INITIAL.
     ls_po_hd-comp_code = <lfs_po_hd>-CompCode.
      ENDIF.
      IF <lfs_po_hd>-DocCat IS NOT INITIAL.
        ls_po_hd-doc_cat = <lfs_po_hd>-DocCat.
      ENDIF.
*
      IF <lfs_po_hd>-Org IS NOT INITIAL.
        ls_po_hd-org =  <lfs_po_hd>-Org.
      ENDIF.
**
      IF <lfs_po_hd>-Plant IS NOT INITIAL.
        ls_po_hd-plant = <lfs_po_hd>-Plant.
      ENDIF.
**
      IF <lfs_po_hd>-PoNum IS NOT INITIAL.
        ls_po_hd-po_num = <lfs_po_hd>-PoNum.
      ENDIF.
*
      IF <lfs_po_hd>-Status IS NOT INITIAL.
        ls_po_hd-status = <lfs_po_hd>-Status.
      ENDIF.
*
      IF <lfs_po_hd>-Type IS NOT INITIAL.
        ls_po_hd-type = <lfs_po_hd>-Type.
      ENDIF.
*
      IF  <lfs_po_hd>-Vendor IS NOT INITIAL.
        ls_po_hd-vendor = <lfs_po_hd>-Vendor.
      ENDIF.
*
    ENDIF.

    UPDATE ztb_po_head FROM @ls_po_hd .
    IF sy-subrc IS INITIAL.
      mapped-po_hd = VALUE #( BASE mapped-po_hd
                              ( %cid = <lfs_po_hd>-%cid_ref
                                PoNum = ls_po_hd-po_num
                              ) ).
    ELSE.

      APPEND VALUE #( %cid = <lfs_po_hd>-%cid_ref
          PoNum = <lfs_po_hd>-PoNum )
          TO failed-po_hd.

      APPEND VALUE #( %msg = new_message( id       = '00'
                                          number   = '001'
                                          v1       = 'Invalid Details'
                                          severity = if_abap_behv_message=>severity-error )
                      %key-PoNum = <lfs_po_hd>-PoNum
                      %cid =  <lfs_po_hd>-%cid_ref
                      %update = 'X'
                      PoNum = <lfs_po_hd>-PoNum )
                      TO reported-po_hd.

    ENDIF.

  ENDMETHOD.

  METHOD delete.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<lfs_keys>) INDEX 1.
    IF sy-subrc EQ 0.
      DELETE FROM ztb_po_head WHERE po_num EQ @<lfs_keys>-PoNum.
      IF sy-subrc NE 0.
        APPEND VALUE #( %cid = <lfs_keys>-%cid_ref
          PoNum = <lfs_keys>-PoNum )
          TO failed-po_hd.

        APPEND VALUE #( %msg = new_message( id       = '00'
                                            number   = '001'
                                            v1       = 'Invalid Details'
                                            severity = if_abap_behv_message=>severity-error )
                        %key-PoNum = <lfs_keys>-PoNum
                        %cid =  <lfs_keys>-%cid_ref
                        %delete = 'X'
                        PoNum = <lfs_keys>-PoNum )
                        TO reported-po_hd.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD read.

    SELECT * FROM ztb_po_head
         FOR ALL ENTRIES IN @keys
         WHERE po_num = @keys-PoNum
         INTO CORRESPONDING FIELDS OF TABLE @result.

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Po_items.
  ENDMETHOD.

  METHOD cba_Po_items.
    DATA : ls_po_items TYPE ztb_po_items.

    READ TABLE entities_cba ASSIGNING FIELD-SYMBOL(<lfs_po_items>) INDEX 1.
    IF sy-subrc EQ 0.
      DATA(lv_po) = <lfs_po_items>-PoNum.
    ENDIF.

    READ TABLE <lfs_po_items>-%target ASSIGNING FIELD-SYMBOL(<lfs_items>) INDEX 1.
    IF sy-subrc EQ 0.
      DATA(ls_items) = CORRESPONDING ztb_po_items( <lfs_items> MAPPING FROM ENTITY USING CONTROL ).
    ENDIF.

    INSERT ztb_po_items FROM @ls_items.
    IF sy-subrc IS INITIAL.


      INSERT VALUE #( %cid = <lfs_po_items>-%cid_ref
                      PoNum = lv_po
                      PoItem = ls_items-po_item
                    ) INTO  TABLE mapped-po_it.

    ELSE.
      APPEND VALUE #( %cid      = <lfs_po_items>-%cid_ref
                       PoNum  = lv_po
                       PoItem = ls_items-po_item
                     ) TO failed-po_it.

      APPEND VALUE #( %msg = new_message( id       = '00'
                                          number   = '001'
                                          v1       = 'Invalid Details'
                                          severity = if_abap_behv_message=>severity-error )
                      %key-PoNum = lv_po
                      %key-PoItem = ls_items-po_item
                      %cid = <lfs_po_items>-%cid_ref
                      PoNum = lv_po
                      PoItem = ls_items-po_item
                     ) TO reported-po_it.


    ENDIF.

  ENDMETHOD.

  METHOD Change_status.

    DATA :  ls_po_hd TYPE ztb_po_head.


    MODIFY ENTITIES OF zi_po_head IN LOCAL MODE
            ENTITY po_hd
               UPDATE FROM VALUE #( FOR key IN keys
               ( PoNum = key-PoNum
                 Status = 'B'
                 %control-Status = if_abap_behv=>mk-on ) )
               FAILED failed
               REPORTED reported.


    READ ENTITIES OF zi_po_head IN LOCAL MODE
      ENTITY po_hd
      ALL FIELDS WITH
      CORRESPONDING #( keys )
      RESULT DATA(pos).

    result = VALUE #( FOR po IN pos
             ( %tky   = po-%tky
               %param = po ) ).

*    READ TABLE keys INTO DATA(key) INDEX 1.
*    SELECT SINGLE * FROM ztb_po_head WHERE po_num = @key-PoNum INTO @ls_po_hd.
*    ls_po_hd-status = 'B'.
*
*    UPDATE ztb_po_head FROM @ls_po_hd.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_PO_HEAD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_PO_HEAD IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
