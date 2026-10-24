CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_features FOR GLOBAL FEATURES
      REQUEST requested_features FOR Item RESULT result.
    METHODS validateStorLoc FOR VALIDATE ON SAVE
       keys FOR Item~validateStorLoc.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD get_global_features.

*    result = VALUE #(
*                         %update = if_abap_behv=>fc-o-disabled
*                     ).

  ENDMETHOD.

  METHOD validateStorLoc.

    DATA lo_msgs TYPE REF TO if_abap_behv_message.

    lo_msgs = me->new_message( id = 'Z_MSG_CLASS' number = 001 severity = ms-error v1 = 'Storage Location Not Allowed' ).

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
             ENTITY Item
             ALL FIELDS
             WITH CORRESPONDING #( keys )
             RESULT DATA(po_item_check).

    LOOP AT po_item_check INTO DATA(ls_po_item_check).
      IF ls_po_item_check-Storloc NE '1000'.

*        APPEND VALUE #( %tky = ls_po_item_check-%tky ) TO failed-header.
*        failed-header = VALUE #( ( %tky = ls_po_item_check-%tky ) ).
*        APPEND VALUE #( %key = ls_po_item_check-%key ) TO failed-header.
        APPEND VALUE #(  Ponum  = ls_po_item_check-Ponum PoItem = ls_po_item_check-PoItem ) TO failed-item.

        APPEND VALUE #(
                           %tky = ls_po_item_check-%tky
*                         Ponum  = ls_po_item_check-Ponum
*                         PoItem = ls_po_item_check-PoItem
*                          %state_area = 'Storloc'
                   "     %key  = ls_pos_check-%key-PoNum
                        %element-Storloc = if_abap_behv=>mk-on
                        %path = VALUE #( header-Ponum = ls_po_item_check-Ponum )
                        %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text =  'Storage Location Not Allowed' )

*                                 new_message(
*                                    id       = 'Z_MSG_CLASS'
*                                    number   = 001
*                                    severity = ms-error
*                                    v1       = 'Storage Location Not Allowed'
*                                    v2       =
*                                    v3       =
*                                    v4       =
*                                  )

                               "lo_msgs

                               "  NEW zcx_po( severity = if_abap_behv_message=>severity-error
                                "            textid =  zcx_po=>type_unknown
                                 "           Storloc = ls_po_item_check-Storloc )
                       )
        TO reported-item.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_po_head_dt_d DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zr_po_head_dt_d IMPLEMENTATION.

  METHOD adjust_numbers.

    DATA: lv_po_max TYPE n LENGTH 10.
    DATA: max_item TYPE ebelp.

    DATA(lv_count) = REDUCE i( INIT x = 0
                                FOR <hdr> IN mapped-header WHERE ( PoNum IS INITIAL )
                                NEXT x = x + 1 ).

    IF lv_count > 0.

      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = 'ZNUM_OB_PO'
              quantity          = CONV #( lv_count )
            IMPORTING
              number            = DATA(lv_number)
              returncode        = DATA(lv_rc)
              returned_quantity = DATA(lv_ret_qty)
          ).
        CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(lx_nr).
          RETURN.
      ENDTRY.

      lv_po_max = lv_number - lv_ret_qty + 1.
    ENDIF.

    LOOP AT mapped-header ASSIGNING FIELD-SYMBOL(<header>) WHERE PoNum IS INITIAL.
      <header>-PoNum = lv_po_max.
      TRY.
          <header>-PoUuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.
    ENDLOOP.

    IF mapped-header IS INITIAL.
      SELECT * FROM ztb_a_po_items_d FOR ALL ENTRIES IN @mapped-item
                WHERE po_num EQ @mapped-item-%tmp-PoNum
                INTO TABLE @DATA(lt_items).

      max_item = REDUCE #( INIT max = CONV ebelp( '0' )
                                 FOR  ls_item1 IN lt_items
                                 NEXT max = COND ebelp( WHEN ls_item1-po_item > max
                                                                    THEN ls_item1-po_item
                                                                    ELSE max )  ).
    ENDIF.

    LOOP AT mapped-item ASSIGNING FIELD-SYMBOL(<item>).

      max_item += 10.
      <item>-PoNum      = <item>-%tmp-PoNum.
      <item>-PoItem     = max_item.

      TRY.
          <item>-PoItemUuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZR_PO_HEAD_DT_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Header RESULT result.

    METHODS CopyPO FOR MODIFY
       keys FOR ACTION Header~CopyPO.
    METHODS CreatePO FOR MODIFY
       keys FOR ACTION Header~CreatePO.
    METHODS Approved FOR MODIFY
       keys FOR ACTION Header~Approved RESULT result.
    METHODS ChangePOStatus FOR MODIFY
       keys FOR ACTION Header~ChangePOStatus.
    METHODS Selected FOR MODIFY
       keys FOR ACTION Header~Selected RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Header RESULT result.
    METHODS get_global_features FOR GLOBAL FEATURES
      REQUEST requested_features FOR header RESULT result.
    METHODS checktype FOR VALIDATE ON SAVE
       keys FOR header~checktype.
    METHODS updateorg FOR DETERMINE ON SAVE
       keys FOR header~updateorg.
    METHODS updateorg1 FOR DETERMINE ON MODIFY
       keys FOR header~updateorg1.
    METHODS setinitialvalues FOR DETERMINE ON SAVE
       keys FOR header~setinitialvalues.
    METHODS setinitialvalues1 FOR DETERMINE ON MODIFY
       keys FOR header~setinitialvalues1.
    METHODS updateVendor FOR DETERMINE ON MODIFY
       keys FOR header~updateVendor.
    METHODS updateStatus FOR DETERMINE ON MODIFY
       keys FOR Header~updateStatus.
    METHODS updateOrg2 FOR DETERMINE ON SAVE
       keys FOR Header~updateOrg2.
    METHODS precheck_create FOR PRECHECK
       entities FOR CREATE Header.

    METHODS precheck_update FOR PRECHECK
       entities FOR UPDATE Header.
    METHODS Resume FOR MODIFY
       keys FOR ACTION Header~Resume.

*    METHODS earlynumbering_create FOR NUMBERING
*       entities FOR CREATE Header.

*    METHODS earlynumbering_cba_Items FOR NUMBERING
*       entities FOR CREATE Header\_Items.

    METHODS is_create_granted
      IMPORTING approved              TYPE abap_bool OPTIONAL
      RETURNING VALUE(create_granted) TYPE abap_bool.
    METHODS is_update_granted
      IMPORTING approved              TYPE abap_bool OPTIONAL
      RETURNING VALUE(update_granted) TYPE abap_bool.
    METHODS is_delete_granted
      IMPORTING approved              TYPE abap_bool OPTIONAL
      RETURNING VALUE(delete_granted) TYPE abap_bool.

    TYPES:
      t_entities_create TYPE TABLE FOR CREATE zr_po_head_dt_d\\Header,
      t_entities_update TYPE TABLE FOR UPDATE zr_po_head_dt_d\\Header,
      t_failed_travel   TYPE TABLE FOR FAILED   EARLY zr_po_head_dt_d\\Header,
      t_reported_travel TYPE TABLE FOR REPORTED EARLY zr_po_head_dt_d\\Header.

    METHODS precheck_auth
      IMPORTING
        entities_create TYPE t_entities_create OPTIONAL
        entities_update TYPE t_entities_update OPTIONAL
      CHANGING
        failed          TYPE t_failed_travel
        reported        TYPE t_reported_travel.

ENDCLASS.

CLASS lhc_ZR_PO_HEAD_DT_D IMPLEMENTATION.

  METHOD get_instance_authorizations.

    DATA: update_requested TYPE abap_bool,
          delete_requested TYPE abap_bool,
          update_granted   TYPE abap_bool,
          delete_granted   TYPE abap_bool.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
      ENTITY Header
        FIELDS ( Approved )
        WITH CORRESPONDING #( keys )
        RESULT DATA(it_pos)
      FAILED failed.

    CHECK it_pos IS NOT INITIAL.

    "edit is treated like update
    update_requested = COND #( WHEN requested_authorizations-%update      = if_abap_behv=>mk-on
                                 OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                               THEN abap_true ELSE abap_false ).

    delete_requested = COND #( WHEN requested_authorizations-%delete      = if_abap_behv=>mk-on
                               THEN abap_true ELSE abap_false ).


    LOOP AT it_pos INTO DATA(ls_po).

      "check auth for update
      IF update_requested = abap_true.
        update_granted = is_update_granted( ls_po-Approved  ).
        IF update_granted = abap_false.
          APPEND VALUE #( %tky = ls_po-%tky
                          %msg = NEW zcl_po_messages(
                                                   textid    = zcl_po_messages=>not_authorized_for_approve
                                                   approve = ls_po-Approved
                                                   severity  = if_abap_behv_message=>severity-error )

                          %element-Approved = if_abap_behv=>mk-on
                         ) TO reported-header.
        ENDIF.
      ENDIF.

      "check auth for delete
      IF delete_requested = abap_true.
        delete_granted = is_delete_granted( ls_po-Approved ).
        IF delete_granted = abap_false.
          APPEND VALUE #( %tky = ls_po-%tky
                          %msg = NEW zcl_po_messages(
                                                   textid    = zcl_po_messages=>not_authorized_for_approve
                                                   approve = ls_po-Approved
                                                   severity  = if_abap_behv_message=>severity-error )
                          %element-Approved = if_abap_behv=>mk-on
                         ) TO reported-header.
        ENDIF.
      ENDIF.

      " operations on draft instances and on active instances that have no persistent before ( Update on newly created instance)
      " create authorization is checked, for newly created instances
*      update_granted = delete_granted = is_create_granted( ).
*      IF update_granted = abap_false.
*        APPEND VALUE #( %tky = ls_po-%tky
*                        %msg = NEW zcl_po_messages(
*                                                   textid    = zcl_po_messages=>not_authorized_for_approve
*                                                   approve = ls_po-Approved
*                                                   severity  = if_abap_behv_message=>severity-error )
*                        %element-Approved = if_abap_behv=>mk-on
*                      ) TO reported-header.
*      ENDIF.

      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted = abap_true
                                             THEN if_abap_behv=>auth-allowed
                                             ELSE if_abap_behv=>auth-unauthorized )
                          del_auth = COND #( WHEN delete_granted = abap_true
                                             THEN if_abap_behv=>auth-allowed
                                             ELSE if_abap_behv=>auth-unauthorized )
                      IN
                       %tky = ls_po-%tky
                       %update                = upd_auth
                       %action-Edit           = upd_auth

                       %delete                = del_auth
                    ) TO result.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.

    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.
      IF is_create_granted( ) = abap_true.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg    = NEW /dmo/cm_flight_messages(
                                       textid   = zcl_po_messages=>not_authorized
                                       severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-header.

      ENDIF.
    ENDIF.

    "Edit is treated like update
    IF requested_authorizations-%update                =  if_abap_behv=>mk-on OR
       requested_authorizations-%action-Edit           =  if_abap_behv=>mk-on
.

      IF  is_update_granted( ) = abap_true.
        result-%update                =  if_abap_behv=>auth-allowed.
        result-%action-Edit           =  if_abap_behv=>auth-allowed.

      ELSE.
        result-%update                =  if_abap_behv=>auth-unauthorized.
        result-%action-Edit           =  if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg    = NEW /dmo/cm_flight_messages(
                                       textid   = zcl_po_messages=>not_authorized
                                       severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on )
          TO reported-header.

      ENDIF.
    ENDIF.


    IF requested_authorizations-%delete =  if_abap_behv=>mk-on.
      IF is_delete_granted( ) = abap_true.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg    = NEW /dmo/cm_flight_messages(
                                       textid   = zcl_po_messages=>not_authorized
                                       severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-header.
      ENDIF.
    ENDIF.

  ENDMETHOD.


*  METHOD earlynumbering_create.
*    DATA: lv_po_max TYPE n LENGTH 10.
*
*    " Ensure PO Num is not set yet (idempotent)- must be checked when BO is draft-enabled
*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>) WHERE PoNum IS NOT INITIAL.
*      APPEND CORRESPONDING #( <lfs_entities> ) TO mapped-header.
*    ENDLOOP.
*
*    DATA(lt_entities) = entities.
*    DELETE lt_entities WHERE PoNum IS NOT INITIAL.
*
*    TRY.
*        cl_numberrange_runtime=>number_get(
*          EXPORTING
**          ignore_buffer     =
*            nr_range_nr       =   '01'
*            object            =  'ZNUM_OB_PO'
*            quantity          = CONV #( lines( lt_entities ) )
**          subobject         =
**          toyear            =
*          IMPORTING
*            number            =  DATA(number_range_key)
*            returncode        = DATA(number_range_return_code)
*            returned_quantity = DATA(number_range_returned_quantity)
*        ).
*
*
*      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(lx_number_ranges).
*        "Exception Handling
*        LOOP AT lt_entities ASSIGNING <lfs_entities>.
*          APPEND VALUE #( %cid = <lfs_entities>-%cid
*                          %key = <lfs_entities>-%key
*                          %msg = lx_number_ranges
*                        ) TO reported-header.
*          APPEND VALUE #( %cid = <lfs_entities>-%cid
*                          %key = <lfs_entities>-%key
*                        ) TO failed-header.
*        ENDLOOP.
*        EXIT.
*    ENDTRY.
*
*    " At this point ALL entities get a number!
*    ASSERT number_range_returned_quantity = lines( lt_entities ).
*
*    lv_po_max = number_range_key - number_range_returned_quantity.
*
*    LOOP AT lt_entities ASSIGNING <lfs_entities>.
*      lv_po_max = lv_po_max + 1.
*      TRY.
*          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
*        CATCH cx_uuid_error.
*          "handle exception
*      ENDTRY.
*
*      APPEND VALUE #( %cid = <lfs_entities>-%cid
**                      %key-PoNum = lv_po_max
*                      %is_draft = <lfs_entities>-%is_draft
*                      PoNum  = lv_po_max
*                      PoUuid = lv_uuid )
*                  TO mapped-header.
*    ENDLOOP.
*
*
*  ENDMETHOD.
*
*  METHOD earlynumbering_cba_Items.
*
*    DATA: max_item TYPE ebelp.
*
*    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
*      ENTITY Header BY \_Items
*        FROM CORRESPONDING #( entities )
*        LINK DATA(Items).
*
*    " Loop over all unique POs
*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>) GROUP BY <lfs_entities>-PoNum.
*
*      " Get highest item num from existing items belonging to po
*      max_item = REDUCE #( INIT max = CONV ebelp( '0' )
*                                 FOR  ls_item IN Items USING KEY entity WHERE ( source-PoNum  = <lfs_entities>-PoNum )
*                                 NEXT max = COND ebelp( WHEN ls_item-target-PoItem > max
*                                                                    THEN ls_item-target-PoItem
*                                                                    ELSE max )
*                               ).
*
*      " Get highest assigned item num from incoming entities, eg from internal operations
*      max_item = REDUCE #( INIT max = max_item
*                                 FOR  ls_item1 IN entities USING KEY entity WHERE ( PoNum  = <lfs_entities>-PoNum )
*                                 FOR  target IN ls_item1-%target
*                                 NEXT max = COND ebelp( WHEN   target-PoItem > max
*                                                                    THEN target-PoItem
*                                                                    ELSE max )
*                               ).
*
*      " Assign new item num if not already assigned
*      LOOP AT <lfs_entities>-%target ASSIGNING FIELD-SYMBOL(<item_numbers>).
*        APPEND CORRESPONDING #( <item_numbers> ) TO mapped-item ASSIGNING FIELD-SYMBOL(<mapped_items>).
*        IF <item_numbers>-PoItem IS INITIAL.
*          max_item += 10 .
*          <mapped_items>-PoItem = max_item .
*          TRY.
*              DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
*              <mapped_items>-PoItemUuid = lv_uuid.
*            CATCH cx_uuid_error.
*              "handle exception
*          ENDTRY.
*        ENDIF.
*      ENDLOOP.
*
*    ENDLOOP.
*
*  ENDMETHOD.

  METHOD CopyPO.

    " Copy records assigned to internal table.
    DATA: lt_pos TYPE TABLE FOR CREATE zr_po_head_dt_d .
    DATA: lv_po_max TYPE n LENGTH 10.

    READ ENTITIES OF zr_po_head_dt_d  IN LOCAL MODE
    ENTITY Header
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_pos1)
    FAILED failed.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
    ENTITY Header BY \_Items
     ALL FIELDS WITH CORRESPONDING #( lt_pos1 )
   RESULT DATA(lt_pos_items).

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZNUM_OB_PO'
            quantity          = CONV #( lines( keys ) )
          IMPORTING
            number            = DATA(lv_number)
            returncode        = DATA(lv_rc)
            returned_quantity = DATA(lv_ret_qty)
        ).
      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(lx_nr).
        RETURN.
    ENDTRY.

    lv_po_max = lv_number - lv_ret_qty + 1.

    TRY.
        DATA(lv_PoUuid) = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
    ENDTRY.

    LOOP AT lt_pos1 ASSIGNING FIELD-SYMBOL(<ls_pos>).
      APPEND VALUE #( %cid = keys[ KEY entity %key = <ls_pos>-%key ]-%cid
                      %is_draft = keys[ KEY entity %key = <ls_pos>-%key ]-%param-%is_draft
                      %data = CORRESPONDING #( <ls_pos> ) ) TO lt_pos ASSIGNING FIELD-SYMBOL(<ls_pos1>).

      <ls_pos1>-PoNum = lv_po_max.
      <ls_pos1>-PoUuid = lv_PoUuid.

    ENDLOOP.

    DATA:
      pos       TYPE TABLE FOR CREATE zr_po_head_dt_d\\Header,
      items_cba TYPE TABLE FOR CREATE zr_po_head_dt_d\\Header\_Items.

*    LOOP AT keys INTO DATA(key).
*      READ TABLE lt_pos1 ASSIGNING FIELD-SYMBOL(<po>) WITH KEY id COMPONENTS %tky = key-%tky.
*      IF sy-subrc EQ 0.
*        "Fill po container for creating new po instance
*        APPEND VALUE #( %cid  = key-%cid
*                        %is_draft = key-%param-%is_draft
*                        %data = CORRESPONDING #( <po> EXCEPT ponum pouuid ) ) TO pos ASSIGNING FIELD-SYMBOL(<new_po>).
*
*        <new_po>-PoNum = lv_po_max.
*        <new_po>-PoUuid = lv_pouuid.
*
*        "Fill %cid_ref of po as instance identifier for cba item
*        APPEND VALUE #( %cid_ref = key-%cid )
*          TO items_cba ASSIGNING FIELD-SYMBOL(<items_cba>).
*
*        LOOP AT lt_pos_items ASSIGNING FIELD-SYMBOL(<item>) USING KEY entity WHERE PoNum EQ <po>-PoNum.
*          "Fill booking container for creating booking with cba
*          APPEND VALUE #( %cid  = key-%cid && <item>-PoItem
*                          %data = CORRESPONDING #( lt_pos_items[ KEY entity %tky = <item>-%tky ] EXCEPT ponum PoItemUuid pouuid  ) )
*                        TO <items_cba>-%target ASSIGNING FIELD-SYMBOL(<new_item>).
*
*          TRY.
*              DATA(lv_PoitemUuid) = cl_system_uuid=>create_uuid_x16_static( ).
*            CATCH cx_uuid_error.
*          ENDTRY.
*          <new_item>-PoItemUuid = lv_PoitemUuid.
*          <new_item>-PoUuid = lv_pouuid.
*
*        ENDLOOP.
*      ELSE.
*        APPEND CORRESPONDING #( key MAPPING %fail = DEFAULT VALUE #( cause = if_abap_behv=>cause-not_found ) ) TO failed-header.
*      ENDIF.
*    ENDLOOP.

    "Create BO instance by copy.
    MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
    ENTITY Header
    CREATE FIELDS ( PoNum PoUuid Type CompCode DocCat Org Status Vendor Approved )
    WITH lt_pos
*    CREATE BY \_Items FIELDS ( PoNum PoItem PoItemUuid PoUuid Material Plant ItemText Storloc Qty Uom ProductPrice PriceUnit )
*          WITH items_cba
    MAPPED mapped. "DATA(mapped_create).

    " Set values to front end.
*    mapped-header = mapped_create-header.

*    MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
*    ENTITY Header
*    CREATE SET FIELDS WITH VALUE #( FOR key IN keys (  %cid = keys[ 1 ]-%cid
*                                                       PoNum = lt_pos[ 1 ]-PoNum
*                                                       Type = lt_pos[ 1 ]-Type
*                                                       CompCode = lt_pos[ 1 ]-CompCode ) )
*      MAPPED mapped
*      FAILED failed
*      REPORTED reported.



  ENDMETHOD.

  METHOD CreatePO.

    DATA: lv_po_max TYPE n LENGTH 10.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZNUM_OB_PO'
            quantity          = CONV #( lines( keys ) )
          IMPORTING
            number            = DATA(lv_number)
            returncode        = DATA(lv_rc)
            returned_quantity = DATA(lv_ret_qty)
        ).
      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(lx_nr).
        RETURN.
    ENDTRY.

    lv_po_max = lv_number - lv_ret_qty + 1.

    TRY.
        DATA(lv_PoUuid) = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
    ENDTRY.

    MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
     ENTITY Header
     CREATE FROM VALUE #( FOR <ls_instance> IN keys
                          ( %cid = <ls_instance>-%cid
                            PoNum = lv_po_max
                            PoUuid = lv_PoUuid
                            Type = 'NB'
                            CompCode = '001'
                            DocCat = 'A'
                            Org = '002'
                            Status = 'X'
                            Vendor = 'C01'
                            %control = VALUE #( PoNum = if_abap_behv=>mk-on
                                                PoUuid = if_abap_behv=>mk-on
                                                Type =  if_abap_behv=>mk-on
                                                CompCode = if_abap_behv=>mk-on
                                                DocCat = if_abap_behv=>mk-on
                                                Org = if_abap_behv=>mk-on
                                                Status = if_abap_behv=>mk-on
                                                Vendor = if_abap_behv=>mk-on )
                            %is_draft = <ls_instance>-%param-%is_draft )
                          )
     MAPPED mapped
     FAILED failed
     REPORTED DATA(reported1).

*    MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
*     ENTITY Header
*     CREATE SET FIELDS WITH VALUE #( FOR key IN keys (  %cid = keys[ 1 ]-%cid
*                                                        PoNum = ''
*                                                        Type = ''
*                                                        CompCode = '' ) )
*     MAPPED mapped
*     FAILED failed
*     REPORTED reported.


  ENDMETHOD.

  METHOD Approved.

    MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
      ENTITY Header
      UPDATE
      FIELDS ( Approved )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                      Approved = abap_true
                                      %control-Approved = if_abap_behv=>mk-on ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
      ENTITY Header
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(podata).


    result = VALUE #( FOR po IN podata ( %tky = po-%tky
                                         %param = po
                                        )
                     ).



  ENDMETHOD.

  METHOD ChangePOStatus.

    SELECT * FROM zr_po_head_dt_d INTO TABLE @DATA(lt_posh).

    MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
           ENTITY Header
           UPDATE FROM VALUE #( FOR po IN lt_posh ( %tky-PoNum = po-PoNum %tky-PoUuid = po-PoUuid
*                                                    PoNum = po-PoNum PoUuid = po-PoUuid
                                                    Status = ''
                                                    %control-PoNum = if_abap_behv=>mk-on
                                                    %control-Status = if_abap_behv=>mk-on ) )
           MAPPED mapped
           FAILED failed
           REPORTED reported.

  ENDMETHOD.

  METHOD Selected.

    DATA(lt_keys) = keys.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
      ENTITY Header
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_po).

    DATA(lf_new_status) = lt_keys[ 1 ]-%param-Po_Status.

    MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
      ENTITY Header
      UPDATE FIELDS ( Status )
      WITH VALUE #( ( %tky = lt_po[ 1 ]-%tky Status = lf_new_status ) ).

    READ ENTITIES OF zr_po_head_dt_d
     IN LOCAL MODE
     ENTITY Header
     FIELDS ( Status ) WITH CORRESPONDING #( keys )
     RESULT DATA(lt_po1).

    result = VALUE #( FOR <lr_po> IN lt_po1 ( %tky = <lr_po>-%tky %param =  <lr_po> ) ).

*    MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
*      ENTITY Header
*      UPDATE FROM VALUE #( FOR key IN keys ( PoNum = key-PoNum Status = key-%param-Po_Status
*                                             %control-PoNum = if_abap_behv=>mk-on %control-Status = if_abap_behv=>mk-on ) )
*      MAPPED mapped
*      FAILED failed
*      REPORTED reported.

*    APPEND VALUE #( PoNum = keys[ 1 ]-PoNum %param-PoNum = keys[ 1 ]-PoNum %param-Status = keys[ 1 ]-%param-Po_Status ) TO result.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
     ENTITY Header
        FIELDS (  PoNum Approved Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(it_pos)
      FAILED failed.


    result = VALUE #( FOR ls_po IN it_pos
                       ( %tky                           = ls_po-%tky
                         %features-%action-Approved = COND #( WHEN ls_po-Approved = abap_true
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                         %features-%action-Selected = COND #( WHEN ls_po-Status = abap_true
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                         %features-%assoc-_Items    = COND #( WHEN ls_po-Status = abap_true
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                      ) ).


*    result = VALUE #( FOR ls_po IN it_pos
*                        LET approvevalue = COND #( WHEN ls_po-Approved = abap_true
*                                                       THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
*                            statusvalue = COND #( WHEN ls_po-Status = abap_true
*                                                       THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
*                            assocvalue   = COND #( WHEN ls_po-Status = abap_true
*                                                       THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
*                        IN ( %tky = ls_po-%tky
*                             %action-Selected = statusvalue
*                             %action-Approved = approvevalue
*                             %assoc-_Items = assocvalue ) ).


  ENDMETHOD.

  METHOD get_global_features.


    result = VALUE #(
                          %action-ChangePOStatus = if_abap_behv=>fc-o-enabled
                          %create = if_abap_behv=>fc-o-enabled
                          %update = if_abap_behv=>fc-o-enabled
*                          %delete = if_abap_behv=>fc-o-disabled
                      ).

  ENDMETHOD.

  METHOD checkType.

    DATA lo_msgs TYPE REF TO if_abap_behv_message.

    lo_msgs = me->new_message( id = 'Z_MSG_CLASS' number = 000 severity = ms-error v1 = 'TYPE Not Allowed' ).

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
             ENTITY Header
             ALL FIELDS
             WITH CORRESPONDING #( keys )
             RESULT DATA(pos_check).

    LOOP AT pos_check INTO DATA(ls_pos_check).
      IF ls_pos_check-Type NE 'NB'.

*        APPEND VALUE #( %tky = ls_pos_check-%tky ) TO failed-header.
*        failed-header = VALUE #( ( %tky = ls_pos_check-%tky ) ).
*        APPEND VALUE #( %key = ls_pos_check-%key ) TO failed-header.
        APPEND VALUE #(  Ponum  = ls_pos_check-Ponum ) TO failed-header.

        APPEND VALUE #(
*                           %tky = ls_pos_check-%tky
                         Ponum  = ls_pos_check-Ponum
*                          %state_area = 'TYPE'
                   "     %key  = ls_pos_check-%key-PoNum
                        %element-type = if_abap_behv=>mk-on
                        %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text =  'Type Not allowed' )

*                                 new_message(
*                                    id       = 'Z_MSG_CLASS'
*                                    number   = 000
*                                    severity = ms-error
*                                    v1       = 'TYPE Not Allowed'
*                                    v2       =
*                                    v3       =
*                                    v4       =
*                                  )

                               "lo_msgs

                               "  NEW zcx_po( severity = if_abap_behv_message=>severity-error
                                "            textid =  zcx_po=>type_unknown
                                 "           type = ls_pos_check-type )
                       )
        TO reported-header.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD updateOrg.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
           ENTITY Header
           FIELDS ( DocCat )
           WITH CORRESPONDING #( keys )
           RESULT DATA(pos_org_upd).
    IF pos_org_upd IS NOT INITIAL.
      MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
        ENTITY Header
        UPDATE
        FIELDS ( Org )
        WITH VALUE #( FOR pos IN pos_org_upd ( %tky = pos-%tky Org = '1'  ) )
        REPORTED DATA(ls_return1).
    ENDIF.

  ENDMETHOD.

  METHOD updateOrg1.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
           ENTITY Header
           FIELDS ( DocCat )
           WITH CORRESPONDING #( keys )
           RESULT DATA(pos_org_upd).
    IF pos_org_upd IS NOT INITIAL.
      MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
        ENTITY Header
        UPDATE
        FIELDS ( Org )
        WITH VALUE #( FOR pos IN pos_org_upd ( %tky = pos-%tky Org = '2' ) )
        REPORTED DATA(ls_return1).
    ENDIF.

  ENDMETHOD.

  METHOD setInitialValues.
*
    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
               ENTITY Header
             FIELDS ( Type )
            WITH CORRESPONDING #( keys )
           RESULT DATA(pos_crt).
    IF pos_crt IS NOT INITIAL.
      MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
        ENTITY Header
        UPDATE
        FIELDS ( Status )
        WITH VALUE #( FOR pos IN pos_crt ( %tky = pos-%tky Status = '1'  ) )
        REPORTED DATA(ls_return).
    ENDIF.

  ENDMETHOD.

  METHOD setInitialValues1.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
              ENTITY Header
            FIELDS ( Type )
           WITH CORRESPONDING #( keys )
          RESULT DATA(pos_crt).
    IF pos_crt IS NOT INITIAL.
      MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
        ENTITY Header
        UPDATE
        FIELDS ( Status )
        WITH VALUE #( FOR pos IN pos_crt ( %tky = pos-%tky Status = '2'  ) )
        REPORTED DATA(ls_return).
    ENDIF.

  ENDMETHOD.

  METHOD updateVendor.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
           ENTITY Header
           FIELDS ( Type )
           WITH CORRESPONDING #( keys )
           RESULT DATA(pos_org_upd).
    IF pos_org_upd IS NOT INITIAL.
      MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
        ENTITY Header
        UPDATE
        FIELDS ( Vendor )
        WITH VALUE #( FOR pos IN pos_org_upd ( %tky = pos-%tky Vendor = '10001'  ) )
        REPORTED DATA(ls_return1).
    ENDIF.
*
  ENDMETHOD.

  METHOD updateStatus.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
             ENTITY Header
             FIELDS ( Vendor )
             WITH CORRESPONDING #( keys )
             RESULT DATA(pos_org_upd).
    IF pos_org_upd IS NOT INITIAL.
      MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
        ENTITY Header
        UPDATE
        FIELDS ( Status )
        WITH VALUE #( FOR po IN pos_org_upd ( %tky = po-%tky Status = '1'  ) )
        REPORTED DATA(ls_return1).
    ENDIF.

  ENDMETHOD.

  METHOD updateOrg2.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
           ENTITY Header
           FIELDS ( CompCode )
           WITH CORRESPONDING #( keys )
           RESULT DATA(pos_org_upd).
    IF pos_org_upd IS NOT INITIAL.
      MODIFY ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
        ENTITY Header
        UPDATE
        FIELDS ( Org )
        WITH VALUE #( FOR pos IN pos_org_upd ( %tky = pos-%tky Org = '003' ) )
        REPORTED DATA(ls_return1).
    ENDIF.

  ENDMETHOD.

  METHOD is_create_granted.

    "For validation
    IF approved IS SUPPLIED.

      AUTHORITY-CHECK OBJECT 'ZPO_AUTHOB'
        ID 'ZAPPROVED' FIELD approved
        ID 'ACTVT'     FIELD '01'.

      create_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      " simulation of auth check, " auth granted for approved X, else not
      CASE approved.
        WHEN 'X'.
          create_granted = abap_true.
        WHEN OTHERS.
          create_granted = abap_false.
      ENDCASE.

      "Simulation for full authorization, "(not to be used in productive code)
      create_granted = abap_true.

      "For global auth
    ELSE.

      AUTHORITY-CHECK OBJECT 'ZPO_AUTHOB'
        ID 'ZAPPROVED' DUMMY
        ID 'ACTVT'     FIELD '01'.

      create_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization, "(not to be used in productive code)
      create_granted = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD is_delete_granted.

    "For validation
    IF approved IS SUPPLIED.

      AUTHORITY-CHECK OBJECT 'ZPO_AUTHOB'
        ID 'ZAPPROVED' FIELD approved
        ID 'ACTVT'     FIELD '06'.

      delete_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      " simulation of auth check, " auth granted for approved X, else not
      CASE approved.
        WHEN 'X'.
          delete_granted = abap_true.
        WHEN OTHERS.
          delete_granted = abap_false.
      ENDCASE.

      "Simulation for full authorization, "(not to be used in productive code)
*      delete_granted = abap_true.

      "For global auth
    ELSE.

      AUTHORITY-CHECK OBJECT 'ZPO_AUTHOB'
        ID 'ZAPPROVED' DUMMY
        ID 'ACTVT'     FIELD '06'.

      delete_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization, "(not to be used in productive code)
      delete_granted = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD is_update_granted.

    "For validation
    IF approved IS SUPPLIED.

      AUTHORITY-CHECK OBJECT 'ZPO_AUTHOB'
        ID 'ZAPPROVED' FIELD approved
        ID 'ACTVT'     FIELD '02'.

      update_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      " simulation of auth check, " auth granted for approved X, else not
      CASE approved.
        WHEN 'X'.
          update_granted = abap_true.
        WHEN OTHERS.
          update_granted = abap_false.
      ENDCASE.

      "Simulation for full authorization, "(not to be used in productive code)
      update_granted = abap_true.

      "For global auth
    ELSE.
      AUTHORITY-CHECK OBJECT 'ZPO_AUTHOB'
        ID 'ZAPPROVED' DUMMY
        ID 'ACTVT'     FIELD '02'.

      update_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization, "(not to be used in productive code)
      update_granted = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD precheck_create.

    precheck_auth(
       EXPORTING
         entities_create = entities
       CHANGING
         failed          = failed-header
         reported        = reported-header
     ).

  ENDMETHOD.

  METHOD precheck_update.

    precheck_auth(
     EXPORTING
       entities_update = entities
     CHANGING
       failed          = failed-header
       reported        = reported-header
   ).

  ENDMETHOD.

  METHOD precheck_auth.

    DATA:
      entities          TYPE t_entities_update,
      operation         TYPE if_abap_behv=>t_char01,
      it_vendors        TYPE SORTED TABLE OF ztb_vendor WITH UNIQUE KEY vendor,
      is_modify_granted TYPE abap_bool.

    " Either entities_create or entities_update is provided.  NOT both and at least one.
    ASSERT NOT ( entities_create IS INITIAL EQUIV entities_update IS INITIAL ).

    IF entities_create IS NOT INITIAL.
      entities = CORRESPONDING #( entities_create MAPPING %cid_ref = %cid ).
      operation = if_abap_behv=>op-m-create.
    ELSE.
      entities = entities_update.
      operation = if_abap_behv=>op-m-update.
    ENDIF.

    DELETE entities WHERE %control-Vendor = if_abap_behv=>mk-off.

    it_vendors = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING vendor = Vendor EXCEPT * ).

    CHECK it_vendors IS NOT INITIAL.
    SELECT FROM ztb_vendor FIELDS vendor, vendordesc
                            FOR ALL ENTRIES IN @it_vendors
                            WHERE vendor = @it_vendors-vendor
      INTO TABLE @DATA(it_vendor_dts).

    LOOP AT entities INTO DATA(entity).
      is_modify_granted = abap_false.

      READ TABLE it_vendor_dts WITH KEY vendor = entity-Vendor
                   ASSIGNING FIELD-SYMBOL(<lfs_vendor>).

      "If invalid or initial Vendor -> validate Vendor
      IF sy-subrc = 0.
        CASE operation.
          WHEN if_abap_behv=>op-m-create. is_modify_granted = abap_true.
          WHEN if_abap_behv=>op-m-update. is_modify_granted = abap_true.
        ENDCASE.
      ENDIF.
      IF is_modify_granted = abap_false.
        APPEND VALUE #(
                         %cid      = COND #( WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
                         %tky      = entity-%tky
                       ) TO failed.

        APPEND VALUE #(
                         %cid      = COND #( WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
                         %tky      = entity-%tky
                         %msg      = NEW zcl_po_messages(
                                                 textid    = zcl_po_messages=>not_authorized_for_vendor
                                                 vendor    = entity-Vendor
                                                 severity  = if_abap_behv_message=>severity-error )
                         %element-Vendor   = if_abap_behv=>mk-on
                      ) TO reported.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD Resume.

    DATA:
      entities_update TYPE t_entities_update.

    READ ENTITIES OF zr_po_head_dt_d IN LOCAL MODE
      ENTITY Header
        FIELDS ( Vendor )
        WITH VALUE #(
                      FOR key IN keys
                        %is_draft = if_abap_behv=>mk-on
                        ( %key = key-%key )
                    )
        RESULT DATA(it_pos).

    " Set %control-Vendor (if set) to true, so that the precheck_auth checks the permissions.
    entities_update = CORRESPONDING #( it_pos CHANGING CONTROL ).

    IF entities_update IS NOT INITIAL.
      precheck_auth(
        EXPORTING
          entities_update = entities_update
        CHANGING
          failed          = failed-header
          reported        = reported-header
      ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
