@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Head'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity ZI_PO_HD 
  as select from zat_po_hd
 // association [0..*] to ZI_PO_ITEMS as _po_item  on $projection.PoNum = _po_item.PoNum
  composition [0..*] of ZI_PO_ITEMS as _po_item
{   
    
    key po_num as PoNum,
    po_desc as Description,
    type as OrderType,
    comp_code as CompanyCode,
    org as Organization,
    status as POStatus,
    vendor as Vendor,
    create_by as CreateBy,
    created_date_time as CreatedDateTime,
    changed_date_time as ChangedDateTime,
    local_last_changed_by as LocalLastChangedBy,
    _po_item
}
