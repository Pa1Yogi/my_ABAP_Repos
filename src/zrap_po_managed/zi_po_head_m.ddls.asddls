@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View for PO Head'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PO_HEAD_M
  as select from ztb_po_head_m
  composition [0..*] of ZI_PO_ITEMS_M as _Items
{
  key po_num          as PoNum,
      doc_cat         as DocCat,
      type            as Type,
      comp_code       as CompCode,
      org             as Org,
      status          as Status,
      vendor          as Vendor,
      approved        as Approved,

      @Semantics.user.createdBy: true
      created_by      as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,

      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,

      /* Associations */
      _Items
}
