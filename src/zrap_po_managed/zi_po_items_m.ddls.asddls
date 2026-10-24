@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View for PO Items'
@Metadata.ignorePropagatedAnnotations: false
define view entity ZI_PO_ITEMS_M
  as select from ztb_po_items_m

  association to parent ZI_PO_HEAD_M as _Header on $projection.PoNum = _Header.PoNum

{
  key po_num          as PoNum,
  key po_item         as PoItem,
      item_text       as ItemText,
      material        as Material,
      plant           as Plant,
      storloc         as Storloc,
      qty             as Qty,
      uom             as Uom,
      product_price   as ProductPrice,
      price_unit      as PriceUnit,
      
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,

      _Header
}
