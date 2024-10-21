@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZI_PO_ITEMS as select from zat_po_item
 association to parent ZI_PO_HD as _hd on $projection.PoNum = _hd.PoNum
{
    key po_num as PoNum,
    key po_item as PoItem,
    item_text as ItemText,
    material as Material,
    plant as Plant,
    mat_group as MatGroup,
    @Semantics.quantity.unitOfMeasure: 'uom'
    po_qty as PoQty,
    uom as Uom,
    @Semantics.amount.currencyCode: 'PriceUnit'
    product_price as ProductPrice,
    price_unit as PriceUnit,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    _hd
}
