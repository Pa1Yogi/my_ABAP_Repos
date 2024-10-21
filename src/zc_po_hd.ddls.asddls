@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Head Consumption view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_PO_HD 
//as select from ZI_PO_HD
//composition of target_data_source_name as _association_name
provider contract transactional_query 
as projection on ZI_PO_HD
{
    key PoNum as PoNum,
    Description as Description,
    OrderType as OrderType ,
    CompanyCode as CompanyCode,
    Organization as Organization,
    POStatus,
    Vendor,
    CreateBy,
    CreatedDateTime,
    ChangedDateTime,
    LocalLastChangedBy,
    /* Associations */
    _po_item : redirected to composition child ZC_PO_ITM
 //   _association_name // Make association public
}
