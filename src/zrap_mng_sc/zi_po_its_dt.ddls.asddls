@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Items'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZI_PO_ITS_DT
  as select from ztb_poitems_dt
  association to parent ZI_PO_HD_DT as _POHd on $projection.Ponum = _POHd.Ponum
{
  key ponum           as Ponum,
  key poitem          as Poitem,
      itemtext        as Itemtext,
      material        as Material,
      plant           as Plant,
      storloc         as Storloc,
      qty             as Qty,
      uom             as Uom,
      productprice    as Productprice,
      priceunit       as Priceunit,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,

      _POHd
}
