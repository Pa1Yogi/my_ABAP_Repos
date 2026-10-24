CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Header RESULT result.

    METHODS lock FOR LOCK
       keys FOR LOCK Header.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_PO_HEAD_DTS_M DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_PO_HEAD_DTS_M IMPLEMENTATION.

  METHOD save_modified.

    DATA: ls         TYPE zi_po_head_dts_m,
          lt_pohd    TYPE TABLE OF zi_po_head_dts_m,
          lt_poitems TYPE TABLE OF zi_po_items_dts_m,
          ls_po      TYPE ztb_po_head_m,
          lt_po      TYPE TABLE OF ztb_po_head_m,
          ls_it      TYPE ztb_po_items_m,
          lt_it      TYPE TABLE OF ztb_po_items_m.

    IF create IS NOT INITIAL.
      lt_pohd = CORRESPONDING #( create-header ).
      lt_poitems = CORRESPONDING #( create-item ).
    ENDIF.

    IF update IS NOT INITIAL.
      lt_pohd = CORRESPONDING #( update-header ).
      lt_poitems = CORRESPONDING #( update-item ).
    ENDIF.

    IF delete IS NOT INITIAL.
      lt_pohd = CORRESPONDING #( delete-header ).
      lt_poitems = CORRESPONDING #( delete-item ).
    ENDIF.


    READ TABLE lt_pohd ASSIGNING FIELD-SYMBOL(<ls_pohd>) INDEX 1.
    IF sy-subrc EQ 0.
      ls_po-po_num = <ls_pohd>-PoNum.
      ls_po-type = <ls_pohd>-Type.
      ls_po-comp_code = <ls_pohd>-CompCode.
      ls_po-org = <ls_pohd>-Org.
      ls_po-status = <ls_pohd>-Status.
      ls_po-vendor = <ls_pohd>-Vendor.
      APPEND ls_po TO lt_po.
    ENDIF.

    LOOP AT lt_poitems ASSIGNING FIELD-SYMBOL(<ls_poitems>).
      ls_it-po_num =  <ls_poitems>-PoNum.
      ls_it-po_item = <ls_poitems>-PoItem.
      ls_it-material = <ls_poitems>-Material.
      ls_it-plant = <ls_poitems>-Plant.
      ls_it-qty = <ls_poitems>-Qty.
      ls_it-price_unit = <ls_poitems>-PriceUnit.
      ls_it-Product_Price = <ls_poitems>-ProductPrice.
      ls_it-Uom = <ls_poitems>-Uom.
      ls_it-Item_Text = <ls_poitems>-ItemText.
      APPEND ls_it TO lt_it.
    ENDLOOP.


    IF lt_po IS NOT INITIAL AND delete IS INITIAL.
      MODIFY ztb_po_head_m FROM TABLE @lt_po.
    ENDIF.

    IF lt_it IS NOT INITIAL AND delete IS INITIAL.
      MODIFY ztb_po_items_m FROM  TABLE @lt_it.
    ENDIF.


    IF delete IS NOT INITIAL.

      IF lt_po IS NOT INITIAL AND lt_it IS NOT INITIAL.
        DELETE ztb_po_head_m FROM TABLE @lt_po.
        IF sy-subrc EQ 0.
          DELETE ztb_po_items_m FROM  TABLE @lt_it.
        ENDIF.
      ELSEIF lt_po IS NOT INITIAL AND lt_it IS INITIAL.
        DELETE ztb_po_head_m FROM TABLE @lt_po.
      ENDIF. "/ IF lt_po IS NOT INITIAL AND lt_it IS INITIAL.

      IF lt_it IS NOT INITIAL AND lt_po IS INITIAL .
        DELETE ztb_po_items_m FROM  TABLE @lt_it.
      ENDIF. "/ IF lt_it IS NOT INITIAL AND lt_po IS INITIAL .

    ENDIF. "IF delete IS NOT INITIAL.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
