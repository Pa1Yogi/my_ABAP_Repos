@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for PO Items Draft'
@Metadata.ignorePropagatedAnnotations: false
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_PO_ITEMS_DT_D_D
  as projection on ZR_PO_ITEMS_DT_D
{
      @Search.defaultSearchElement: true
  key PoNum,
  key PoItem,
  key PoItemUuid,
      PoUuid,
      ItemText,
      Material,
      Plant,
      Storloc,
      Qty,
      Uom,
      ProductPrice,
      PriceUnit,
//      LocalLastChangedAt,

      /* Associations */
      _Header : redirected to parent ZC_PO_HEAD_DT_D_D
}
