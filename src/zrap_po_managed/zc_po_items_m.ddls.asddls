@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for PO Items'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZC_PO_ITEMS_M as projection on ZI_PO_ITEMS_M
{
    key PoNum,
    key PoItem,
    ItemText,
    Material,
    Plant,
    Storloc,
    Qty,
    Uom,
    ProductPrice,
    PriceUnit,
    LastChangedAt,
    
    /* Associations */
    _Header : redirected to parent ZC_PO_HEAD_M
}
