CLASS zcl_po_dts DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES tt_po_items TYPE TABLE OF ztb_po_items_u.
    TYPES ty_hd_control TYPE STRUCTURE FOR UPDATE zi_po_head_dt_u.
    TYPES ty_it_control TYPE STRUCTURE FOR UPDATE zi_po_items_dt_u.

    METHODS:
      create_po
        IMPORTING im_po_header TYPE ztb_po_head_u
        EXPORTING ex_messages  TYPE /dmo/t_message,

      update_po
        IMPORTING im_po_header TYPE ztb_po_head_u
                  control      TYPE ty_hd_control
        EXPORTING ex_messages  TYPE /dmo/t_message,

      delete_po
        IMPORTING im_po_header TYPE ztb_po_head_u
        EXPORTING ex_messages  TYPE /dmo/t_message,

      get_po
        IMPORTING im_po        TYPE ztb_po_head_u-po_num
        EXPORTING ex_messages  TYPE /dmo/t_message
                  ex_po_header TYPE ztb_po_head_u
                  ex_po_items  TYPE tt_po_items,

      create_item
        IMPORTING im_po_items TYPE ztb_po_items_u
        EXPORTING ex_messages TYPE /dmo/t_message,

      update_item
        IMPORTING im_po_items TYPE ztb_po_items_u
                  control     TYPE ty_it_control
        EXPORTING ex_messages TYPE /dmo/t_message,

      delete_item
        IMPORTING im_po_items TYPE ztb_po_items_u
        EXPORTING ex_messages TYPE /dmo/t_message,

      savedata.

    CLASS-METHODS:
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_po_dts.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA: mo_instance TYPE REF TO zcl_po_dts.
    DATA: gt_po_ins   TYPE STANDARD TABLE OF ztb_po_head_u,
          gt_po_upd   TYPE STANDARD TABLE OF ztb_po_head_u,
          gt_po_del   TYPE STANDARD TABLE OF ztb_po_head_u,

          gt_item_ins TYPE STANDARD TABLE OF ztb_po_items_u,
          gt_item_upd TYPE STANDARD TABLE OF ztb_po_items_u,
          gt_item_del TYPE STANDARD TABLE OF ztb_po_items_u.

ENDCLASS.



CLASS zcl_po_dts IMPLEMENTATION.
  METHOD create_po.

    INSERT im_po_header INTO TABLE gt_po_ins.

  ENDMETHOD.

  METHOD update_po.

    IF im_po_header-po_num IS NOT INITIAL.
      SELECT SINGLE * FROM ztb_po_head_u
      WHERE po_num EQ @im_po_header-po_num
       INTO @DATA(ls_po_header).
      IF sy-subrc EQ 0.
        IF control-%control-Status IS NOT INITIAL.
          ls_po_header-status = im_po_header-status.
        ENDIF.
        IF control-%control-CompCode IS NOT INITIAL.
          ls_po_header-comp_code = im_po_header-comp_code.
        ENDIF.
        IF control-%control-DocCat IS NOT INITIAL.
          ls_po_header-doc_cat = im_po_header-doc_cat.
        ENDIF.
        IF control-%control-Org IS NOT INITIAL.
          ls_po_header-org = im_po_header-org.
        ENDIF.
        IF control-%control-Type IS NOT INITIAL.
          ls_po_header-type = im_po_header-type.
        ENDIF.
        IF control-%control-Vendor IS NOT INITIAL.
          ls_po_header-Vendor = im_po_header-Vendor.
        ENDIF.
        INSERT ls_po_header INTO TABLE gt_po_upd.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD delete_po.

    INSERT im_po_header INTO TABLE gt_po_del.

    IF gt_po_del[] IS NOT INITIAL.
      SELECT po_num, po_item FROM ztb_po_items_u
       FOR ALL ENTRIES IN @gt_po_del
        WHERE po_num = @gt_po_del-po_num
        INTO TABLE @DATA(lt_child_items).
    ENDIF.

    APPEND LINES OF lt_child_items TO gt_item_del.

  ENDMETHOD.

  METHOD get_po.
    SELECT SINGLE * FROM ztb_po_head_u WHERE po_num EQ @im_po INTO @ex_po_header.
    IF sy-subrc EQ 0.
      SELECT * FROM ztb_po_items_u
         WHERE po_num EQ @im_po
         INTO TABLE @ex_po_items.
    ENDIF.
  ENDMETHOD.

  METHOD create_item.

    INSERT im_po_items INTO TABLE gt_item_ins.

  ENDMETHOD.

  METHOD update_item.

    IF im_po_items-po_num IS NOT INITIAL AND im_po_items-po_item IS NOT INITIAL.
      SELECT SINGLE * FROM ztb_po_items_u
           WHERE po_num EQ @im_po_items-po_num AND po_item EQ @im_po_items-po_item
           INTO @DATA(ls_po_items).
      IF sy-subrc EQ 0.
        IF control-%control-ItemText IS NOT INITIAL.
          ls_po_items-item_text = im_po_items-item_text.
        ENDIF.
        IF control-%control-Material IS NOT INITIAL.
          ls_po_items-material = im_po_items-material.
        ENDIF.
        IF control-%control-Plant IS NOT INITIAL.
          ls_po_items-plant = im_po_items-plant.
        ENDIF.
        IF control-%control-Storloc IS NOT INITIAL.
          ls_po_items-storloc = im_po_items-storloc.
        ENDIF.
        IF control-%control-Qty IS NOT INITIAL.
          ls_po_items-qty = im_po_items-qty.
        ENDIF.
        INSERT ls_po_items INTO TABLE gt_item_upd.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD delete_item.

    INSERT im_po_items INTO TABLE gt_item_del.

  ENDMETHOD.


  METHOD get_instance.

    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                      THEN mo_instance
                                      ELSE NEW #( ) ).

  ENDMETHOD.

  METHOD savedata.

    IF gt_po_ins IS NOT INITIAL.
      INSERT ztb_po_head_u FROM TABLE @gt_po_ins.
    ENDIF.
    IF gt_po_upd IS NOT INITIAL.
      MODIFY ztb_po_head_u FROM TABLE @gt_po_upd.
    ENDIF.
    IF NOT gt_po_del[] IS INITIAL.
      DELETE ztb_po_head_u FROM TABLE @gt_po_del.
    ENDIF.

    IF gt_item_ins IS NOT INITIAL.
      INSERT ztb_po_items_u FROM TABLE @gt_item_ins.
    ENDIF.
    IF gt_item_upd IS NOT INITIAL.
      MODIFY ztb_po_items_u FROM TABLE @gt_item_upd.
    ENDIF.
    IF gt_item_del IS NOT INITIAL.
      DELETE ztb_po_items_u FROM TABLE @gt_item_del.
    ENDIF.

    CLEAR: gt_po_ins, gt_po_upd, gt_po_del,
           gt_item_ins, gt_item_upd, gt_item_del.

  ENDMETHOD.

ENDCLASS.
