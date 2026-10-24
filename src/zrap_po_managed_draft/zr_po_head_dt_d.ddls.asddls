@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Root View for PO Head'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_PO_HEAD_DT_D
  as select from ZTB_A_PO_HEAD_D
  
  composition [0..*] of ZR_PO_ITEMS_DT_D as _Items
  
{
  key po_num                as PoNum,
  key po_uuid               as PoUuid,
      doc_cat               as DocCat,
      type                  as Type,
      comp_code             as CompCode,
      org                   as Org,
      status                as Status,
      vendor                as Vendor,
      approved              as Approved,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,

      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      /* Associations */
      _Items

 
}
