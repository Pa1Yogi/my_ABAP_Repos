@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View for PO Items'
@Metadata.ignorePropagatedAnnotations: false
define view entity ZR_PO_IS_DT_D
  as select from ztb_a_po_its_d

  association to parent ZR_PO_HD_DT_D as _Header on  $projection.PoNum  = _Header.PoNum
                                                 and $projection.PoUuid = _Header.PoUuid

{
  key po_num                as PoNum,
  key po_item               as PoItem,
  key po_item_uuid          as PoItemUuid,
      parent_uuid           as PoUuid,
      item_text             as ItemText,
      material              as Material,
      plant                 as Plant,
      storloc               as Storloc,
      qty                   as Qty,
      uom                   as Uom,
      product_price         as ProductPrice,
      price_unit            as PriceUnit,

      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Header
}
