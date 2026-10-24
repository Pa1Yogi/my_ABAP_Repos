CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES tt_po_failed    TYPE TABLE FOR FAILED   zr_po_hd_dt_d.
    TYPES tt_po_reported  TYPE TABLE FOR REPORTED zr_po_hd_dt_d.
    TYPES tt_items_failed   TYPE TABLE FOR FAILED   zr_po_is_dt_d.
    TYPES tt_items_reported TYPE TABLE FOR REPORTED zr_po_is_dt_d.
    DATA gt_messages TYPE /dmo/t_message.
    DATA gs_po_hd    TYPE ztb_a_po_hd_d.
    DATA gs_item     TYPE ztb_a_po_its_d.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Header RESULT result.

    METHODS create FOR MODIFY
       entities FOR CREATE Header.

    METHODS update FOR MODIFY
       entities FOR UPDATE Header.

    METHODS delete FOR MODIFY
       keys FOR DELETE Header.

    METHODS read FOR READ
       keys FOR READ Header RESULT result.

    METHODS lock FOR LOCK
       keys FOR LOCK Header.

    METHODS rba_Items FOR READ
       keys_rba FOR READ Header\_Items FULL result_requested RESULT result LINK association_links.

    METHODS cba_Items FOR MODIFY
       entities_cba FOR CREATE Header\_Items.
ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<po_create>).

      gs_po_hd = CORRESPONDING #( <po_create> MAPPING FROM ENTITY USING CONTROL ).
*      TRY.
*          gs_po_hd-po_uuid = cl_system_uuid=>create_uuid_x16_static( ).
*        CATCH cx_uuid_error.
*      ENDTRY.

      zcl_po_dts_process=>get_instance( )->create_po(
        EXPORTING
          im_po_header = gs_po_hd
        IMPORTING
          ex_messages  = gt_messages ).

      "Pass messages if any issues
      zcl_po_dt_auxiliary=>handle_po_messages(
        EXPORTING
          iv_cid       = <po_create>-%cid
          it_messages  = gt_messages
          create       = abap_true
        IMPORTING
            failed_added = DATA(failed_added)
        CHANGING
          failed       = failed-header
          reported     = reported-header ).

      IF failed_added = abap_false.
        INSERT VALUE #( %cid = <po_create>-%cid
                        %is_draft = <po_create>-%is_draft
                        ponum = gs_po_hd-po_num
                        PoUuid = gs_po_hd-po_uuid ) INTO TABLE mapped-header.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_po_update>).

      DATA(ls_control) = <fs_po_update>.

      gs_po_hd = CORRESPONDING #( <fs_po_update> MAPPING FROM ENTITY ).

      zcl_po_dts_process=>get_instance( )->update_po(
      EXPORTING
          im_po_header = gs_po_hd
          control      = ls_control
        IMPORTING
          ex_messages  = gt_messages ).

      zcl_po_dt_auxiliary=>handle_po_messages(
          EXPORTING
            iv_cid       = <fs_po_update>-%cid_ref
            po           = <fs_po_update>-PoNum
            po_uuid      = <fs_po_update>-PoUuid
            it_messages  = gt_messages
            update       = abap_true
          IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed       = failed-header
            reported     = reported-header ).

      IF failed_added = abap_false.
*        INSERT VALUE #(
**                        ponum = <fs_po_update>-ponum
**                        PoUuid = <fs_po_update>-pouuid
**                        %is_draft = <fs_po_update>-%is_draft
*                        %tky = <fs_po_update>-%tky
*                         ) INTO TABLE mapped-header.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_po_delete>).

      gs_po_hd = CORRESPONDING #( <fs_po_delete> MAPPING FROM ENTITY ).

      zcl_po_dts_process=>get_instance( )->delete_po(
      EXPORTING
          im_po_header = gs_po_hd
        IMPORTING
          ex_messages  = gt_messages ).

      zcl_po_dt_auxiliary=>handle_po_messages(
          EXPORTING
            iv_cid       = <fs_po_delete>-%cid_ref
            po           = <fs_po_delete>-PoNum
            po_uuid      = <fs_po_delete>-PoUuid
            it_messages  = gt_messages
            delete       = abap_true
          CHANGING
            failed       = failed-header
            reported     = reported-header ).


    ENDLOOP.

  ENDMETHOD.

  METHOD read.

    DATA ls_po_hd    TYPE ztb_a_po_hd_d.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<po_to_read>) GROUP BY <po_to_read>-%tky.

      zcl_po_dts_process=>get_instance( )->get_po(
        EXPORTING
          im_po        = <po_to_read>-PoNum
        IMPORTING
          ex_messages  = gt_messages
          ex_po_header = ls_po_hd ).

      zcl_po_dt_auxiliary=>handle_po_messages(
       EXPORTING
         po       = <po_to_read>-PoNum
         po_uuid      = <po_to_read>-PoUuid
         it_messages  = gt_messages
       IMPORTING
           failed_added = DATA(failed_added)
       CHANGING
         failed       = failed-header
         reported     = reported-header ).

      IF failed_added = abap_false.
        INSERT CORRESPONDING #( ls_po_hd MAPPING TO ENTITY ) INTO TABLE result.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Items.

    DATA: ls_po_hd    TYPE ztb_a_po_hd_d,
          it_po_items TYPE STANDARD TABLE OF ztb_a_po_its_d,
          items       LIKE LINE OF result.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<po_rba>) GROUP BY <po_rba>-PoNum.

      zcl_po_dts_process=>get_instance( )->get_po(
        EXPORTING
          im_po        = <po_rba>-PoNum
        IMPORTING
          ex_messages  = gt_messages
          ex_po_header = ls_po_hd
          ex_po_items  = it_po_items ).

      zcl_po_dt_auxiliary=>handle_po_messages(
       EXPORTING
        po           = <po_rba>-PoNum
        po_uuid      = <po_rba>-PoUuid
        it_messages  = gt_messages
       IMPORTING
         failed_added = DATA(failed_added)
       CHANGING
         failed       = failed-header
         reported     = reported-header ).

      IF failed_added = abap_false.
        LOOP AT it_po_items ASSIGNING FIELD-SYMBOL(<items>).
          "fill link table with key fields

          INSERT VALUE #( source-%tky = <po_rba>-%tky
                          target-%tky = VALUE #( PoNum  = <items>-po_num
                                                 PoItemUuid = <items>-po_item_uuid
                                                 PoItem = <items>-po_item ) )

                     INTO TABLE association_links.

          IF result_requested = abap_true.
            items = CORRESPONDING #( <items> MAPPING TO ENTITY ).
            INSERT items INTO TABLE result.
          ENDIF.

        ENDLOOP.
      ENDIF.

    ENDLOOP.

    SORT association_links BY target ASCENDING.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.

    SORT result BY %tky ASCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.

  ENDMETHOD.

  METHOD cba_Items.

    DATA: ls_po_hd    TYPE ztb_a_po_hd_d,
          it_po_items TYPE STANDARD TABLE OF ztb_a_po_its_d,
          last_item   TYPE ebelp VALUE '0'.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<po>).

      DATA(ponum) = <po>-PoNum.

      "Get the Items to it_po_items with ponum and messages if any.
      zcl_po_dts_process=>get_instance( )->get_po(
       EXPORTING
         im_po        = <po>-PoNum
       IMPORTING
         ex_messages  = gt_messages
         ex_po_header = ls_po_hd
         ex_po_items  = it_po_items ).

      zcl_po_dt_auxiliary=>handle_po_messages(
       EXPORTING
        po           = <po>-PoNum
        po_uuid      = <po>-PoUuid
        it_messages  = gt_messages
        itemcreate   = abap_true
       IMPORTING
        failed_added = DATA(failed_added)
       CHANGING
        failed       = failed-header
        reported     = reported-header ).

      IF failed_added = abap_true.
        LOOP AT <po>-%target ASSIGNING FIELD-SYMBOL(<item>).

          zcl_po_dt_auxiliary=>handle_item_messages(
           EXPORTING
            iv_cid       = <item>-%cid
            po           = <item>-PoNum
            item         = <item>-PoItem
            po_item_uuid = <item>-PoItemUuid
            is_dependend = abap_true
            it_messages  = gt_messages
           CHANGING
            failed       = failed-item
            reported     = reported-item ).

        ENDLOOP.

      ELSE.

        last_item = VALUE #( it_po_items[ lines( it_po_items ) ]-po_item OPTIONAL ).

        LOOP AT <po>-%target ASSIGNING FIELD-SYMBOL(<fs_item_create>).
          gs_item = CORRESPONDING #( <fs_item_create> MAPPING FROM ENTITY ) .

          gs_item-po_num = <fs_item_create>-PoNum.
*          last_item += 1.
*          gs_item-po_item = last_item.
          gs_item-parent_uuid = <po>-PoUuid.
*          TRY.
*              gs_item-po_item_uuid = cl_system_uuid=>create_uuid_x16_static( ).
*            CATCH cx_uuid_error.
*          ENDTRY.

          zcl_po_dts_process=>get_instance( )->create_item(
            EXPORTING
              im_po_items = gs_item
            IMPORTING
              ex_messages = gt_messages ).

          zcl_po_dt_auxiliary=>handle_item_messages(
            EXPORTING
             iv_cid       = <fs_item_create>-%cid
             po           = <fs_item_create>-PoNum
             item         = <fs_item_create>-PoItem
             po_item_uuid = <fs_item_create>-PoItemUuid
             it_messages  = gt_messages
             create       = abap_true
            IMPORTING
              failed_added = failed_added
            CHANGING
             failed       = failed-item
             reported     = reported-item ).

          IF failed_added = abap_false.
            INSERT VALUE #( %cid = <fs_item_create>-%cid
                            ponum = gs_item-po_num
                            poitem = gs_item-po_item
                            PoItemUuid = gs_item-po_item_uuid
                            %is_draft = <fs_item_create>-%is_draft ) INTO TABLE mapped-item.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    DATA gs_item     TYPE ztb_a_po_its_d.
    DATA gt_messages TYPE /dmo/t_message.

    METHODS update FOR MODIFY
       entities FOR UPDATE Item.

    METHODS delete FOR MODIFY
       keys FOR DELETE Item.

    METHODS read FOR READ
       keys FOR READ Item RESULT result.

    METHODS rba_Header FOR READ
       keys_rba FOR READ Item\_Header FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Item IMPLEMENTATION.

  METHOD update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_items_update>).

      DATA(ls_control) = <fs_items_update>.

      gs_item = CORRESPONDING #( <fs_items_update> MAPPING FROM ENTITY ).

      zcl_po_dts_process=>get_instance( )->update_item(
      EXPORTING
            im_po_items = gs_item
            control     = ls_control
          IMPORTING
            ex_messages = gt_messages ).

      zcl_po_dt_auxiliary=>handle_item_messages(
      EXPORTING
        iv_cid       = <fs_items_update>-%cid_ref
        po           = <fs_items_update>-PoNum
        item         = <fs_items_update>-PoItem
        po_item_uuid = <fs_items_update>-PoItemUuid
        it_messages  = gt_messages
        update       = abap_true
       IMPORTING
        failed_added = DATA(failed_added)
      CHANGING
        failed       = failed-item
        reported     = reported-item ).

      IF failed_added = abap_false.
*        INSERT VALUE #( ponum = <fs_items_update>-PoNum
*                        poitem = <fs_items_update>-PoItem
*                        PoItemUuid = <fs_items_update>-PoItemUuid ) INTO TABLE mapped-item.
      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<item>).

      gs_item = CORRESPONDING #( <item> MAPPING FROM ENTITY ).

      zcl_po_dts_process=>get_instance( )->delete_item(
      EXPORTING
            im_po_items = gs_item
          IMPORTING
            ex_messages = gt_messages ).

      zcl_po_dt_auxiliary=>handle_item_messages(
      EXPORTING
        iv_cid       = <item>-%cid_ref
        po           = <item>-PoNum
        item         = <item>-PoItem
        po_item_uuid = <item>-PoItemUuid
        it_messages  = gt_messages
        delete       = abap_true
       IMPORTING
        failed_added = DATA(failed_added)
      CHANGING
        failed       = failed-item
        reported     = reported-item ).

    ENDLOOP.

  ENDMETHOD.

  METHOD read.

    DATA: ls_po_hd    TYPE ztb_a_po_hd_d,
          it_po_items TYPE STANDARD TABLE OF ztb_a_po_its_d.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<item_by_po>) GROUP BY <item_by_po>-PoNum .

      zcl_po_dts_process=>get_instance( )->get_po(
        EXPORTING
          im_po        = <item_by_po>-PoNum
        IMPORTING
          ex_messages  = gt_messages
          ex_po_header = ls_po_hd
          ex_po_items  = it_po_items ).

      zcl_po_dt_auxiliary=>handle_item_messages(
      EXPORTING
        po           = <item_by_po>-PoNum
        item         = <item_by_po>-PoItem
        po_item_uuid = <item_by_po>-PoItemUuid
        it_messages  = gt_messages
       IMPORTING
          failed_added = DATA(failed_added)
      CHANGING
        failed       = failed-item
        reported     = reported-item ).

      IF failed_added = abap_false.
        "For each po num find the requested bookings
        LOOP AT GROUP <item_by_po> ASSIGNING FIELD-SYMBOL(<item>) GROUP BY <item>-%tky.

          READ TABLE it_po_items INTO DATA(ls_po_items) WITH KEY po_num  = <item>-%key-PoNum
                                                                  po_item = <item>-%key-PoItem .
          "if read was successful
          IF sy-subrc = 0.
            INSERT CORRESPONDING #( ls_po_items MAPPING TO ENTITY ) INTO TABLE result.
          ELSE.
            "Item not found
            INSERT VALUE #( ponum    = <item>-PoNum
                            poitem   = <item>-PoItem
                            %fail-cause = if_abap_behv=>cause-not_found )
              INTO TABLE failed-item.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD rba_Header.

    DATA: ls_po_hd    TYPE ztb_a_po_hd_d.

    DATA: messages TYPE /dmo/t_message.

    "Only one function call for each requested po
    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<item_by_po>) GROUP BY <item_by_po>-PoNum .

      "Get PO Header to ls_po_hd and messages if any.
      zcl_po_dts_process=>get_instance( )->get_po(
      EXPORTING
        im_po        = <item_by_po>-PoNum
      IMPORTING
        ex_messages  = gt_messages
        ex_po_header = ls_po_hd ).

      zcl_po_dt_auxiliary=>handle_item_messages(
      EXPORTING
        po           = <item_by_po>-PoNum
        item         = <item_by_po>-PoItem
        po_item_uuid = <item_by_po>-PoItemUuid
        it_messages  = gt_messages
       IMPORTING
          failed_added = DATA(failed_added)
      CHANGING
        failed       = failed-item
        reported     = reported-item ).

      IF failed_added = abap_false.
        LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<po>) USING KEY entity WHERE PoNum = <item_by_po>-PoNum.
          INSERT VALUE #(
              source-%tky     = <po>-%tky
              target-ponum = <po>-PoNum
            ) INTO TABLE association_links.

          IF result_requested = abap_true.
            APPEND CORRESPONDING #( ls_po_hd MAPPING TO ENTITY ) TO result.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

    SORT association_links BY source ASCENDING.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.

    SORT result BY %tky ASCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZR_PO_HD_DT_D DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_PO_HD_DT_D IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    "Save the data
    zcl_po_dts_process=>get_instance( )->savedata( ).

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
