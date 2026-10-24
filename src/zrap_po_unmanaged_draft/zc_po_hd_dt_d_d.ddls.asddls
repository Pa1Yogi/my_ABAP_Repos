@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for PO Head'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_PO_HD_DT_D_D
  provider contract transactional_query
  as projection on ZR_PO_HD_DT_D
{
      @Search.defaultSearchElement: true
  key PoNum,
  key PoUuid,
      DocCat,
      Type,
      CompCode,
      Org,
      Status,
      Vendor,
      Approved,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _Items : redirected to composition child ZC_PO_IS_DT_D_D
}
