@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PO_HDS_DT as select from ztb_pohead_dt
composition [0..*] of ZI_PO_ITS_DTS as _Items
{
    key ponum as Ponum,
    doccat as Doccat,
    type as Type,
    compcode as Compcode,
    org as Org,
    status as Status,
    vendor as Vendor,
    plant as Plant,
    @Semantics.user.createdBy: true 
    createdby as Createdby,
    @Semantics.systemDateTime.createdAt: true 
    created_at as CreatedAt,
    @Semantics.user.lastChangedBy: true 
    last_changed_by as LastChangedBy,
    //local ETag field --> OData ETag
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt,
    _Items // Make association public
}
