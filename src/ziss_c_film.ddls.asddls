@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Film Projection View'
@Metadata.allowExtensions: true
@Search.searchable: true
@UI: {
  headerInfo: { typeName: 'Film',
                typeNamePlural: 'Films',
                title: { type: #STANDARD, label:'Film', value: 'FilmID' }}}
define root view entity ZISS_C_FILM
  as projection on ZISS_I_FILM
{
      @UI.facet: [ { id:              'General_Information',
                                  purpose:         #STANDARD,
                                  type:            #COLLECTION,
                                  label:           'General Information',
                                  position:        10 },

                       { id: 'Basic_Data',
                         type: #FIELDGROUP_REFERENCE,
                         label: 'Basic Data',
                         parentId: 'General_Information',
                         targetQualifier: 'Basic_Data',
                         position: 10 },
                       { id: 'Additional_Data',
                         type: #FIELDGROUP_REFERENCE,
                         label: 'Additional Data',
                         parentId: 'General_Information',
                         targetQualifier: 'Additional_Data',
                         position: 20 },
                       { id: 'Price_Details',
                         type: #FIELDGROUP_REFERENCE,
                         label: 'Price Details',
                         parentId: 'General_Information',
                         targetQualifier: 'Price_Details',
                         position: 30 }]
      @UI.hidden: true
  key FilmUUID,
      @UI: {  lineItem:       [ { position: 10 } ],
                    identification: [ { position: 10 } ],
                    fieldGroup: [ { qualifier: 'Basic_Data', position: 10}],
                    selectionField: [ { position: 10 } ],
                    dataPoint: { title: 'FilmID' } }
      FilmID,
      @UI: {  lineItem:       [ { position: 20 } ],
                    identification: [ { position: 20 } ],
                    fieldGroup: [ { qualifier: 'Basic_Data', position: 20}],
                    selectionField: [ { position: 20 } ],
                    dataPoint: { title: 'Film Name' } }
      FilmName,
      @UI: {  lineItem:       [ { position: 30 } ],
                    identification: [ { position: 30 } ],
                    fieldGroup: [ { qualifier: 'Basic_Data', position: 30}],
                    selectionField: [ { position: 30 } ]}
      @Consumption.valueHelpDefinition: [ {
      entity: {
      name: 'ZISS_I_GROUP',
      element: 'GroupID'
      }
      } ]
      GroupID,
       @UI: {  lineItem:       [ { position: 40 },
                            { type: #FOR_ACTION, dataAction: 'acceptFilm', label: 'Accept' },
                            { type: #FOR_ACTION, dataAction: 'cancelFilm', label: 'Cancel a Film' }
                          ],
          identification: [ { position: 40 },
                            { type: #FOR_ACTION, dataAction: 'acceptFilm', label: 'Accept' },
                            { type: #FOR_ACTION, dataAction: 'cancelFilm', label: 'Cancel a Film' }
                          ] } 
    @UI.fieldGroup: [ { qualifier: 'Basic_Data', position: 30}] 
      Status,
      @UI: {  lineItem:       [ { position: 40 } ],
                identification: [ { position: 40 } ],
                 fieldGroup: [ { qualifier: 'Additional_Data', position: 10 } ]}
      StartDate,
      @UI: {  lineItem:       [ { position: 50 } ],
               identification: [ { position: 50 } ],
                fieldGroup: [ { qualifier: 'Additional_Data', position: 20 } ]}
      EndDate,
      @UI: {  lineItem:       [ { position: 50 } ],
               identification: [ { position: 50 } ],
                fieldGroup: [ { qualifier: 'Additional_Data', position: 30 } ]}
      FilmTime,
      @UI: {  lineItem:       [ { position: 60 } ],
               identification: [ { position: 60 } ],
                fieldGroup: [ { qualifier: 'Additional_Data', position: 40 } ]}
      Country,
      @UI: {  lineItem:       [ { position: 70 } ],
               identification: [ { position: 70 } ],
                fieldGroup: [ { qualifier: 'Additional_Data', position: 50 } ]}
      Director,
      @UI: {  lineItem:       [ { position: 80 } ],
                identification: [ { position: 80 } ],
                fieldGroup: [ { qualifier: 'Price_Details', position: 10 } ],
                  dataPoint: { title: 'Net Price'} }
      //      @Semantics.amount.currencyCode:'Currency'
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      Price,
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
      @UI.facet: [ { id: 'Bookings',
               purpose: #STANDARD,
               type: #LINEITEM_REFERENCE,
               label: 'Bookings',
               position: 30,
               targetElement: '_Booking' }]
      _Booking : redirected to composition child ZISS_C_BOOKING,
      _Currency,
      _FilmGroup
}
