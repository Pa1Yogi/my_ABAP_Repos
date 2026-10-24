@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_PO_HDS
  provider contract transactional_query
  as projection on ZI_PO_HEADER_DTS
{
  key PoNum,
      DocCat,
      Type,
      CompCode,
      Org,
      Status,
      Vendor,
      Plant,
      CreatedBy,
      CreatedDateTime,
      ChangedDateTime,
      LocalLastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _PO_items
}
