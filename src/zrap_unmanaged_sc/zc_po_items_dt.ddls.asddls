@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for PO Items'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
serviceQuality: #X,
sizeCategory: #S,
dataClass: #MIXED
}
define view entity ZC_PO_ITEMS_DT as projection on ZI_PO_ITEMS_DT
{
    key PoNum,
    key PoItem,
    ItemText,
    Material,
    Plant,
    StorLoc,
    Qty,
    Uom,
    ProductPrice,
    PriceUnit,
    LocalLastChangedBy,
    LocalLastChangedAt,
    CreatedBy,
    CreatedDateTime,
    ChangedDateTime,
//    LastChangedAt,
    /* Associations */
    _po_hd : redirected to parent ZC_PO_HEADER_DT
}
