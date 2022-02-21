@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Film View'

define root view entity ZISS_I_FILM
  as select from ziss_film as Film

  composition [0..*] of ZISS_I_BOOKING as _Booking
  association [0..1] to ZISS_I_GROUP   as _FilmGroup on $projection.GroupID = _FilmGroup.GroupID
  association [0..1] to I_Currency     as _Currency  on $projection.Currency = _Currency.Currency

{
  key filmuuid                        as FilmUUID,
      filmid                          as FilmID,
      filmname                        as FilmName,
      groupid                         as GroupID,
      status                          as Status,
      startdate                       as StartDate,
      enddate                         as EndDate,
      filmtime                        as FilmTime,
      country                         as Country,
      director                        as Director,
      price                           as Price,
      currency                        as Currency,
      @Semantics.user.createdBy: true
      case createdby
       when 'CB9980000150' then 'Isaichkina'
         else 'Another user'
       end                            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      cast(creationtime as timestamp) as CreationTime,
      @Semantics.user.lastChangedBy: true
      case changedby
       when 'CB9980000150' then 'Isaichkina'
         else 'Another user'
       end                            as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      cast(changetime as timestamp)   as ChangeTime,

      _Booking,
      _FilmGroup,
      _Currency

}
