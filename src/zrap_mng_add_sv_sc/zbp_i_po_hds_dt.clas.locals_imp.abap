CLASS lhc_ZI_PO_HDS_DT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_po_hds_dt RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_po_hds_dt RESULT result.

ENDCLASS.

CLASS lhc_ZI_PO_HDS_DT IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_PO_HDS_DT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_PO_HDS_DT IMPLEMENTATION.

  METHOD save_modified.

********************************************************************************
*
* Implements additional save
*
********************************************************************************

    DATA po_log        TYPE STANDARD TABLE OF ztb_po_log_table.
    DATA po_log_create TYPE STANDARD TABLE OF ztb_po_log_table.
    DATA po_log_update TYPE STANDARD TABLE OF ztb_po_log_table.

    " (1) Get instance data of all instances that have been created
    IF create-zi_po_hds_dt IS NOT INITIAL.
      " Creates internal table with instance data
      po_log = CORRESPONDING #( create-zi_po_hds_dt ).

      LOOP AT po_log ASSIGNING FIELD-SYMBOL(<po_log>).
        <po_log>-changing_operation = 'CREATE'.

        " Generate time stamp
        GET TIME STAMP FIELD <po_log>-created_at.

        " Read Header instance data into ls_po that includes %control structure
        READ TABLE create-zi_po_hds_dt WITH TABLE KEY entity COMPONENTS Ponum = <po_log>-po INTO DATA(ls_po).
        IF sy-subrc = 0.

          " If new value of the booking_fee field created
          IF ls_po-%control-Plant = cl_abap_behv=>flag_changed.
            " Generate uuid as value of the change_id field
            TRY.
                <po_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ) .
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
            <po_log>-changed_field_name = 'plant'.
            <po_log>-changed_value = ls_po-Plant.
            APPEND <po_log> TO po_log_create.
          ENDIF.

          " If new value of the overall_status field created
          IF ls_po-%control-Status = cl_abap_behv=>flag_changed.
            " Generate uuid as value of the change_id field
            TRY.
                <po_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ) .
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
            <po_log>-changed_field_name = 'overall_status'.
            <po_log>-changed_value = ls_po-Status.
            APPEND <po_log> TO po_log_create.
          ENDIF.

        ENDIF.

      ENDLOOP.

      " Inserts rows specified in po_log_create into the DB table ztb_po_log_table
      INSERT ztb_po_log_table FROM TABLE @po_log_create.

    ENDIF.

    " (2) Get instance data of all instances that have been updated during the transaction
    IF update-zi_po_hds_dt IS NOT INITIAL.

      po_log = CORRESPONDING #( update-zi_po_hds_dt ).

      LOOP AT update-zi_po_hds_dt ASSIGNING FIELD-SYMBOL(<po_log_update>).

        ASSIGN po_log[ po = <po_log_update>-Ponum ] TO FIELD-SYMBOL(<po_log_db>).

        <po_log_db>-changing_operation = 'UPDATE'.

        " Generate time stamp
        GET TIME STAMP FIELD <po_log_db>-created_at.


        IF <po_log_update>-%control-Plant = if_abap_behv=>mk-on.
          <po_log_db>-changed_value = <po_log_update>-Plant.
          " Generate uuid as value of the change_id field
          TRY.
              <po_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static( ) .
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.

          <po_log_db>-changed_field_name = 'plant'.

          APPEND <po_log_db> TO po_log_update.

        ENDIF.

        IF <po_log_update>-%control-Compcode = if_abap_behv=>mk-on.
          <po_log_db>-changed_value = <po_log_update>-Compcode.

          " Generate uuid as value of the change_id field
          TRY.
              <po_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static( ) .
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.

          <po_log_db>-changed_field_name = 'description'.

          APPEND <po_log_db> TO po_log_update.

        ENDIF.

      ENDLOOP.


      " Inserts rows specified in po_log_update into the DB table ztb_po_log_table
      INSERT ztb_po_log_table FROM TABLE @po_log_update.

    ENDIF.

    " (3) Get keys of all travel instances that have been deleted during the transaction
    IF delete-zi_po_hds_dt IS NOT INITIAL.

      po_log = CORRESPONDING #( delete-zi_po_hds_dt ).
      LOOP AT po_log ASSIGNING FIELD-SYMBOL(<po_log_delete>).
        <po_log_delete>-changing_operation = 'DELETE'.
        " Generate time stamp
        GET TIME STAMP FIELD <po_log_delete>-created_at.
        " Generate uuid as value of the change_id field
        TRY.
            <po_log_delete>-change_id = cl_system_uuid=>create_uuid_x16_static( ) .
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.

      ENDLOOP.

      " Inserts rows specified in po_log into the DB table ztb_po_log_table
      INSERT ztb_po_log_table FROM TABLE @po_log.

    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
