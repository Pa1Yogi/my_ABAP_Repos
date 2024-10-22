CLASS lhc_PO_IT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE po_it.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE po_it.

    METHODS read FOR READ
      IMPORTING keys FOR READ po_it RESULT result.

    METHODS rba_Po_hd FOR READ
      IMPORTING keys_rba FOR READ po_it\_Po_hd FULL result_requested RESULT result LINK association_links.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE PO_IT.

ENDCLASS.

CLASS lhc_PO_IT IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Po_hd.
  ENDMETHOD.

  METHOD create.
   DATA :  ls_po_items TYPE ztb_po_items,
           lt_msg    TYPE /dmo/t_message.

    READ TABLE entities ASSIGNING FIELD-SYMBOL(<lfs_po_items>) index 1.
    if sy-subrc eq 0.
     ls_po_items = CORRESPONDING #( <lfs_po_items> MAPPING FROM ENTITY USING CONTROL ).
    endif.

    INSERT ztb_po_items from @ls_po_items.
    IF sy-subrc IS not INITIAL.
        mapped-po_it = VALUE #( BASE mapped-po_it
                                ( %cid = <lfs_po_items>-%cid
                                  PoNum = ls_po_items-po_num
                                  PoItem = ls_po_items-po_item
                                ) ).


      ELSE.
        LOOP AT lt_msg INTO DATA(ls_msg).
          APPEND VALUE #( %cid = <lfs_po_items>-%cid
              PoNum = <lfs_po_items>-PoNum )
              TO failed-po_hd.

          APPEND VALUE #( %msg = new_message( id       = ls_msg-msgid
                                              number   = ls_msg-msgno
                                              v1       = ls_msg-msgv1
                                              v2       = ls_msg-msgv2
                                              v3       = ls_msg-msgv3
                                              v4       = ls_msg-msgv4
                                              severity = if_abap_behv_message=>severity-error )
                          %key-PoNum = <lfs_po_items>-PoNum
                        "  %key-PoItem = <lfs_po_items>-PoItem
                          %cid =  <lfs_po_items>-%cid
                          %create = 'X'
                          PoNum = <lfs_po_items>-PoNum )
                         " PoItem = <lfs_po_items>-PoItem )
                          TO reported-po_hd.
        ENDLOOP.
      ENDIF.

  ENDMETHOD.

ENDCLASS.
