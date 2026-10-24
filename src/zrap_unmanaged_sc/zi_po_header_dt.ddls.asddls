@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View for PO Head'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PO_HEADER_DT as select from ztb_pohead
//composition of target_data_source_name as _association_name
composition [0..*] of ZI_PO_ITEMS_DT as _PO_items
{
    
    key po_num                as PoNum,
      doc_cat               as DocCat,
      type                  as Type,
      comp_code             as CompCode,
      org                   as Org,
      status                as Status,
      vendor                as Vendor,
      plant                 as Plant,
      created_by            as CreatedBy,
      created_date_time     as CreatedDateTime,
      changed_date_time     as ChangedDateTime,
      local_last_changed_by as LocalLastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,
      //      _association_name // Make association public
      _PO_items
}
