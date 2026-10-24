CLASS zcx_po DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_abap_behv_message.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_t100_message.

    CONSTANTS:
      BEGIN OF type_unknown,
        msgid TYPE symsgid VALUE 'Z_PO_MSG',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'TYPE Not Allowed',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF type_unknown.

    METHODS constructor
      IMPORTING
        severity TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        textid   LIKE if_t100_message=>t100key OPTIONAL
        previous TYPE REF TO cx_root OPTIONAL
        type     TYPE char2 OPTIONAL.

    DATA  type  TYPE c LENGTH 2 READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_PO IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key =
        if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
    me->if_abap_behv_message~m_severity = severity.
    me->type = |{ type ALPHA = OUT }|.
  ENDMETHOD.
ENDCLASS.
