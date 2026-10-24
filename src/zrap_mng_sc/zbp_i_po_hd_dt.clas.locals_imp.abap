CLASS lhc_ZI_PO_HD_DT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_po_hd_dt RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_po_hd_dt RESULT result.
    METHODS createpobytemplate FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_hd_dt~createpobytemplate RESULT result.

    METHODS selected FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_hd_dt~selected RESULT result.

    METHODS unselected FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_hd_dt~unselected RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_po_hd_dt RESULT result.
    METHODS checkplant FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_po_hd_dt~checkplant.

    METHODS checktype FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_po_hd_dt~checktype.
    METHODS updateorg1 FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_po_hd_dt~updateorg1.

ENDCLASS.

CLASS lhc_ZI_PO_HD_DT IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createPOByTemplate.

    " Copy records assigned to internal table.
    DATA: lt_pos TYPE TABLE FOR CREATE zi_po_hd_dt .

    READ ENTITIES OF zi_po_hd_dt  IN LOCAL MODE
    ENTITY zi_po_hd_dt
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_pos1)
    FAILED failed.

    SELECT MAX( Ponum ) FROM zi_po_hd_dt INTO @DATA(lv_po).

    DATA lt_create TYPE TABLE FOR CREATE zi_po_hd_dt.
    lt_create = VALUE #( FOR row IN  lt_pos1 INDEX INTO idx
                             ( Ponum      = lv_po + idx
                               Compcode = row-Compcode
                               CreatedAt = row-Compcode
                               Createdby = row-Createdby
                               Doccat = row-Doccat
                               Org = row-Org
                                ) ). " Open

*    LOOP AT lt_pos1 ASSIGNING FIELD-SYMBOL(<ls_pos>).
*      APPEND VALUE #( %cid_ref = keys[ KEY entity %key = <ls_pos>-%key ]-%cid_ref
** %is_draft = keys[ KEY entity %key = <ls_pos>-%key ]-%param-%is_draft
*                       %data = CORRESPONDING #( <ls_pos> ) ) TO lt_pos ASSIGNING FIELD-SYMBOL(<ls_pos1>).
*    ENDLOOP.
*
*    LOOP AT lt_pos ASSIGNING FIELD-SYMBOL(<ls_pos2>).
*      <ls_pos2>-PoNum =  <ls_pos2>-PoNum + 1.
*      CONDENSE  <ls_pos2>-PoNum.
*      <ls_pos2>-PoNum  = |{ <ls_pos2>-PoNum  ALPHA = IN }|.
*    ENDLOOP.

    "Create BO instance by copy.
    MODIFY ENTITIES OF zi_po_hd_dt IN LOCAL MODE
    ENTITY zi_po_hd_dt
    CREATE FIELDS ( PoNum Type CompCode DocCat Org Plant Status Vendor  )
    WITH lt_create
    FAILED failed
    REPORTED reported
    MAPPED DATA(mapped_create).

    " Set values to front end.
*    mapped-zi_po_header_dts = mapped_create-zi_po_hd_dt.

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

    result = VALUE #( FOR create IN  lt_create INDEX INTO idx
                                ( %cid_ref = keys[ idx ]-%cid_ref
                                  %key     = keys[ idx ]-Ponum
                                  %param   = CORRESPONDING #(  create ) ) ) .

  ENDMETHOD.

  METHOD Selected.

    " Modify in local mode
    MODIFY ENTITIES OF zi_po_hd_dt IN LOCAL MODE
           ENTITY zi_po_hd_dt
              UPDATE FROM VALUE #( FOR key IN keys ( Ponum = key-Ponum
                                                     Status = 'A' " Accepted
                                                     %control-Status = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.

  ENDMETHOD.

  METHOD UnSelected.
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_po_hd_dt IN LOCAL MODE
    ENTITY zi_po_hd_dt
       FIELDS (  Ponum Status )
       WITH CORRESPONDING #( keys )
     RESULT DATA(lt_po_result)
     FAILED failed.
    result = VALUE #( FOR ls_po IN lt_po_result
                      ( %key                           = ls_po-%key
                        %features-%action-Selected = COND #( WHEN ls_po-status = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                        %features-%action-UnSelected = COND #( WHEN ls_po-Status = 'A'
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                        %assoc-_Items                = COND #( WHEN ls_po-Status = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                      ) ).

  ENDMETHOD.

  METHOD checkPlant.
  ENDMETHOD.

  METHOD checkType.

    DATA lo_msgs TYPE REF TO if_abap_behv_message.
    lo_msgs = me->new_message( id = 'Z_PO_MSG' number = 000 severity = ms-error v1 = 'TYPE Not Allowed' ).

    READ ENTITIES OF zi_po_hd_dt IN LOCAL MODE
             ENTITY zi_po_hd_dt
             ALL FIELDS
             WITH CORRESPONDING #( keys )
             RESULT DATA(pos_check).

    IF pos_check IS NOT INITIAL.
      LOOP AT pos_check INTO DATA(ls_pos_check).
        IF ls_pos_check-Type NE 'A'.

*          APPEND VALUE #( %tky = ls_pos_check-%tky ) TO failed-zi_po_hd_dt.
*          failed-zi_po_header_dts = VALUE #( ( %tky = ls_pos_check-%tky ) ).
*          APPEND VALUE #( %key = ls_pos_check-%key ) TO failed-zi_po_hd_dt.
          APPEND VALUE #(  Ponum  = ls_pos_check-Ponum ) TO failed-zi_po_hd_dt.

          APPEND VALUE #(
*                           %tky = ls_pos_check-%tky
                           Ponum  = ls_pos_check-Ponum
*                          %state_area = 'TYPE'
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
          TO reported-zi_po_hd_dt.

        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD updateOrg1.

    READ ENTITIES OF zi_po_hd_dt IN LOCAL MODE
          ENTITY zi_po_hd_dt
          FIELDS ( DocCat )
          WITH CORRESPONDING #( keys )
          RESULT DATA(pos_org_up).

*    READ ENTITIES OF zi_po_hd_dt IN LOCAL MODE
*        ENTITY zi_po_hd_dt
*              FROM VALUE #( FOR ls_pos IN keys (
*                               Ponum = ls_pos-Ponum
*                               %control-Doccat = if_abap_behv=>mk-on ) )
*        RESULT DATA(lt_read_po1).

    IF pos_org_up IS NOT INITIAL.
      MODIFY ENTITIES OF zi_po_hd_dt IN LOCAL MODE
        ENTITY zi_po_hd_dt
        UPDATE
        FIELDS ( Org )
        WITH VALUE #( FOR pos IN pos_org_up ( %tky = pos-%tky Org = '1'  ) )
        REPORTED DATA(ls_return1).

*      MODIFY ENTITIES OF zi_po_hd_dt IN LOCAL MODE
*       ENTITY zi_po_hd_dt
*              UPDATE FROM VALUE #( FOR po IN lt_read_po1 (
*                Ponum = po-Ponum
*                Doccat = po-Doccat
*                %control-Org = if_abap_behv=>mk-on ) ) .
    ENDIF.



  ENDMETHOD.

ENDCLASS.
