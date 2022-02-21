@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Group View'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZISS_I_GROUP
  as select from ziss_group as FilmGroup
{
@Search.defaultSearchElement: true
      @ObjectModel.text.element: ['GroupName']
  key groupid   as GroupID,
      groupname as GroupName
}
