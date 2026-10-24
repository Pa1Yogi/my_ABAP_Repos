CLASS zcl_po_messages DEFINITION
  PUBLIC
   INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_t100_message .

    CONSTANTS:

      BEGIN OF not_sufficient_numbers,
        msgid TYPE symsgid VALUE 'Z_MSG_CLASS',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_sufficient_numbers,

      BEGIN OF number_range_depleted,
        msgid TYPE symsgid VALUE 'Z_MSG_CLASS',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF number_range_depleted,

      BEGIN OF not_authorized,
        msgid TYPE symsgid VALUE 'Z_MSG_CLASS',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_authorized,

      BEGIN OF not_authorized_for_approve,
        msgid TYPE symsgid VALUE 'Z_MSG_CLASS',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_authorized_for_approve,

      BEGIN OF not_authorized_for_vendor,
        msgid TYPE symsgid VALUE 'Z_MSG_CLASS',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_authorized_for_vendor.

    METHODS constructor
      IMPORTING
        textid   LIKE if_t100_message=>t100key OPTIONAL
        attr1    TYPE string OPTIONAL
        attr2    TYPE string OPTIONAL
        attr3    TYPE string OPTIONAL
        attr4    TYPE string OPTIONAL
        approve  TYPE char1 OPTIONAL
        vendor   TYPE lifnr OPTIONAL
        severity TYPE if_abap_behv_message=>t_severity OPTIONAL
        uname    TYPE syuname OPTIONAL.

    DATA:
      mv_attr1   TYPE string,
      mv_attr2   TYPE string,
      mv_attr3   TYPE string,
      mv_attr4   TYPE string,
      mv_approve TYPE c LENGTH 1,
      mv_vendor  TYPE lifnr,
      mv_uname   TYPE syuname.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_po_messages IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(  previous = previous ) .

    me->mv_attr1                 = attr1.
    me->mv_attr2                 = attr2.
    me->mv_attr3                 = attr3.
    me->mv_attr4                 = attr4.
    me->mv_approve               = approve.
    me->mv_vendor                = vendor.
    me->mv_uname                 = uname.


    if_abap_behv_message~m_severity = severity.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
