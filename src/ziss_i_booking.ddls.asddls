@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Booking View'


define view entity ZISS_I_BOOKING
  as select from ziss_booking as Booking

  association        to parent ZISS_I_FILM as _Film     on $projection.FilmUUID = _Film.FilmUUID
  association [0..1] to I_Currency         as _Currency on $projection.Currency = _Currency.Currency

{
  key filmuuid                        as FilmUUID,
  key bookinguuid                     as BookingUUID,
      bookingid                       as BookingID,
      quantity                        as Quantity,
      filmdate                        as FilmDate,
      @Semantics.amount.currencyCode: 'Currency'
      netamount                       as NetAmount,
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
      _Film,
      _Currency
}
