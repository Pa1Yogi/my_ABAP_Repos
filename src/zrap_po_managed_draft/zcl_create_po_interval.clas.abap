CLASS zcl_create_po_interval DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_create_po_interval IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval = VALUE #( ( nrrangenr  = '01'
                                  fromnumber = '0000000001'
                                  tonumber   = '9999999999'
                                  procind    = 'I' ) )
            object   = 'ZNUM_OB_PO'
          IMPORTING
            error    = DATA(lv_error)
            warning  = DATA(lv_warning) ).

        IF lv_error IS INITIAL.
          COMMIT WORK.
          out->write( 'Interval 01 created.' ).
        ELSE.
          out->write( |Error creating interval| ).
        ENDIF.

      CATCH cx_number_ranges INTO DATA(lx).
        out->write( lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
