CLASS zcl_po_auxiliary DEFINITION
   INHERITING FROM cl_abap_behv
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES tt_po_failed    TYPE TABLE FOR FAILED   zi_po_header_dt.
    TYPES tt_po_reported  TYPE TABLE FOR REPORTED zi_po_header_dt.
    TYPES tt_items_failed   TYPE TABLE FOR FAILED   zi_po_items_dt.
    TYPES tt_items_reported TYPE TABLE FOR REPORTED zi_po_items_dt.
    TYPES tt_po_dt TYPE TABLE OF ztb_pohead.

    CLASS-METHODS handle_po_messages
      IMPORTING
        iv_cid      TYPE string   OPTIONAL
        po          TYPE ebeln OPTIONAL
        it_messages TYPE /dmo/t_message
      CHANGING
        failed      TYPE tt_po_failed
        reported    TYPE tt_po_reported.

    CLASS-METHODS handle_item_messages
      IMPORTING
        iv_cid      TYPE string   OPTIONAL
        po          TYPE ebeln OPTIONAL
        item        TYPE ebelp OPTIONAL
        it_messages TYPE /dmo/t_message
      CHANGING
        failed      TYPE tt_items_failed
        reported    TYPE tt_items_reported.

    CLASS-METHODS create_po
      IMPORTING
        im_po_dt TYPE tt_po_dt.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA obj TYPE REF TO zcl_po_auxiliary.
    CLASS-METHODS get_message_object
      RETURNING VALUE(r_result) TYPE REF TO zcl_po_auxiliary.

ENDCLASS.



CLASS zcl_po_auxiliary IMPLEMENTATION.

  METHOD get_message_object.

    IF obj IS INITIAL.
      CREATE OBJECT obj.
    ENDIF.
    r_result = obj.

  ENDMETHOD.

  METHOD handle_po_messages.

    LOOP AT it_messages INTO DATA(ls_message) WHERE msgty = 'E' OR msgty = 'A'.
      APPEND VALUE #( %cid = iv_cid  ponum = po ) TO failed.
      APPEND VALUE #( %msg      = get_message_object( )->new_message( id       = ls_message-msgid
                                               number   = ls_message-msgno
                                               severity = if_abap_behv_message=>severity-error
                                               v1       = ls_message-msgv1
                                               v2       = ls_message-msgv2
                                               v3       = ls_message-msgv3
                                               v4       = ls_message-msgv4 )
                      %key-PoNum  = po
                      %cid          = iv_cid
                      PoNum      = po ) TO reported.

    ENDLOOP.

  ENDMETHOD.

  METHOD handle_item_messages.

    LOOP AT it_messages INTO DATA(ls_message) WHERE msgty = 'E' OR msgty = 'A'.
      APPEND VALUE #( %cid = iv_cid  ponum = po ) TO failed.
      APPEND VALUE #( %msg      = get_message_object( )->new_message( id       = ls_message-msgid
                                               number   = ls_message-msgno
                                               severity = if_abap_behv_message=>severity-error
                                               v1       = ls_message-msgv1
                                               v2       = ls_message-msgv2
                                               v3       = ls_message-msgv3
                                               v4       = ls_message-msgv4 )
                      %key-PoNum  = po
                      %cid          = iv_cid
                      PoNum      = po
                      poitem = item ) TO reported.

    ENDLOOP.

  ENDMETHOD.

  METHOD create_po.
    MODIFY ztb_pohead FROM TABLE @im_po_dt.
  ENDMETHOD.

ENDCLASS.
