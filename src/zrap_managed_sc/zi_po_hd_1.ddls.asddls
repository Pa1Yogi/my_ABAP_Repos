@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Header'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PO_HD_1 as select from ZI_PO_HEADER_DTS
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
