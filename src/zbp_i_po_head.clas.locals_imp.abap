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

    METHODS Post FOR MODIFY
      IMPORTING keys FOR ACTION po_hd~Post RESULT result.

ENDCLASS.

CLASS lhc_PO_HD IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD create.

   DATA :  ls_po_hd TYPE ztb_po_head,
           lt_msg    TYPE /dmo/t_message.

    READ TABLE entities ASSIGNING FIELD-SYMBOL(<lfs_po_hd>) index 1.
    if sy-subrc eq 0.
     ls_po_hd = CORRESPONDING #( <lfs_po_hd> MAPPING FROM ENTITY USING CONTROL ).
    endif.

    INSERT ztb_po_head from @ls_po_hd.
    IF sy-subrc IS INITIAL.
        mapped-po_hd = VALUE #( BASE mapped-po_hd
                                ( %cid = <lfs_po_hd>-%cid
                                  PoNum = ls_po_hd-po_num
                                ) ).
      ELSE.
        LOOP AT lt_msg INTO DATA(ls_msg).
          APPEND VALUE #( %cid = <lfs_po_hd>-%cid
              PoNum = <lfs_po_hd>-PoNum )
              TO failed-po_hd.

          APPEND VALUE #( %msg = new_message( id       = ls_msg-msgid
                                              number   = ls_msg-msgno
                                              v1       = ls_msg-msgv1
                                              v2       = ls_msg-msgv2
                                              v3       = ls_msg-msgv3
                                              v4       = ls_msg-msgv4
                                              severity = if_abap_behv_message=>severity-error )
                          %key-PoNum = <lfs_po_hd>-PoNum
                          %cid =  <lfs_po_hd>-%cid
                          %create = 'X'
                          PoNum = <lfs_po_hd>-PoNum )
                          TO reported-po_hd.
        ENDLOOP.
      ENDIF.

  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Po_items.
  ENDMETHOD.

  METHOD cba_Po_items.
   DATA :  ls_po_items TYPE ztb_po_items,
           lt_msg     TYPE /dmo/t_message,
         lt_msg_b   TYPE /dmo/t_message.

    READ TABLE entities_cba ASSIGNING FIELD-SYMBOL(<lfs_po_items>) index 1.
    if sy-subrc eq 0.
     DATA(lv_po) = <lfs_po_items>-PoNum.
    endif.

    READ TABLE <lfs_po_items>-%target ASSIGNING FIELD-SYMBOL(<lfs_items>) index 1.
    if sy-subrc eq 0.
     DATA(ls_items) = CORRESPONDING ztb_po_items( <lfs_items> MAPPING FROM ENTITY USING CONTROL ).
    endif.

    INSERT ztb_po_items from @ls_items.
    IF sy-subrc IS INITIAL.

    "Pass data back to UI
        INSERT VALUE #( %cid = <lfs_po_items>-%cid_ref
                        PoNum = lv_po
                        PoItem = ls_items-po_item
                      ) INTO  TABLE mapped-po_it.


     LOOP AT lt_msg_b INTO DATA(ls_msg) WHERE msgty CA 'EA'.
          APPEND VALUE #( %cid      = <lfs_po_items>-%cid_ref
                          PoNum  = lv_po
                          PoItem = ls_items-po_item
                        ) TO failed-po_it.
          APPEND VALUE #( %msg = new_message( id       = ls_msg-msgid
                                              number   = ls_msg-msgno
                                              v1       = ls_msg-msgv1
                                              v2       = ls_msg-msgv2
                                              v3       = ls_msg-msgv3
                                              v4       = ls_msg-msgv4
                                              severity = if_abap_behv_message=>severity-error )
                          %key-PoNum = lv_po
                          %key-PoItem = ls_items-po_item
                          %cid = <lfs_po_items>-%cid_ref
                          PoNum = lv_po
                          PoItem = ls_items-po_item
                         ) TO reported-po_it.
        ENDLOOP.

      ELSE.
        LOOP AT lt_msg INTO DATA(ls_msg1).
          APPEND VALUE #( %cid = <lfs_po_items>-%cid_ref
              PoNum = <lfs_po_items>-PoNum )
              TO failed-po_hd.

          APPEND VALUE #( %msg = new_message( id       = ls_msg1-msgid
                                              number   = ls_msg1-msgno
                                              v1       = ls_msg1-msgv1
                                              v2       = ls_msg1-msgv2
                                              v3       = ls_msg1-msgv3
                                              v4       = ls_msg1-msgv4
                                              severity = if_abap_behv_message=>severity-error )
                          %key-PoNum = <lfs_po_items>-PoNum
                        "  %key-PoItem = <lfs_po_items>-PoItem
                          %cid =  <lfs_po_items>-%cid_ref
                          %create = 'X'
                          PoNum = <lfs_po_items>-PoNum )
                         " PoItem = <lfs_po_items>-PoItem )
                          TO reported-po_hd.
        ENDLOOP.
      ENDIF.

  ENDMETHOD.

  METHOD Post.
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
