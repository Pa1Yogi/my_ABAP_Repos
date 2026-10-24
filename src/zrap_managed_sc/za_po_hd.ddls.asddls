@EndUserText.label: 'Abstract Entity of PO HD'
define root abstract entity ZA_PO_HD
 // with parameters parameter_name : parameter_type
{
     key po_num                : ebeln;
      doc_cat               : bstyp;
      type                  : abap.char(2);
      comp_code             : bukrs;
      org                   : ekorg;
      status                : abap.char(1);
      vendor                : lifnr;
      plant                 : werks_d;
      created_by            : abp_creation_user;
      created_date_time     : abp_creation_tstmpl;
      changed_date_time     : abp_locinst_lastchange_tstmpl;
      local_last_changed_by : abp_locinst_lastchange_user;
      last_changed_at       : abp_lastchange_tstmpl;
      local_last_changed_at : abp_locinst_lastchange_tstmpl;

      _HdtoItm              : composition [1..*] of ZA_PO_ITMS;
    
}
