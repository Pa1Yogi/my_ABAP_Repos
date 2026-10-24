CLASS zcl_po_dt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES tt_failed    TYPE RESPONSE FOR MAPPED  zi_po_header_dt.
    TYPES tt_mapped    TYPE RESPONSE FOR FAILED   zi_po_header_dt.
    TYPES tt_reported  TYPE RESPONSE FOR REPORTED zi_po_header_dt.
    TYPES tt_reported_late  TYPE RESPONSE FOR REPORTED LATE zi_po_header_dt.

    TYPES tt_create TYPE TABLE FOR CREATE zi_po_header_dt.
    TYPES tt_update TYPE TABLE FOR UPDATE zi_po_header_dt.
    TYPES tt_delete TYPE TABLE FOR DELETE zi_po_header_dt.

    TYPES tt_item_failed   TYPE RESPONSE FOR MAPPED  zi_po_header_dt.
    TYPES tt_item_mapped   TYPE RESPONSE FOR FAILED  zi_po_header_dt.
    TYPES tt_item_reported TYPE RESPONSE FOR REPORTED zi_po_header_dt.

    TYPES tt_item_create TYPE TABLE FOR CREATE zi_po_header_dt\_Po_items.
    TYPES tt_item_update TYPE TABLE FOR UPDATE zi_po_items_dt.
    TYPES tt_item_delete TYPE TABLE FOR DELETE zi_po_items_dt.

    METHODS:
      create_po
        IMPORTING entities TYPE tt_create
        CHANGING  mapped   TYPE tt_failed
                  failed   TYPE tt_mapped
                  reported TYPE tt_reported,

      update_po
        IMPORTING entities TYPE tt_update
        CHANGING  mapped   TYPE tt_failed
                  failed   TYPE tt_mapped
                  reported TYPE tt_reported,

      delete_po
        IMPORTING keys     TYPE tt_delete
        CHANGING  mapped   TYPE tt_failed
                  failed   TYPE tt_mapped
                  reported TYPE tt_reported,

      create_item
        IMPORTING entities TYPE tt_item_create
        CHANGING  mapped   TYPE tt_item_failed
                  failed   TYPE tt_item_mapped
                  reported TYPE tt_item_reported,

      update_item
        IMPORTING entities TYPE tt_item_update
        CHANGING  mapped   TYPE tt_item_failed
                  failed   TYPE tt_item_mapped
                  reported TYPE tt_item_reported,

      delete_item
        IMPORTING keys     TYPE tt_item_delete
        CHANGING  mapped   TYPE tt_item_failed
                  failed   TYPE tt_item_mapped
                  reported TYPE tt_item_reported,


      savedata
        CHANGING reported TYPE tt_reported_late.

    CLASS-METHODS:
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_po_dt.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: mo_instance TYPE REF TO zcl_po_dt.
    DATA: gt_po_dt    TYPE STANDARD TABLE OF ztb_pohead,
          gs_mapped   TYPE tt_mapped,

          gt_po_ins   TYPE STANDARD TABLE OF ztb_pohead,
          gt_po_upd   TYPE STANDARD TABLE OF ztb_pohead,
          gt_po_del   TYPE STANDARD TABLE OF ztb_pohead,

          gt_item_ins TYPE STANDARD TABLE OF ztb_poitems,
          gt_item_upd TYPE STANDARD TABLE OF ztb_poitems,
          gt_item_del TYPE STANDARD TABLE OF ztb_poitems.

ENDCLASS.



CLASS zcl_po_dt IMPLEMENTATION.
  METHOD create_po.

    gt_po_ins = CORRESPONDING #( entities MAPPING FROM ENTITY USING CONTROL ).

    mapped = VALUE #( zi_po_header_dt = VALUE #( FOR ls_entity IN entities
                      ( %cid      = ls_entity-%cid
                        %key      = ls_entity-%key ) ) ).

*    mapped-zi_po_header_dt = VALUE #( FOR ls_entity IN entities
*                     ( %cid      = ls_entity-%cid
*                       %key      = ls_entity-%key ) ).
*
*    failed-zi_po_header_dt = VALUE #( FOR ls_entity IN entities
*                   ( %cid = ls_entity-%cid
*                     %key = ls_entity-%key
*                     %fail-cause = if_abap_behv=>cause-conflict ) ).
*
*    reported-zi_po_header_dt  = VALUE #( FOR ls_entity IN entities
*                   ( %cid = ls_entity-%cid
*                     %key = ls_entity-%key ) ).


  ENDMETHOD.

  METHOD update_po.

    gt_po_upd = CORRESPONDING #( entities MAPPING FROM ENTITY USING CONTROL ).

    mapped-zi_po_header_dt = VALUE #( FOR ls_entity IN entities
                    ( %key      = ls_entity-%key ) ).

    failed-zi_po_header_dt = VALUE #( FOR ls_entity IN entities
                 ( %key = ls_entity-%key
                   %fail-cause = if_abap_behv=>cause-conflict ) ).

  ENDMETHOD.

  METHOD delete_po.
    DATA: lt_PO TYPE STANDARD TABLE OF ztb_pohead.

    gt_po_del = CORRESPONDING #( keys MAPPING po_num = PoNum ).

    SELECT po_num, po_item FROM ztb_poitems
     FOR ALL ENTRIES IN @gt_po_del
      WHERE po_num = @gt_po_del-po_num
      INTO TABLE @DATA(lt_child_items).
    APPEND LINES OF lt_child_items TO gt_item_del.


  ENDMETHOD.

  METHOD create_item.

    LOOP AT entities INTO DATA(ls_entity).

*      IF line_exists( gt_item_ins[ po_num = ls_entity-PoNum po_item = ls_entity-PoItem ] )
*      OR ( ls_entity-PoItem IS NOT INITIAL
*           AND exists( select 1 FROM ztb_poitem
*                         WHERE po_num = @ls_entity-PoNum AND po_item = @ls_entity-PoItem ) ).
*
*      APPEND VALUE #( %key- = ls_entity-%key
*                       %fail-cause = if_abap_behv=>cause-conflict ) TO failed-zi_po_items_dt.
*        CONTINUE.
*      ENDIF.

*       APPEND CORRESPONDING #( ls_entity1-
*        MAPPING po_num = PoNum po_item = PoItem material = Material  EXCEPT * )
*        TO gt_item_upd.

*      APPEND VALUE #( %key = ls_entity-%key ) TO mapped-zi_po_items_dt.

*       APPEND VALUE #( %key = ls_entity-%key
*                      %fail-cause = if_abap_behv=>cause-conflict ) TO failed-zi_po_header_dt.
*
*       APPEND VALUE #( %key = ls_entity-%key ) TO mapped-zi_po_header_dt.

      LOOP AT ls_entity-%target INTO DATA(ls_tar).
        APPEND CORRESPONDING #( ls_tar MAPPING po_num = PoNum po_item = PoItem material = Material ) TO gt_item_ins.

*        APPEND VALUE #( %key = ls_tar-%key
*                      %fail-cause = if_abap_behv=>cause-conflict ) TO failed-zi_po_items_dt.
*
*        APPEND VALUE #( %key = ls_tar-%key ) TO mapped-zi_po_items_dt.

      ENDLOOP.

    ENDLOOP.

*    failed-zi_po_items_dt = VALUE #( FOR ls_entity IN entities
*                  ( %key-PoNum = ls_entity-%key-PoNum
*                    %fail-cause = if_abap_behv=>cause-conflict ) ).

*    mapped-zi_po_items_dt = VALUE #( FOR ls_entity IN entities
*                    ( %key-PoNum      = ls_entity-%key-PoNum ) ).






  ENDMETHOD.

  METHOD update_item.

    LOOP AT entities INTO DATA(ls_entity1).
*
*      IF NOT line_exists( gt_item_ins[ po_num = ls_entity-PoNum po_item = ls_entity-PoItem ] )
*        AND NOT exists( select 1 FROM ztb_poitem
*                           WHERE po_num = @ls_entity-PoNum AND po_item = @ls_entity-PoItem ).
*
*        APPEND VALUE #( %key = ls_entity-%key
*                         %fail-cause = if_abap_behv=>cause-not_found ) TO failed.
*        CONTINUE.
*      ENDIF.
*
*      APPEND CORRESPONDING #( ls_entity
*        MAPPING po_num = PoNum po_item = PoItem material = Material quantity = Quantity EXCEPT * )
*        TO gt_item_upd.
*
*      APPEND VALUE #( %key = ls_entity-%key ) TO mapped.

      APPEND CORRESPONDING #( ls_entity1 MAPPING  po_num = PoNum po_item = PoItem material = Material ) TO gt_item_upd.

    ENDLOOP.

*    failed-zi_po_items_dt = VALUE #( FOR ls_entity IN entities
*                  ( %key-PoNum = ls_entity-%key-PoNum
*                    %fail-cause = if_abap_behv=>cause-conflict ) ).
*
*    mapped-zi_po_items_dt = VALUE #( FOR ls_entity IN entities
*                    ( %key-PoNum      = ls_entity-%key-PoNum ) ).

*    gt_item_upd = CORRESPONDING #( entities MAPPING FROM ENTITY USING CONTROL ).

  ENDMETHOD.

  METHOD delete_item.

    LOOP AT keys INTO DATA(ls_key).
*
*      IF NOT exists( select 1 FROM ztb_poitem
*                       WHERE po_num = @ls_key-PoNum AND po_item = @ls_key-PoItem ).
*        APPEND VALUE #( %key = ls_key-%key
*                         %fail-cause = if_abap_behv=>cause-not_found ) TO failed.
*        CONTINUE.
*      ENDIF.
*
      APPEND CORRESPONDING #( ls_key MAPPING po_num = PoNum po_item = PoItem EXCEPT * ) TO gt_item_del.
*
    ENDLOOP.

*    gt_item_del = CORRESPONDING #( keys ).

*    failed-zi_po_items_dt = VALUE #( FOR ls_key IN keys
*                   ( %key-PoNum = ls_key-%key-PoNum
*                     %fail-cause = if_abap_behv=>cause-conflict ) ).
*
*    mapped-zi_po_items_dt = VALUE #( FOR ls_key IN keys
*                    ( %key-PoNum      = ls_key-%key-PoNum ) ).


  ENDMETHOD.


  METHOD get_instance.

    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                      THEN mo_instance
                                      ELSE NEW #( ) ).

  ENDMETHOD.

  METHOD savedata.


    IF gt_po_ins IS NOT INITIAL.
      INSERT ztb_pohead FROM TABLE @gt_po_ins.
    ENDIF.
    IF gt_po_upd IS NOT INITIAL.
      MODIFY ztb_pohead FROM TABLE @gt_po_upd.
    ENDIF.
    IF NOT gt_po_del[] IS INITIAL.
      DELETE ztb_pohead FROM TABLE @gt_po_del.
    ENDIF.

    IF gt_item_ins IS NOT INITIAL.
      INSERT ztb_poitems FROM TABLE @gt_item_ins.
    ENDIF.
    IF gt_item_upd IS NOT INITIAL.
      MODIFY ztb_poitems FROM TABLE @gt_item_upd.
    ENDIF.
    IF gt_item_del IS NOT INITIAL.
      DELETE ztb_poitems FROM TABLE @gt_item_del.
    ENDIF.

    CLEAR: gt_po_ins, gt_po_upd, gt_po_del,
           gt_item_ins, gt_item_upd, gt_item_del.

  ENDMETHOD.

ENDCLASS.
