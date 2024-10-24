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
      IMPORTING entities FOR CREATE po_it.

ENDCLASS.

CLASS lhc_PO_IT IMPLEMENTATION.

  METHOD update.

    DATA :  ls_po_items TYPE ztb_po_items,
            lt_po_items TYPE TABLE of ztb_po_items.


*    READ TABLE entities ASSIGNING FIELD-SYMBOL(<lfs_po_it>) INDEX 1.
*    IF sy-subrc EQ 0.
      SELECT * FROM ztb_po_items FOR ALL ENTRIES IN @entities WHERE po_num = @entities-PoNum INTO table @lt_po_items.
*      ls_po_items = CORRESPONDING #( <lfs_po_it> MAPPING FROM ENTITY USING CONTROL ).
*    ENDIF.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_po_it>).
      READ TABLE lt_po_items ASSIGNING FIELD-SYMBOL(<lfs_items>)
          WITH KEY po_num = <lfs_po_it>-PoNum po_item = <lfs_po_it>-PoItem BINARY SEARCH.
      IF sy-subrc eq 0.
       IF <lfs_po_it>-Material IS NOT INITIAL.
       <lfs_items>-material = <lfs_po_it>-Material.
       ENDIF.
       IF <lfs_po_it>-ItemText IS NOT INITIAL.
       <lfs_items>-item_text = <lfs_po_it>-ItemText.
       ENDIF.
       IF <lfs_po_it>-Plant IS NOT INITIAL.
       <lfs_items>-plant = <lfs_po_it>-Plant.
       ENDIF.
       IF <lfs_po_it>-ProductPrice IS NOT INITIAL.
       <lfs_items>-product_price = <lfs_po_it>-ProductPrice.
       ENDIF.
       IF <lfs_po_it>-PriceUnit IS NOT INITIAL.
       <lfs_items>-price_unit = <lfs_po_it>-PriceUnit.
       ENDIF.
       IF <lfs_po_it>-Qty IS NOT INITIAL.
       <lfs_items>-qty = <lfs_po_it>-Qty.
       ENDIF.
       IF <lfs_po_it>-Uom IS NOT INITIAL.
       <lfs_items>-uom = <lfs_po_it>-Uom.
       ENDIF.
       IF <lfs_po_it>-StorLoc IS NOT INITIAL.
       <lfs_items>-stor_loc = <lfs_po_it>-StorLoc.
       ENDIF.
      endif.

    ENDLOOP.

    UPDATE ztb_po_items FROM TABLE @lt_po_items.
    IF sy-subrc IS INITIAL.
*      mapped-po_it = VALUE #( BASE mapped-po_it
*                              ( %cid = <lfs_po_it>-%cid_ref
*                                PoNum = ls_po_items-po_num
*                              ) ).

      INSERT VALUE #( %cid = <lfs_po_it>-%cid_ref
                      PoNum = <lfs_po_it>-PoNum
                      PoItem = <lfs_po_it>-PoItem
                    ) INTO  TABLE mapped-po_it.
    ELSE.

      APPEND VALUE #( %cid = <lfs_po_it>-%cid_ref
          PoNum = <lfs_po_it>-PoNum
          PoItem = <lfs_po_it>-PoItem )
          TO failed-po_it.

      APPEND VALUE #( %msg = new_message( id       = '00'
                                          number   = '001'
                                          v1       = 'Invalid Details'
                                          severity = if_abap_behv_message=>severity-error )
                      %key-PoNum = <lfs_po_it>-PoNum
                      %key-PoItem = <lfs_po_it>-PoItem
                      %cid =  <lfs_po_it>-%cid_ref
                      %update = 'X'
                      PoNum = <lfs_po_it>-PoNum
                      PoItem = <lfs_po_it>-PoItem )
                      TO reported-po_it.

    ENDIF.

  ENDMETHOD.

  METHOD delete.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<lfs_keys>) INDEX 1.
    IF sy-subrc EQ 0.
      DELETE FROM ztb_po_items WHERE po_num EQ @<lfs_keys>-PoNum AND po_item EQ @<lfs_keys>-PoItem.
      IF sy-subrc NE 0.
        APPEND VALUE #( %cid = <lfs_keys>-%cid_ref
          PoNum = <lfs_keys>-PoNum
          PoItem = <lfs_keys>-PoItem  )
          TO failed-po_it.

        APPEND VALUE #( %msg = new_message( id       = '00'
                                            number   = '001'
                                            v1       = 'Invalid Details'
                                            severity = if_abap_behv_message=>severity-error )
                        %key-PoNum = <lfs_keys>-PoNum
                        %key-PoItem = <lfs_keys>-PoItem
                        %cid =  <lfs_keys>-%cid_ref
                        %delete = 'X'
                        PoNum = <lfs_keys>-PoNum
                        PoItem = <lfs_keys>-PoItem  )
                        TO reported-po_it.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Po_hd.
  ENDMETHOD.

  METHOD create.
    DATA : ls_po_items TYPE ztb_po_items.

    READ TABLE entities ASSIGNING FIELD-SYMBOL(<lfs_po_items>) INDEX 1.
    IF sy-subrc EQ 0.
      ls_po_items = CORRESPONDING #( <lfs_po_items> MAPPING FROM ENTITY USING CONTROL ).
    ENDIF.

    INSERT ztb_po_items FROM @ls_po_items.
    IF sy-subrc IS NOT INITIAL.
      mapped-po_it = VALUE #( BASE mapped-po_it
                              ( %cid = <lfs_po_items>-%cid
                                PoNum = ls_po_items-po_num
                                PoItem = ls_po_items-po_item
                              ) ).


    ELSE.
      APPEND VALUE #( %cid = <lfs_po_items>-%cid
          PoNum = <lfs_po_items>-PoNum
          PoItem = <lfs_po_items>-PoItem )
          TO failed-po_it.

      APPEND VALUE #( %msg = new_message( id       = '00'
                                          number   = '001'
                                          v1       = 'Invalid Details'
                                          severity = if_abap_behv_message=>severity-error )
                      %key-PoNum = <lfs_po_items>-PoNum
                      %key-PoItem = <lfs_po_items>-PoItem
                      %cid =  <lfs_po_items>-%cid
                      %create = 'X'
                      PoNum = <lfs_po_items>-PoNum
                      PoItem = <lfs_po_items>-PoItem )
                      TO reported-po_it.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
