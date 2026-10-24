@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for PO Head'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.usageType:{
serviceQuality: #X,
sizeCategory: #S,
dataClass: #MIXED
}
@UI:{ headerInfo: {
typeName: 'Purchase Order',
typeNamePlural: 'Purchase Orders',
title: {
type: #STANDARD,
value: 'PoNum'
}
} }
define root view entity ZC_PO_HEADER_DT
  as projection on ZI_PO_HEADER_DT
{
      @Search.defaultSearchElement: true
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
      _PO_items : redirected to composition child ZC_PO_ITEMS_DT
}
