@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Definition for Items Table'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PO_ITEMS_DT
  as select from ztb_poitems
  association to parent ZI_PO_HEADER_DT as _po_hd on $projection.PoNum = _po_hd.PoNum
{
  key po_num                as PoNum,
  key po_item               as PoItem,
      item_text             as ItemText,
      material              as Material,
      plant                 as Plant,
      stor_loc              as StorLoc,
      qty                   as Qty,
      uom                   as Uom,
      product_price         as ProductPrice,
      price_unit            as PriceUnit,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      created_by            as CreatedBy,
      created_date_time     as CreatedDateTime,
      changed_date_time     as ChangedDateTime,
//      last_changed_at       as LastChangedAt,
      _po_hd
}
