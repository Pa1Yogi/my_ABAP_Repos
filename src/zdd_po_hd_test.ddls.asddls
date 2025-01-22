@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO HD Test'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZDD_PO_HD_TEST as select from ZI_PO_HD
{   
    key PoNum,
    Description,
    OrderType,
    CompanyCode,
    Organization,
    POStatus,
    Vendor,
    CreateBy,
    CreatedDateTime,
    ChangedDateTime,
    LocalLastChangedBy
}
