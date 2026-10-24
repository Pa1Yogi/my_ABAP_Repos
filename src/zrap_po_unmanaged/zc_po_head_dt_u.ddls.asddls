@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for PO Head'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_PO_HEAD_DT_U
 provider contract transactional_query
 as projection on ZI_PO_HEAD_DT_U
{
    key PoNum,
    DocCat,
    Type,
    CompCode,
    Org,
    Status,
    Vendor,
    Approved,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    
    /* Associations */
      _Items : redirected to composition child ZC_PO_ITEMS_DT_U
}
