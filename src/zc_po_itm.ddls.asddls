@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Items Consumption view'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_PO_ITM as projection on ZI_PO_ITEMS
{
    key PoNum as PoNum,
    key PoItem,
    ItemText,
    Material,
    Plant,
    MatGroup,
    PoQty,
    Uom,
    ProductPrice,
    PriceUnit,
    LocalLastChangedBy,
    LocalLastChangedAt,
    /* Associations */
    _hd : redirected to parent ZC_PO_HD
}
