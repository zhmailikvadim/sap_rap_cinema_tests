@EndUserText.label: 'Booking Projection View'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@UI: {
  headerInfo: { typeName: 'Booking',
                typeNamePlural: 'Bookings',
                title: { type: #STANDARD, label:'Booking', value: 'BookingID' }}}
define view entity ZISS_C_BOOKING
  as projection on ZISS_I_BOOKING
{
  @UI.facet: [ { id: 'General_Information',
                        purpose: #STANDARD,
                        type: #COLLECTION,
                        label: 'General Information',
                        position: 10 },
                      { id: 'Basic_Data',
                        type: #FIELDGROUP_REFERENCE,
                        label: 'Basic Data',
                        parentId: 'General_Information',
                        targetQualifier: 'Basic_Data',
                        position: 10 }]
  @UI.hidden: true
  key FilmUUID,
  @UI.hidden: true
  key BookingUUID,
  @UI: {   lineItem:   [ { position: 10, importance: #HIGH } ],
       fieldGroup: [ { qualifier: 'Basic_Data', position: 10 } ],
       dataPoint: { title: 'Booking ID' } }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      BookingID,
      @UI: {   lineItem:   [ { position: 20, importance: #HIGH } ],
      fieldGroup: [ { qualifier: 'Basic_Data', position: 20 } ],
      selectionField: [ {position: 10 } ] }
      Quantity,
      @UI: {   lineItem:       [ { position: 30, importance: #HIGH } ],
             fieldGroup: [ { qualifier: 'Basic_Data', position: 30 } ],
             selectionField: [ {position: 30 } ] }
      @Search.defaultSearchElement: true
      FilmDate,
      @UI: {   lineItem:       [ { position: 50, importance: #HIGH } ],
         dataPoint:      { title: 'Net Amount' } }
      @Semantics.amount.currencyCode: 'Currency'
      NetAmount,
        @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Currency', 
      element: 'Currency'
    }
  } ]
      Currency,
       @UI.facet: [ { id: 'Admin_Data',
                   purpose: #STANDARD,
                   type: #COLLECTION,
                   label: 'Admin Data',
                   position: 20 },
                 { id: 'Create_Info',
                   type: #FIELDGROUP_REFERENCE,
                   label: 'Create Info',
                   parentId: 'Admin_Data',
                   targetQualifier: 'Create_Info',
                   position: 10 },
                 { id: 'Change_Info',
                   type: #FIELDGROUP_REFERENCE,
                   label: 'Change Info',
                   parentId: 'Admin_Data',
                   targetQualifier: 'Change_Info',
                   position: 20 } ]

      @UI: { fieldGroup: [ { qualifier: 'Create_Info', position: 10, label: 'Created By' } ] }
      CreatedBy,
      @UI: { fieldGroup: [ { qualifier: 'Create_Info', position: 20, label: 'Created At' } ] }
      CreationTime,
      @UI: { fieldGroup: [ { qualifier: 'Change_Info', position: 10, label: 'Changed By' } ] }
      ChangedBy,
      @UI: { fieldGroup: [ { qualifier: 'Change_Info', position: 20, label: 'Changed At'  } ] }
      ChangeTime,
      
      /* Associations */      
      _Currency,
      _Film : redirected to parent ZISS_C_FILM
}
