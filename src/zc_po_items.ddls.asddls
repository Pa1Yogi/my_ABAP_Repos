@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for PO Items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_PO_ITEMS 
 as projection on ZI_PO_ITMS
{
    key PoNum,
    key PoItem,
    ItemText,
    Material,
    Plant,
    StorLoc,
    @Semantics.quantity.unitOfMeasure: 'uom'
    Qty,
    Uom,
    @Semantics.amount.currencyCode: 'PriceUnit'
    ProductPrice,
    PriceUnit,
    LocalLastChangedBy,
    LocalLastChangedAt,
    /* Associations */
    _po_hd : redirected to parent ZC_PO_HEAD
}
