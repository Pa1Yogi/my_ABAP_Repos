@EndUserText.label: 'Abstract Entity of PO Items'
define abstract entity ZA_PO_ITMS
//  with parameters parameter_name : parameter_type
{
    key po_num                : ebeln;
  key po_item               : ebelp;
      item_text             : abap.char(40);
      material              : abap.char(40);
      plant                 : werks_d;
      stor_loc              : lgort_d;
      uom                   : abap.unit(3);
      @Semantics.quantity.unitOfMeasure : 'uom'
      qty                   : abap.quan(13,3);
      @Semantics.amount.currencyCode: 'price_unit'
      product_price         : abap.curr(10,2);
      price_unit            : abap.cuky;
      local_last_changed_by : abp_locinst_lastchange_user;
      local_last_changed_at : abp_locinst_lastchange_time;
      created_by            : abp_creation_user;
      created_date_time     : abp_creation_tstmpl;
      changed_date_time     : abp_locinst_lastchange_tstmpl;
      last_changed_at       : abp_lastchange_tstmpl;

      _ItemtoHd             : association to parent ZA_PO_HD on $projection.po_num = _ItemtoHd.po_num;
    
}
