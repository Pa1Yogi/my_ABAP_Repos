CLASS lhc_ZI_PO_HEADER_DT DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    TYPES tt_po_failed    TYPE TABLE FOR FAILED   zi_po_header_dt.
    TYPES tt_po_reported  TYPE TABLE FOR REPORTED zi_po_header_dt.
    TYPES tt_items_failed   TYPE TABLE FOR FAILED   zi_po_items_dt.
    TYPES tt_items_reported TYPE TABLE FOR REPORTED zi_po_items_dt.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_po_header_dt RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_po_header_dt RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_po_header_dt RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zi_po_header_dt.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_po_header_dt.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_po_header_dt.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_po_header_dt RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_po_header_dt.

    METHODS rba_Po_items FOR READ
      IMPORTING keys_rba FOR READ zi_po_header_dt\_Po_items FULL result_requested RESULT result LINK association_links.

    METHODS cba_Po_items FOR MODIFY
      IMPORTING entities_cba FOR CREATE zi_po_header_dt\_Po_items.

    METHODS Change_status FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_header_dt~Change_status RESULT result.

    METHODS Selected FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_header_dt~Selected RESULT result.

    METHODS map_messages
      IMPORTING
        cid          TYPE string         OPTIONAL
        po           TYPE ebeln OPTIONAL
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_po_failed
        reported     TYPE tt_po_reported.

    METHODS map_messages_assoc_to_items
      IMPORTING
        cid          TYPE string
        is_dependend TYPE abap_bool       DEFAULT  abap_false
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_items_failed
        reported     TYPE tt_items_reported.

ENDCLASS.

CLASS lhc_ZI_PO_HEADER_DT IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITY zi_po_header_dt
      FIELDS ( PoNum  )
      WITH VALUE #(
        FOR keyval IN keys (
          %key              = keyval-%key
        )
      )
      RESULT DATA(lt_po_result).
    result = VALUE #(
      FOR ls_po IN lt_po_result ( %key  = ls_po-%key
                                  %assoc-_PO_items = COND #( WHEN ls_po-Status = 'B'
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.

    DATA: messages TYPE /dmo/t_message,
          po_in    TYPE ztb_pohead,
          it_po_dt TYPE TABLE OF ztb_pohead,
          po_out   TYPE ztb_pohead.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<po_create>).

      po_in = CORRESPONDING #( <po_create> MAPPING FROM ENTITY USING CONTROL ).

      APPEND po_in TO it_po_dt.

*      "create po with insert statement
*      zcl_po_auxiliary=>create_po( im_po_dt = it_po_dt ).

      IF messages IS INITIAL.
        INSERT VALUE #( %cid = <po_create>-%cid  ponum = po_out-po_num ) INTO TABLE mapped-zi_po_header_dt.
      ELSE.
        zcl_po_auxiliary=>handle_po_messages(
          EXPORTING
            iv_cid       = <po_create>-%cid
            it_messages  = messages
          CHANGING
            failed       = failed-zi_po_header_dt
            reported     = reported-zi_po_header_dt
        ).
      ENDIF.

*      map_messages(
*          EXPORTING
*            cid       = <po_create>-%cid
*            messages  = messages
*          IMPORTING
*            failed_added = DATA(failed_added)
*          CHANGING
*            failed    = failed-zi_po_header_dt
*            reported  = reported-zi_po_header_dt
*        ).
*
*      IF failed_added = abap_false.
*        INSERT VALUE #(
*            %cid     = <po_create>-%cid
*            ponum = po_out-po_num )
*          INTO TABLE mapped-zi_po_header_dt.
*      ENDIF.

      zcl_po_dt=>get_instance( )->create_po(
        EXPORTING
             entities = entities
        CHANGING
             mapped   = mapped
             failed   = failed
             reported = reported ).

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    DATA lt_messages TYPE /dmo/t_message.
    DATA ls_po   TYPE ztb_pohead.
    DATA ls_pox  TYPE ztb_pohead. "refers to x structure (> BAPIs)
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_po_update>).
      ls_po = CORRESPONDING #( <fs_po_update> MAPPING FROM ENTITY ).
      ls_pox-po_num = <fs_po_update>-PoNum.

      "Update

      zcl_po_auxiliary=>handle_po_messages(
          EXPORTING
            iv_cid       = <fs_po_update>-%cid_ref
            po           = <fs_po_update>-PoNum
            it_messages  = lt_messages
          CHANGING
            failed       = failed-zi_po_header_dt
            reported     = reported-zi_po_header_dt
        ).

*      MODIFY ENTITIES OF zi_po_header_dt ENTITY zi_po_header_dt
*        UPDATE FIELDS ( Type  )
*        WITH VALUE #( ( Type = 'C' ) ).


       zcl_po_dt=>get_instance( )->update_po(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported ).

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    DATA lt_messages TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_po_delete>).

      "Delete Data

      zcl_po_auxiliary=>handle_po_messages(
          EXPORTING
            iv_cid       = <fs_po_delete>-%cid_ref
            po           = <fs_po_delete>-PoNum
            it_messages  = lt_messages
          CHANGING
            failed       = failed-zi_po_header_dt
            reported     = reported-zi_po_header_dt
        ).


    ENDLOOP.

    zcl_po_dt=>get_instance( )->delete_po(
        EXPORTING
             keys = keys
        CHANGING
             mapped   = mapped
             failed   = failed
             reported = reported ).

  ENDMETHOD.

  METHOD read.

    DATA: ls_po_out  TYPE ztb_pohead,
          lt_message TYPE /dmo/t_message.


*     READ ENTITY ZI_PO_HEADER_DT FIELDS ( PoNum CompCode )
*        WITH VALUE #( ( %key-PoNum =  ) )
*            RESULT   DATA(lt_received_PO_data)
*          FAILED   DATA(ls_failed).

    LOOP AT keys INTO DATA(ls_po_to_read) GROUP BY ls_po_to_read-%key.

      "Read data

      IF lt_message IS INITIAL.
        "fill result parameter with flagged fields
        INSERT CORRESPONDING #( ls_po_out MAPPING TO ENTITY ) INTO TABLE result.
      ELSE.
        "fill failed table in case of error
        failed-zi_po_header_dt = VALUE #( BASE failed-zi_po_header_dt FOR msg IN lt_message (
                                               %key = ls_po_to_read-%key
                                               %fail-cause = COND #(
                                                                WHEN msg-msgty = 'E' AND ( msg-msgno = '016' OR msg-msgno = '009' )
                                                                       THEN if_abap_behv=>cause-not_found
                                                                       ELSE if_abap_behv=>cause-unspecific )
                                                                                             )
                                        ).
      ENDIF.

    ENDLOOP.

*     DATA: lt_po_dt TYPE STANDARD TABLE OF ztb_pohead.
*
*    lt_po_dt = CORRESPONDING #( keys MAPPING po_num = PoNum EXCEPT * ).
*
*    IF lt_po_dt IS NOT INITIAL.
*      SELECT * FROM ztb_pohead
*        FOR ALL ENTRIES IN @lt_po_dt
*        WHERE po_num = @lt_po_dt-po_num
*        INTO TABLE @DATA(lt_result).
*    ENDIF.
*
*    result = CORRESPONDING #( lt_result MAPPING PoNum = po_num Status = status EXCEPT * ).
*
*    " flag not-found keys as failed
*    LOOP AT keys INTO DATA(ls_key).
*      READ TABLE result WITH KEY PoNum = ls_key-PoNum TRANSPORTING NO FIELDS.
*      IF sy-subrc <> 0.
*        APPEND VALUE #( %key = ls_key-%key
*                         %fail-cause = if_abap_behv=>cause-not_found ) TO failed.
*      ENDIF.
*    ENDLOOP.

  ENDMETHOD.

  METHOD lock.

*    TRY.
*        "Instantiate lock object
*        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = '/DMO/ETRAVEL' ).
*      CATCH cx_abap_lock_failure INTO DATA(lr_exp).
*        RAISE SHORTDUMP lr_exp.
*    ENDTRY.
*    LOOP AT keys   ASSIGNING FIELD-SYMBOL(<fs_po>).
*      TRY.
    "enqueue travel instance
*          lock->enqueue(
*              it_parameter  = VALUE #( (  name = 'TRAVEL_ID' value = REF #( <fs_po>-PoNum ) ) )
*          ).
*          "exception is raised if foreign lock exists
*        CATCH cx_abap_foreign_lock INTO DATA(lx_foreign_lock).
*
*          zcl_po_auxiliary=>handle_po_messages(
*        EXPORTING
*          po           = <fs_po>-PoNum
*          it_messages  = VALUE #( (
*                                            msgid = '/DMO/CM_FLIGHT_LEGAC'
*                                            msgty = 'E'
*                                            msgno = '032'
*                                            msgv1 = <fs_po>-PoNum
*                                            msgv2 = lx_foreign_lock->user_name ) )
*        CHANGING
*          failed       = failed-zi_po_header_dt
*          reported     = reported-zi_po_header_dt
*      ).

*
*        CATCH cx_abap_lock_failure INTO lr_exp.
*          RAISE SHORTDUMP lr_exp.
*      ENDTRY.
*    ENDLOOP.

*    READ ENTITIES OF zi_po_header_dt IN LOCAL MODE
*      ENTITY zi_po_header_dt
*        ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_result)
*      FAILED failed.

  ENDMETHOD.

  METHOD rba_Po_items.

    DATA: ls_po_out   TYPE ztb_pohead,
          lt_item_out TYPE TABLE OF ztb_poitems,
          ls_item     LIKE LINE OF result,
          lt_message  TYPE /dmo/t_message.

*     READ ENTITY zi_po_items_dt
*    BY \_po_hd FIELDS (  PoNum CompCode )
*    WITH VALUE #( ( %key-PoNum =  ) )
*    RESULT DATA(lt_read_itemss_ba)
*    LINK DATA(lt_link_table)
*    FAILED DATA(ls_failed_rba).

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<fs_po_rba>).
*      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
*        EXPORTING
*          iv_travel_id = <fs_travel_rba>-travelid
*        IMPORTING
*          es_travel    = ls_travel_out
*          et_booking   = lt_booking_out
*          et_messages  = lt_message
      .
      IF lt_message IS INITIAL.
        LOOP AT lt_item_out ASSIGNING FIELD-SYMBOL(<fs_item>).
          "fill link table with key fields
          INSERT
            VALUE #(
              source-%key = <fs_po_rba>-%key
              target-%key = VALUE #(
                ponum  = <fs_item>-po_num
                poitem = <fs_item>-po_item
              )
            )
            INTO TABLE association_links.

          "fill result parameter with flagged fields
          IF result_requested = abap_true.
            ls_item = CORRESPONDING #( <fs_item> MAPPING TO ENTITY ).
            ls_item-LocalLastChangedAt = ls_po_out-last_changed_at.
            INSERT ls_item INTO TABLE result.
          ENDIF.
        ENDLOOP.
      ELSE.
        "fill failed table in case of error
        failed-zi_po_header_dt = VALUE #( BASE failed-zi_po_header_dt FOR msg IN lt_message (
                               %key = <fs_po_rba>-PoNum
                               %fail-cause = COND #(
                                       WHEN msg-msgty = 'E' AND ( msg-msgno = '016' OR msg-msgno = '009' )
                                            THEN if_abap_behv=>cause-not_found
                                             ELSE if_abap_behv=>cause-unspecific
            )
          )
        ).
      ENDIF.

    ENDLOOP.

*    DATA: lt_keys TYPE STANDARD TABLE OF ztb_pohead.
*
*    lt_keys = CORRESPONDING #( keys_rba MAPPING po_num = PoNum EXCEPT * ).
*
*    IF lt_keys IS NOT INITIAL.
*      SELECT * FROM ztb_poitem
*        FOR ALL ENTRIES IN @lt_keys
*        WHERE po_num = @lt_keys-po_num
*        INTO TABLE @DATA(lt_items).
*    ENDIF.
*
*    result = CORRESPONDING #( lt_items
*      MAPPING PoNum = po_num PoItem = po_item Material = material Quantity = quantity EXCEPT * ).
*
*    association_links = VALUE #(
*      FOR ls_key IN keys_rba
*      ( source-%key = ls_key-%key
*        target      = VALUE #( FOR ls_item IN result WHERE ( PoNum = ls_key-PoNum )
*                                ( %key = ls_item-%key ) ) ) ).


  ENDMETHOD.

  METHOD cba_Po_items.

    DATA lt_messages        TYPE /dmo/t_message.
    DATA lt_item_old     TYPE tt_items_failed.
    DATA ls_item         TYPE ztb_poitems.
    DATA lv_last_item  TYPE ebelp VALUE '0'.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_item_create_ba>).
      DATA(lv_po) = <fs_item_create_ba>-PoNum.
*      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
*        EXPORTING
*          iv_travel_id = lv_travelid
*        IMPORTING
*          et_booking   = lt_booking_old
*          et_messages  = lt_messages.

      IF lt_messages IS INITIAL.
        IF lt_item_old IS NOT INITIAL.
          lv_last_item = lt_item_old[ lines( lt_item_old ) ]-PoItem.
        ENDIF.
        LOOP AT <fs_item_create_ba>-%target ASSIGNING FIELD-SYMBOL(<fs_item_create>).
          ls_item = CORRESPONDING #( <fs_item_create> MAPPING FROM ENTITY USING CONTROL ) .
          lv_last_item += 1.
          ls_item-po_item = lv_last_item.
*          CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
*            EXPORTING
*              is_travel   = VALUE /dmo/s_travel_in( travel_id = lv_travelid )
*              is_travelx  = VALUE /dmo/s_travel_inx( travel_id = lv_travelid )
*              it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( ls_booking ) ) )
*              it_bookingx = VALUE /dmo/t_booking_inx(
*                (
*                  booking_id  = ls_booking-booking_id
*                  action_code = /dmo/if_flight_legacy=>action_code-create
*                )
*              )
*            IMPORTING
*              et_messages = lt_messages.
          IF lt_messages IS INITIAL.
            INSERT
              VALUE #(
                %cid = <fs_item_create>-%cid
                ponum = lv_po
                poitem = ls_item-po_item
              )
              INTO TABLE mapped-zi_po_items_dt.
          ELSE.
            LOOP AT lt_messages INTO DATA(ls_message) WHERE msgty = 'E' OR msgty = 'A'.
              INSERT VALUE #( %cid = <fs_item_create>-%cid ) INTO TABLE failed-zi_po_items_dt.
              INSERT
                VALUE #(
                  %cid     = <fs_item_create>-%cid
                  ponum = <fs_item_create>-PoNum
                  %msg     = new_message(
                    id       = ls_message-msgid
                    number   = ls_message-msgno
                    severity = if_abap_behv_message=>severity-error
                    v1       = ls_message-msgv1
                    v2       = ls_message-msgv2
                    v3       = ls_message-msgv3
                    v4       = ls_message-msgv4
                  )
                )
                INTO TABLE reported-zi_po_items_dt.
            ENDLOOP.
          ENDIF.

        ENDLOOP.

      ELSE.

        zcl_po_auxiliary=>handle_po_messages(
         EXPORTING
           iv_cid       = <fs_item_create_ba>-%cid_ref
           po           = lv_po
           it_messages  = lt_messages
         CHANGING
           failed       = failed-zi_po_header_dt
           reported     = reported-zi_po_header_dt
       ).


      ENDIF.
    ENDLOOP.

*    DATA: lt_item_create TYPE TABLE FOR CREATE zi_po_items_dt.
*
*    LOOP AT entities_cba INTO DATA(ls_cba).
*      LOOP AT ls_cba-%target INTO DATA(ls_item).
*        APPEND VALUE #( %cid     = ls_item-%cid
*                         %key-PoNum = ls_cba-PoNum
*                         PoNum    = ls_cba-PoNum
*                         PoItem   = ls_item-PoItem
*                         Material = ls_item-Material
*                         Quantity = ls_item-Quantity
*                         %control = ls_item-%control ) TO lt_item_create.
*      ENDLOOP.
*
    zcl_po_dt=>get_instance( )->create_item(
    EXPORTING
      entities = entities_cba
    CHANGING
      mapped   = mapped
      failed   = failed
      reported = reported ).

  ENDMETHOD.

  METHOD Change_status.
  ENDMETHOD.

  METHOD Selected.
  ENDMETHOD.

  METHOD map_messages.

  ENDMETHOD.

  METHOD map_messages_assoc_to_items.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_PO_ITEMS_DT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_po_items_dt.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_po_items_dt.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_po_items_dt RESULT result.

    METHODS rba_Po_hd FOR READ
      IMPORTING keys_rba FOR READ zi_po_items_dt\_Po_hd FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_ZI_PO_ITEMS_DT IMPLEMENTATION.

  METHOD update.

    DATA lt_messages TYPE /dmo/t_message.
    DATA ls_items  TYPE ztb_poitems.
*    DATA ls_itesx TYPE /dmo/s_booking_inx.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_items_update>).
      ls_items = CORRESPONDING #( <fs_items_update> MAPPING FROM ENTITY ).
*      ls_bookingx-booking_id = <fs_booking_update>-BookingID.
*      ls_bookingx-_intx      = CORRESPONDING #( <fs_booking_update> MAPPING FROM ENTITY ).
*      ls_bookingx-action_code = /dmo/if_flight_legacy=>action_code-update.

*      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
*        EXPORTING
*          is_travel   = VALUE /dmo/s_travel_in( travel_id = <fs_booking_update> travelid )
*          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <fs_booking_update> travelid )
*          it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( ls_booking ) ) )
*          it_bookingx = VALUE /dmo/t_booking_inx( ( ls_bookingx ) )
*        IMPORTING
*          et_messages = lt_messages.

      zcl_po_auxiliary=>handle_item_messages(
      EXPORTING
        iv_cid       = <fs_items_update>-%cid_ref
        po           = <fs_items_update>-PoNum
        item         = <fs_items_update>-PoItem
        it_messages  = lt_messages
      CHANGING
        failed       = failed-zi_po_items_dt
        reported     = reported-zi_po_items_dt ).

    ENDLOOP.

    zcl_po_dt=>get_instance( )->update_item(
     EXPORTING
       entities = entities
     CHANGING
       mapped   = mapped
       failed   = failed
       reported = reported ).

  ENDMETHOD.

  METHOD delete.

    DATA messages TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<item>).

*      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
*        EXPORTING
*          is_travel   = VALUE /dmo/s_travel_in( travel_id = <booking>-travelid )
*          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <booking>-travelid )
*          it_booking  = VALUE /dmo/t_booking_in( ( booking_id = <booking>-bookingid ) )
*          it_bookingx = VALUE /dmo/t_booking_inx( ( booking_id  = <booking>-bookingid
*                                                    action_code = /dmo/if_flight_legacy=>action_code-delete ) )
*        IMPORTING
*          et_messages = messages.

      zcl_po_auxiliary=>handle_item_messages(
    EXPORTING
      iv_cid       = <item>-%cid_ref
      po           = <item>-PoNum
      item         = <item>-PoItem
      it_messages  = messages
    CHANGING
      failed       = failed-zi_po_items_dt
      reported     = reported-zi_po_items_dt ).

    ENDLOOP.

    zcl_po_dt=>get_instance( )->delete_item(
      EXPORTING
        keys = keys
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported ).



  ENDMETHOD.

  METHOD read.

    DATA: ls_po_out  TYPE ztb_pohead,
*          lt_item_out TYPE ztb_poitems,
          lt_message TYPE /dmo/t_message.
    "Only one function call for each requested travelid
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_po_read>) GROUP BY <fs_po_read>-PoNum .

*      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
*        EXPORTING
*          iv_travel_id = <fs_travel_read>-travelid
*        IMPORTING
*          es_travel    = ls_travel_out
*          et_booking   = lt_booking_out
*          et_messages  = lt_message.

      IF lt_message IS INITIAL.
        "For each travelID find the requested bookings
*        LOOP AT GROUP <fs_po_read> ASSIGNING FIELD-SYMBOL(<fs_item_read>) GROUP BY <fs_item_read>-%key.
*          READ TABLE lt_booking_out INTO DATA(ls_booking) WITH KEY travel_id  = <fs_booking_read>-%key-TravelID
*                                                                   booking_id = <fs_booking_read>-%key-BookingID .
*          "if read was successfull
*          IF sy-subrc = 0.
*            "fill result parameter with flagged fields
*            INSERT
*              VALUE #( travelid      =   ls_booking-travel_id
*                       bookingid     =   ls_booking-booking_id
*                       bookingdate   =   COND #( WHEN <fs_booking_read>-%control BookingDate      = cl_abap_behv=>flag_changed THEN ls_booking-booking_date   )
*                       customerid    =   COND #( WHEN <fs_booking_read>-%control CustomerID       = cl_abap_behv=>flag_changed THEN ls_booking-customer_id    )
*                       airlineid     =   COND #( WHEN <fs_booking_read>-%control AirlineID        = cl_abap_behv=>flag_changed THEN ls_booking-carrier_id     )
*                       connectionid  =   COND #( WHEN <fs_booking_read>-%control ConnectionID     = cl_abap_behv=>flag_changed THEN ls_booking-connection_id  )
*                       flightdate    =   COND #( WHEN <fs_booking_read>-%control FlightDate       = cl_abap_behv=>flag_changed THEN ls_booking-flight_date    )
*                       flightprice   =   COND #( WHEN <fs_booking_read>-%control FlightPrice      = cl_abap_behv=>flag_changed THEN ls_booking-flight_price   )
*                       currencycode  =   COND #( WHEN <fs_booking_read>-%control CurrencyCode     = cl_abap_behv=>flag_changed THEN ls_booking-currency_code  )
**                       lastchangedat =   COND #( WHEN <fs_booking_read> %control-LastChangedAt    = cl_abap_behv=>flag_changed THEN ls_travel_out lastchangedat   )
*                     ) INTO TABLE et_booking.
*                      ELSE.
*            "BookingID not found
*            INSERT
*              VALUE #( travelid    = <fs_booking_read>-TravelID
*                       bookingid   = <fs_booking_read>-BookingID
*                       %fail-cause = if_abap_behv=>cause-not_found )
*              INTO TABLE failed-booking.
*          ENDIF.
*        ENDLOOP.
      ELSE.
        "TravelID not found or other fail cause
*        LOOP AT GROUP <fs_po_read> ASSIGNING <fs_item_read>.
*          failed-zi_po_items_dt = VALUE #(  BASE failed-zi_po_items_dt
*                                     FOR msg IN lt_message ( %key-PoNum    = <fs_item_read>-po
*                                                             %key-PoItem   = <fs_item_read>-poitem
*                                                             %fail-cause      =
*           COND #( WHEN ( msg-msgty = 'E' AND msg-msgno = '016' OR msg-msgno = '009')
*                         THEN if_abap_behv=>cause-not_found
*                             ELSE if_abap_behv=>cause-unspecific ) ) ).
*        ENDLOOP.
      ENDIF.
    ENDLOOP.

*     DATA: lt_keys TYPE STANDARD TABLE OF ztb_poitem.
*
*    lt_keys = CORRESPONDING #( keys MAPPING po_num = PoNum po_item = PoItem EXCEPT * ).
*
*    IF lt_keys IS NOT INITIAL.
*      SELECT * FROM ztb_poitem
*        FOR ALL ENTRIES IN @lt_keys
*        WHERE po_num  = @lt_keys-po_num
*          AND po_item = @lt_keys-po_item
*        INTO TABLE @DATA(lt_result).
*    ENDIF.
*
*    result = CORRESPONDING #( lt_result
*      MAPPING PoNum = po_num PoItem = po_item Material = material Quantity = quantity EXCEPT * ).
*
*    LOOP AT keys INTO DATA(ls_key).
*      READ TABLE result WITH KEY PoNum = ls_key-PoNum PoItem = ls_key-PoItem TRANSPORTING NO FIELDS.
*      IF sy-subrc <> 0.
*        APPEND VALUE #( %key = ls_key-%key
*                         %fail-cause = if_abap_behv=>cause-not_found ) TO failed.
*      ENDIF.
*    ENDLOOP.

  ENDMETHOD.

  METHOD rba_Po_hd.

    DATA: ls_po_out  TYPE ztb_pohead,
*          lt_item_out TYPE /dmo/t_booking,
*          ls_po      LIKE LINE OF et_travel,
          lt_message TYPE /dmo/t_message.
    "Only one function call for each requested travelid
    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<fs_po>) GROUP BY <fs_po>-PoNum.

*      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
*        EXPORTING
*          iv_travel_id = <fs_travel>-%key-TravelID
*        IMPORTING
*          es_travel    = ls_travel_out
*          et_messages  = lt_message.

      IF lt_message IS INITIAL.
        LOOP AT GROUP <fs_po> ASSIGNING FIELD-SYMBOL(<fs_item>).
          "fill link table with key fields
*          INSERT VALUE #( source-%key = <fs_booking>-%key target-%key = ls_travel_out-travel_id ) INTO TABLE association_links.
          IF result_requested = abap_true.
            "fill result parameter with flagged fields
*            ls_travel = CORRESPONDING #(  ls_travel_out MAPPING TO ENTITY ).
*            INSERT ls_travel INTO TABLE et_travel.
          ENDIF.
        ENDLOOP.
      ELSE. "fill failed table in case of error
        failed-zi_po_items_dt = VALUE #(  BASE failed-zi_po_items_dt
                              FOR msg IN lt_message ( %key-PoNum    = <fs_po>-%key-PoNum
                                                      %key-PoItem   = <fs_po>-%key-PoItem
                                                      %fail-cause      = COND
           #( WHEN ( msg-msgty = 'E' AND msg-msgno = '016' OR msg-msgno = '009' )
                                 THEN if_abap_behv=>cause-not_found
                                 ELSE if_abap_behv=>cause-unspecific ) ) ).
      ENDIF.
    ENDLOOP.

*    DATA: lt_keys TYPE STANDARD TABLE OF ztb_pohead.
*
*    lt_keys = CORRESPONDING #( keys_rba MAPPING po_num = PoNum EXCEPT * ).
*
*    IF lt_keys IS NOT INITIAL.
*      SELECT * FROM ztb_pohead
*        FOR ALL ENTRIES IN @lt_keys
*        WHERE po_num = @lt_keys-po_num
*        INTO TABLE @DATA(lt_header).
*    ENDIF.
*
*    result = CORRESPONDING #( lt_header MAPPING PoNum = po_num Status = status EXCEPT * ).
*
*    association_links = VALUE #(
*      FOR ls_key IN keys_rba
*      ( source-%key = ls_key-%key
*        target      = VALUE #( FOR ls_hd IN result WHERE ( PoNum = ls_key-PoNum )
*                                ( %key = ls_hd-%key ) ) ) ).


  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_PO_HEADER_DT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_PO_HEADER_DT IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    "Save the data
    zcl_po_dt=>get_instance( )->savedata(
   CHANGING
     reported = reported
 ).
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
