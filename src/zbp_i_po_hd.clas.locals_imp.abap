CLASS lhc_ZI_PO_HD DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_po_hd RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_po_hd RESULT result.

    METHODS approval FOR MODIFY
      IMPORTING keys FOR ACTION zi_po_hd~approval RESULT result.

ENDCLASS.

CLASS lhc_ZI_PO_HD IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD Approval.

   READ ENTITIES OF zi_po_hd IN LOCAL MODE ENTITY zi_po_hd
   ALL FIELDS WITH CORRESPONDING #( keys )
   RESULT DATA(lt).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_PO_HD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_PO_HD IMPLEMENTATION.

  METHOD save_modified.
   DATA: ls type ZI_PO_HD,
         lt TYPE TABLE of ZI_PO_HD,
         ls_t TYPE zat_po_hd,
         lt_t TYPE TABLE of zat_po_hd.

        lt = CORRESPONDING #( update-zi_po_hd MAPPING FROM ENTITY ).

        LOOP at lt_t ASSIGNING FIELD-SYMBOL(<fs>).
         ls_t-po_num = <fs>-po_num.
         ls_t-type = <fs>-type.
         APPEND ls_t to lt_t.
        ENDLOOP.

        INSERT zat_po_hd FROM TABLE @lt_t.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
