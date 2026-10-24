CLASS lhc_ZI_PO_HEADER_DTS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_po_header_dts RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_po_header_dts RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_po_header_dts RESULT result.

    METHODS ChangePOStatus FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_header_dts~ChangePOStatus.

    METHODS CopyPO FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_header_dts~CopyPO.

    METHODS CreatePO FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_header_dts~CreatePO.

    METHODS DeepAction FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_header_dts~DeepAction RESULT result.

    METHODS POStatus FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_header_dts~POStatus RESULT result.

    METHODS Selected FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_header_dts~Selected RESULT result.

    METHODS setInitialValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_po_header_dts~setInitialValues.

    METHODS updateOrg1 FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_po_header_dts~updateOrg1.

    METHODS updateOrg FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_po_header_dts~updateOrg.

    METHODS updateOrg2 FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_po_header_dts~updateOrg2.

    METHODS checkPlant FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_po_header_dts~checkPlant.

    METHODS checkType FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_po_header_dts~checkType.

ENDCLASS.

CLASS lhc_ZI_PO_HEADER_DTS IMPLEMENTATION.

  METHOD get_instance_features.


    READ ENTITIES OF zi_po_header_dts IN LOCAL MODE
ENTITY  zi_po_header_dts
FIELDS ( Status ) WITH CORRESPONDING #(  keys )
RESULT DATA(selected)
FAILED failed.
    result = VALUE #( FOR stus IN selected LET
   statusvalue = COND #( WHEN stus-Status = abap_true
                                         THEN if_abap_behv=>fc-o-disabled
                                         ELSE if_abap_behv=>fc-o-enabled )
                                         IN ( %tky = stus-%tky %action-Selected = statusvalue ) ).



  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ChangePOStatus.

    SELECT * FROM zi_po_header_dts INTO TABLE @DATA(lt_posh).

    MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
           ENTITY zi_po_header_dts
           UPDATE FROM VALUE #( FOR po IN lt_posh ( PoNum = po-PoNum Status = ''
                                                    %control-PoNum = if_abap_behv=>mk-on
                                                    %control-Status = if_abap_behv=>mk-on ) )
           MAPPED mapped
           FAILED failed
           REPORTED reported.

  ENDMETHOD.

  METHOD CopyPO.

    " Copy records assigned to internal table.
    DATA: lt_pos TYPE TABLE FOR CREATE zi_po_header_dts .

    READ ENTITIES OF zi_po_header_dts  IN LOCAL MODE
    ENTITY zi_po_header_dts
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_pos1)
    FAILED failed.

    LOOP AT lt_pos1 ASSIGNING FIELD-SYMBOL(<ls_pos>).
      APPEND VALUE #( %cid = keys[ KEY entity %key = <ls_pos>-%key ]-%cid
* %is_draft = keys[ KEY entity %key = <ls_pos>-%key ]-%param-%is_draft
                       %data = CORRESPONDING #( <ls_pos> ) ) TO lt_pos ASSIGNING FIELD-SYMBOL(<ls_pos1>).
    ENDLOOP.

    LOOP AT lt_pos ASSIGNING FIELD-SYMBOL(<ls_pos2>).
      <ls_pos2>-PoNum =  <ls_pos2>-PoNum + 1.
      CONDENSE  <ls_pos2>-PoNum.
      <ls_pos2>-PoNum  = |{ <ls_pos2>-PoNum  ALPHA = IN }|.
    ENDLOOP.

    "Create BO instance by copy.
    MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
    ENTITY zi_po_header_dts
    CREATE FIELDS ( PoNum Type CompCode DocCat Org Plant Status Vendor  )
    WITH lt_pos
    MAPPED DATA(mapped_create).
    " Set values to front end.
    mapped-zi_po_header_dts = mapped_create-zi_po_header_dts.

*     DATA(lv_lifnr) = cl_uuid_factory->create_system_uuid()->create_uuid_x16().

*    MODIFY ENTITIES OF zi_po_hd IN LOCAL MODE
*    ENTITY zi_po_hd
*    CREATE SET FIELDS WITH VALUE #( FOR key IN keys (  %cid = keys[ 1 ]-%cid
*                                                       PoNum = lt_pos[ 1 ]-PoNum
*                                                       Type = lt_pos[ 1 ]-Type
*                                                       CompCode = lt_pos[ 1 ]-CompCode ) )
*      MAPPED mapped
*      FAILED failed
*      REPORTED reported.



  ENDMETHOD.

  METHOD CreatePO.

    SELECT * FROM zi_po_header_dts INTO TABLE @DATA(lt_posh).
    SORT lt_posh DESCENDING BY PoNum.
    READ TABLE lt_posh INTO DATA(ls_posh) INDEX 1.
    ls_posh-PoNum = ls_posh-PoNum + 1.
    ls_posh-PoNum = |{ ls_posh-PoNum  ALPHA = IN }|.

    MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
  ENTITY zi_po_header_dts
  CREATE FROM VALUE #( FOR <ls_instance> IN keys (
  %cid = <ls_instance>-%cid
  PoNum = ls_posh-PoNum
  Type = 'NB'
  CompCode = '001'
  DocCat = 'A'
  Org = '002'
  Plant = 'HYD'
  Status = 'X'
  Vendor = 'C01'
  %control = VALUE #(
  PoNum = if_abap_behv=>mk-on
  Type =  if_abap_behv=>mk-on
  CompCode = if_abap_behv=>mk-on
  DocCat = if_abap_behv=>mk-on
  Org = if_abap_behv=>mk-on
  Plant = if_abap_behv=>mk-on
  Status = if_abap_behv=>mk-on
  Vendor = if_abap_behv=>mk-on
  )
  ) )
  MAPPED mapped
  FAILED failed
  REPORTED DATA(reported1).

*    MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
*     ENTITY zi_po_header_dts
*     CREATE SET FIELDS WITH VALUE #( FOR key IN keys (  %cid = keys[ 1 ]-%cid
*                                                        PoNum = ''
*                                                        Type = ''
*                                                        CompCode = '' ) )
*       MAPPED mapped
*       FAILED failed
*       REPORTED reported.


  ENDMETHOD.

  METHOD DeepAction.
  ENDMETHOD.

  METHOD POStatus.

    DATA(lt_keys) = keys.

    READ ENTITIES OF zi_po_header_dts
    IN LOCAL MODE
    ENTITY zi_po_header_dts
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_po).

    DATA(lf_new_status) = lt_keys[ 1 ]-%param-Po_Status.

    MODIFY ENTITIES OF zi_po_header_dts
    IN LOCAL MODE
    ENTITY zi_po_header_dts
    UPDATE FIELDS ( Status )
    WITH VALUE #( ( %tky = lt_po[ 1 ]-%tky Status = lf_new_status ) ).

    READ ENTITIES OF zi_po_header_dts
     IN LOCAL MODE
     ENTITY zi_po_header_dts
     FIELDS ( Status ) WITH CORRESPONDING #( keys )
     RESULT DATA(lt_po1).

    result = VALUE #(
                FOR <lr_po> IN lt_po1 ( %tky = <lr_po>-%tky %param =  <lr_po> ) ).


*        MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
*     ENTITY zi_po_hd
*     UPDATE FROM VALUE #( FOR key IN keys ( PoNum = key-PoNum
*                                            Status = key-%param-Po_Status
*                                            %control-PoNum = if_abap_behv=>mk-on
*                                            %control-Status = if_abap_behv=>mk-on ) )
*    MAPPED mapped
*    FAILED failed
*    REPORTED reported.
*
*    APPEND VALUE #( PoNum = keys[ 1 ]-PoNum
*                         %param-PoNum = keys[ 1 ]-PoNum
*                        %param-Status = keys[ 1 ]-%param-Po_Status ) TO result.



  ENDMETHOD.

  METHOD Selected.

    MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
 ENTITY zi_po_header_dts
 UPDATE
 FIELDS ( Status )
 WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = abap_true %control-Status = if_abap_behv=>mk-on ) )
 FAILED failed
 REPORTED reported.

    READ ENTITIES OF zi_po_header_dts IN LOCAL MODE
    ENTITY zi_po_header_dts
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(podata).

    result = VALUE #( FOR po IN podata (   %tky = po-%tky %param = po ) ).


  ENDMETHOD.

  METHOD setInitialValues.

    READ ENTITIES OF zi_po_header_dts IN LOCAL MODE
                ENTITY zi_po_header_dts
              FIELDS ( Type )
             WITH CORRESPONDING #( keys )
            RESULT DATA(pos_crt).

    IF pos_crt IS NOT INITIAL.
      MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
        ENTITY zi_po_header_dts
        UPDATE
        FIELDS ( Status )
        WITH VALUE #( FOR pos IN pos_crt ( %tky = pos-%tky Status = '1'  ) )
        REPORTED DATA(ls_return).
    ENDIF.



  ENDMETHOD.

  METHOD updateOrg1.

    READ ENTITIES OF zi_po_header_dts IN LOCAL MODE
           ENTITY zi_po_header_dts
           FIELDS ( DocCat )
           WITH CORRESPONDING #( keys )
           RESULT DATA(pos_org_up).
    IF pos_org_up IS NOT INITIAL.
      MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
        ENTITY zi_po_header_dts
        UPDATE
        FIELDS ( Org )
        WITH VALUE #( FOR pos IN pos_org_up ( %tky = pos-%tky Org = '1'  ) )
        REPORTED DATA(ls_return1).
    ENDIF.


  ENDMETHOD.

  METHOD updateOrg.

    READ ENTITIES OF zi_po_header_dts IN LOCAL MODE
            ENTITY zi_po_header_dts
            FIELDS ( DocCat )
            WITH CORRESPONDING #( keys )
            RESULT DATA(pos_org_up).
    IF pos_org_up IS NOT INITIAL.
      MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
        ENTITY zi_po_header_dts
        UPDATE
        FIELDS ( Org )
        WITH VALUE #( FOR pos IN pos_org_up ( %tky = pos-%tky Org = '1'  ) )
        REPORTED DATA(ls_return1).
    ENDIF.


  ENDMETHOD.

  METHOD updateOrg2.

    READ ENTITIES OF zi_po_header_dts IN LOCAL MODE
             ENTITY zi_po_header_dts
             FIELDS ( DocCat )
             WITH CORRESPONDING #( keys )
             RESULT DATA(pos_org_up).
    IF pos_org_up IS NOT INITIAL.
      MODIFY ENTITIES OF zi_po_header_dts IN LOCAL MODE
        ENTITY zi_po_header_dts
        UPDATE
        FIELDS ( Org )
        WITH VALUE #( FOR pos IN pos_org_up ( %tky = pos-%tky Org = '2'  ) )
        REPORTED DATA(ls_return1).
    ENDIF.


  ENDMETHOD.

  METHOD checkPlant.

    READ ENTITIES OF zi_po_header_dts IN LOCAL MODE
          ENTITY zi_po_header_dts BY \_PO_items
          FIELDS ( Plant )
          WITH VALUE #( ( %tky-PoNum = keys[ 1 ]-%tky-PoNum ) )
          RESULT DATA(pos_checkPlant).

    LOOP AT pos_checkPlant INTO DATA(ls_pos_checkPlant).
      IF ls_pos_checkPlant-Plant NE '0001'.
        failed-zi_po_items_dts = VALUE #( ( %key-PoNum = ls_pos_checkPlant-%key-PoNum
                                            %key-PoItem = ls_pos_checkPlant-%key-PoItem ) ).

        reported-zi_po_items_dts = VALUE #( ( %key-PoNum = ls_pos_checkPlant-%key-PoNum
                                             %key-PoItem = ls_pos_checkPlant-%key-PoItem
                                             %element-plant = if_abap_behv=>mk-on
*                                             %element-poitem = if_abap_behv=>mk-on
                                             %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                             text = 'Plant is not Valid' ) ) ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD checkType.

    DATA lo_msgs TYPE REF TO if_abap_behv_message.
    lo_msgs = me->new_message( id = 'Z_PO_MSG' number = 000 severity = ms-error v1 = 'TYPE Not Allowed' ).

    READ ENTITIES OF zi_po_header_dts IN LOCAL MODE
             ENTITY zi_po_header_dts
             ALL FIELDS
             WITH CORRESPONDING #( keys )
             RESULT DATA(pos_check).

    IF pos_check IS NOT INITIAL.
      LOOP AT pos_check INTO DATA(ls_pos_check).
        IF ls_pos_check-Type NE 'A'.

          APPEND VALUE #( %tky = ls_pos_check-%tky ) TO failed-zi_po_header_dts.
*          failed-zi_po_header_dts = VALUE #( ( %tky = ls_pos_check-%tky ) ).

          APPEND VALUE #( %tky = ls_pos_check-%tky
                          %state_area = 'TYPE'
                     "     %key  = ls_pos_check-%key-PoNum
                          %element-type = if_abap_behv=>mk-on
                          %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text =  'Type Not allowed' )

*                                 new_message(
*                                    id       = 'Z_PO_MSG'
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
          TO reported-zi_po_header_dts.

        ENDIF.
      ENDLOOP.
    ENDIF.


  ENDMETHOD.

*  METHOD earlynumbering_create.
*
*    DATA(lt_entities) = entities.
*
*    TRY.
**        cl_numberrange_runtime=>number_get(
**          EXPORTING
***          ignore_buffer     =
**            nr_range_nr       =   '00'
**            object            =  'ZNUMB_OBJ'
**            quantity          = CONV #( lines( lt_entities ) )
***          subobject         =
***          toyear            =
**          IMPORTING
**            number            =  DATA(lv_latest_num)
**            returncode        = DATA(lv_code)
**            returned_quantity = DATA(lv_qty)
**        ).
*        DATA(lv_curr_num) = '0000000005'."lv_latest_num - lv_qty.
*      CATCH cx_nr_object_not_found.
*      CATCH cx_number_ranges  INTO DATA(lo_error).
**
**
**
*        LOOP AT lt_entities INTO DATA(ls_entities). "Exception Handling
*          APPEND VALUE #( %cid = ls_entities-%cid %key = ls_entities-%key ) TO failed-zi_po_header_dts.
*          APPEND VALUE #( %cid = ls_entities-%cid %key = ls_entities-%key %msg = lo_error ) TO reported-zi_po_header_dts.
*        ENDLOOP.
*        EXIT.
*    ENDTRY.
*
*    DATA: lt_po_m TYPE TABLE FOR MAPPED EARLY zi_po_header_dts,
*          ls_po_m LIKE LINE OF lt_po_m.
*
*
*    LOOP AT lt_entities INTO ls_entities.
**      lv_curr_num = lv_curr_num + 1.
**      ls_po_m = VALUE #( %cid = ls_entities-%cid
**                         PoNum = lv_curr_num
**                         %key-PoNum = lv_curr_num
**                         %is_draft = ls_entities-%is_draft ).
**      APPEND ls_po_m TO mapped-zi_po_header_dts.
**      IF lv_curr_num IS INITIAL.
**        TRY.
**            lv_curr_num = cl_system_uuid=>create_uuid_x16_static( ).
**          CATCH cx_uuid_error.
**            "handle exception
**        ENDTRY.
**      ENDIF.
*      APPEND VALUE #( %cid = ls_entities-%cid
*                      %key = VALUE #( PoNum = lv_curr_num )
*                      %is_draft = ls_entities-%is_draft
*                      PoNum  = lv_curr_num )
*                  TO mapped-zi_po_header_dts.
*    ENDLOOP.
*
*
*  ENDMETHOD.

*  METHOD earlynumbering_cba_Po_items.
*    LOOP AT entities INTO DATA(entity).
**      " Get current max Customer Number from DB
**      SELECT MAX( cust_no )
**      INTO (lv_max)
**      FROM zvd_t_isale
**      WHERE cust_no = -%key-custno.
*      LOOP AT entity-%target INTO DATA(t_item).
*        APPEND VALUE #( %cid = t_item-%cid
*                        %key = VALUE #(
*                        PoNum = entity-%key-PoNum )
*                        %is_draft = t_item-%is_draft
*                        PoNum = entity-%key-PoNum
*                        PoItem = t_item-PoItem )
*                   TO mapped-zi_po_items_dts.
*      ENDLOOP.
*    ENDLOOP.
*  ENDMETHOD.


ENDCLASS.

CLASS lsc_ZI_PO_HEADER_DTS DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_PO_HEADER_DTS IMPLEMENTATION.

  METHOD adjust_numbers.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
