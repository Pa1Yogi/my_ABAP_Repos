CLASS zcl_po_dt_auxiliary DEFINITION
    INHERITING FROM cl_abap_behv
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES tt_po_failed    TYPE TABLE FOR FAILED   zr_po_hd_dt_d.
    TYPES tt_po_reported  TYPE TABLE FOR REPORTED zr_po_hd_dt_d.
    TYPES tt_items_failed   TYPE TABLE FOR FAILED   zr_po_is_dt_d.
    TYPES tt_items_reported TYPE TABLE FOR REPORTED zr_po_is_dt_d.
    TYPES tt_po_dt TYPE TABLE OF ztb_a_po_hd_d.

    CLASS-METHODS handle_po_messages
      IMPORTING
        iv_cid       TYPE string   OPTIONAL
        po           TYPE ebeln OPTIONAL
        po_uuid      TYPE sysuuid_x16 OPTIONAL
        it_messages  TYPE /dmo/t_message
        create       TYPE  abap_bool       DEFAULT  abap_false
        update       TYPE  abap_bool       DEFAULT  abap_false
        delete       TYPE  abap_bool       DEFAULT  abap_false
        itemcreate   TYPE  abap_bool       DEFAULT  abap_false
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_po_failed
        reported     TYPE tt_po_reported.

    CLASS-METHODS handle_item_messages
      IMPORTING
        iv_cid       TYPE string   OPTIONAL
        po           TYPE ebeln OPTIONAL
        item         TYPE ebelp OPTIONAL
        po_item_uuid TYPE sysuuid_x16 OPTIONAL
        it_messages  TYPE /dmo/t_message
        is_dependend TYPE abap_bool       DEFAULT  abap_false
        create       TYPE  abap_bool       DEFAULT  abap_false
        update       TYPE  abap_bool       DEFAULT  abap_false
        delete       TYPE  abap_bool       DEFAULT  abap_false
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_items_failed
        reported     TYPE tt_items_reported.

    CLASS-METHODS get_cause_from_message
      IMPORTING
        msgid             TYPE symsgid
        msgno             TYPE symsgno
        is_dependend      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(fail_cause) TYPE if_abap_behv=>t_fail_cause.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA obj TYPE REF TO zcl_po_dt_auxiliary.
    CLASS-METHODS get_message_object
      RETURNING VALUE(r_result) TYPE REF TO zcl_po_dt_auxiliary.

ENDCLASS.



CLASS zcl_po_dt_auxiliary IMPLEMENTATION.

  METHOD get_message_object.

    IF obj IS INITIAL.
      CREATE OBJECT obj.
    ENDIF.
    r_result = obj.

  ENDMETHOD.

  METHOD handle_po_messages.
    failed_added = abap_false.

    IF ( NOT line_exists( failed[ KEY entity COMPONENTS %cid = iv_cid  PoNum = po ] ) ).
      LOOP AT it_messages INTO DATA(ls_message) WHERE msgty = 'E' OR msgty = 'A'.

*      IF ( ls_message-msgty = 'E' OR ls_message-msgty = 'A' ) AND

        APPEND VALUE #( %cid = iv_cid
                        %tky-ponum = po
                        %tky-pouuid = po_uuid

                        %fail-cause = get_cause_from_message( msgid        = ls_message-msgid
                                                              msgno        = ls_message-msgno
*                                                                  is_dependend = abap_false
                                                                ) )
                     TO failed.

        APPEND VALUE #( %msg      = get_message_object( )->new_message( id       = ls_message-msgid
                                                 number   = ls_message-msgno
                                                 severity = if_abap_behv_message=>severity-error
                                                 v1       = ls_message-msgv1
                                                 v2       = ls_message-msgv2
                                                 v3       = ls_message-msgv3
                                                 v4       = ls_message-msgv4 )
*                      %key-PoNum  = po
                        %cid          = iv_cid
                        %tky-PoNum      = po
                        %tky-pouuid = po_uuid )
                      TO reported.

        failed_added = abap_true.
      ENDLOOP.
    ENDIF.

    IF failed_added = abap_false AND itemcreate = abap_false.
      INSERT VALUE #( %cid = iv_cid
                      %tky-ponum = po
                      %tky-pouuid = po_uuid
                      %msg = get_message_object( )->new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                                           text     = COND #( WHEN create THEN 'PO Created'
                                                                                              WHEN update THEN 'PO Updated'
                                                                                              WHEN delete THEN 'PO Deleted'  ) ) )
                   INTO TABLE reported.
    ENDIF.

  ENDMETHOD.

  METHOD handle_item_messages.
    failed_added = abap_false.

    IF ( NOT line_exists( failed[ KEY entity COMPONENTS %cid = iv_cid  PoNum = po PoItem = item ] ) ).
      LOOP AT it_messages INTO DATA(ls_message) WHERE msgty = 'E' OR msgty = 'A'.

*      IF ( ls_message-msgty = 'E' OR ls_message-msgty = 'A' ) AND
        APPEND VALUE #( %cid = iv_cid
                        %tky-ponum = po
                        %tky-poitem = item
                        %tky-poitemuuid = po_item_uuid
                        %fail-cause = get_cause_from_message( msgid        = ls_message-msgid
                                                              msgno        = ls_message-msgno
*                                                                  is_dependend = abap_false
                                                                ) )
                       TO failed.

        APPEND VALUE #( %msg      = get_message_object( )->new_message( id       = ls_message-msgid
                                                 number   = ls_message-msgno
                                                 severity = if_abap_behv_message=>severity-error
                                                 v1       = ls_message-msgv1
                                                 v2       = ls_message-msgv2
                                                 v3       = ls_message-msgv3
                                                 v4       = ls_message-msgv4 )
*                      %key-PoNum  = po
                        %cid          = iv_cid
                        %tky-PoNum      = po
                        %tky-poitem = item
                        %tky-poitemuuid = po_item_uuid )
                       TO reported.

        failed_added = abap_true.
      ENDLOOP.
    ENDIF.

    IF failed_added = abap_false.
      INSERT VALUE #( %cid = iv_cid
                      %tky-ponum = po
                      %tky-poitem = item
                      %tky-poitemuuid = po_item_uuid
                      %msg = get_message_object( )->new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                                           text     = COND #( WHEN create THEN 'Item Created'
                                                                                              WHEN update THEN 'Item Updated'
                                                                                              WHEN delete THEN 'Item Deleted' ) )  )
                   INTO TABLE reported.
    ENDIF.

  ENDMETHOD.

  METHOD get_cause_from_message.
    fail_cause = if_abap_behv=>cause-unspecific.

    IF msgid = 'ZMSG_PO'.
      CASE msgno.
        WHEN '009'  "PO Key initial
          OR '016'  "PO does not exist
          OR '017'.  "Item does not exist
          IF is_dependend = abap_true.
            fail_cause = if_abap_behv=>cause-dependency.
          ELSE.
            fail_cause = if_abap_behv=>cause-not_found.
          ENDIF.
        WHEN '032'. "PO is locked by
          fail_cause = if_abap_behv=>cause-locked.
        WHEN '046'. "You are not authorized
          fail_cause = if_abap_behv=>cause-unauthorized.
      ENDCASE.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
