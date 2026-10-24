CLASS zcl_tb_maintain DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_tb_maintain IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: it_po       TYPE TABLE OF ztb_po_head_u,
          it_po_items TYPE TABLE OF ztb_po_items_u,
          it_vend     TYPE TABLE OF ztb_vendor.

*    it_po = VALUE #( ( po_num = '4500000001' type = 'NB' doc_cat = 'B' vendor = '12345'
*                       org = 'ABC' status = '1' comp_code = '100' approved = 'X' )
*                     ( po_num = '4500000002' type = 'NB' doc_cat = 'B' vendor = '3456'
*                       org = 'CDE' status = '1' comp_code = '100' )
*                     ( po_num = '4500000003' type = 'NB' doc_cat = 'C' vendor = '12345'
*                       org = 'ABC' status = '1' comp_code = '100' approved = 'X' )
*                     ( po_num = '4500000004' type = 'NB' doc_cat = 'A' vendor = '4567'
*                       org = 'BCD' status = '1' comp_code = '100' approved = 'X' )
*                     ( po_num = '4500000005' type = 'NB' doc_cat = 'B' vendor = '12345'
*                       org = 'ABC' status = '2' comp_code = '100' )  ).
*
*    MODIFY ztb_po_head_u FROM TABLE @it_po.
*
*    it_po_items = VALUE #( ( po_num = '4500000001' po_item = '10' item_text = 'Item' material = 'Mat1' plant = '0001'
*                             storloc = '0001' qty = '5' uom = 'KG' product_price = '15000' price_unit = 'INR' )
*                           ( po_num = '4500000001' po_item = '20' item_text = 'Item' material = 'Mat2' plant = '0001'
*                             storloc = '0001' qty = '2' uom = 'KG' product_price = '15000' price_unit = 'INR' )
*
*                           ( po_num = '4500000002' po_item = '10' item_text = 'Item' material = 'Mat1' plant = '0001'
*                             storloc = '0001' qty = '1' uom = 'KG' product_price = '15000' price_unit = 'INR' )
*
*                           ( po_num = '4500000003' po_item = '10' item_text = 'Item' material = 'Mat1' plant = '0001'
*                             storloc = '0001' qty = '3' uom = 'KG' product_price = '15000' price_unit = 'INR' )
*
*                           ( po_num = '4500000004' po_item = '10' item_text = 'Item' material = 'Mat1' plant = '0001'
*                             storloc = '0001' qty = '5' uom = 'KG' product_price = '15000' price_unit = 'INR' )
*                           ( po_num = '4500000004' po_item = '20' item_text = 'Item' material = 'Mat1' plant = '0001'
*                             storloc = '0001' qty = '2' uom = 'KG' product_price = '15000' price_unit = 'INR' )
*
*                           ( po_num = '4500000005' po_item = '10' item_text = 'Item' material = 'Mat1' plant = '0001'
*                             storloc = '0001' qty = '3' uom = 'KG' product_price = '15000' price_unit = 'INR' )
*                           ( po_num = '4500000005' po_item = '20' item_text = 'Item' material = 'Mat2' plant = '0001'
*                             storloc = '0002' qty = '3' uom = 'KG' product_price = '15000' price_unit = 'INR' )
*                           ( po_num = '4500000005' po_item = '30' item_text = 'Item' material = 'Mat3' plant = '0001'
*                             storloc = '' qty = '2' uom = 'KG' product_price = '15000' price_unit = 'INR' )  ).
**
*    MODIFY ztb_po_items_u FROM TABLE @it_po_items.

    it_vend = VALUE #( ( vendor = '0000001234' vendordesc = 'Vendor1' )
                       ( vendor = '0000012345' vendordesc = 'Vendor2' )
                       ( vendor = '2345' vendordesc = 'Vendor3' )
                       ( vendor = '3456' vendordesc = 'Vendor4' )
                       ( vendor = '4567' vendordesc = 'Vendor5' ) ).
*
    MODIFY ztb_vendor FROM TABLE @it_vend.

*    DELETE FROM ztb_a_po_head_d WHERE po_num EQ '       20'. " and po_num EQ '       20'.
*    DELETE FROM ztb_pohead_dt.
*    DELETE FROM ztb_po_items_u.
*    DELETE FROM ztb_d_po_head_d.



  ENDMETHOD.
ENDCLASS.
