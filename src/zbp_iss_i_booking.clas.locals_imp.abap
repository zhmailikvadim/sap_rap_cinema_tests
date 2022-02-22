CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateAmount.

    METHODS calculateBookingID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateBookingID.
    METHODS validateFilmDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateFilmDate.


ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD calculateAmount.
   READ ENTITIES OF ziss_i_film IN LOCAL MODE
           ENTITY Booking
             FIELDS ( FilmDate Quantity ) WITH CORRESPONDING #( keys )
           RESULT DATA(lt_booking).
    READ ENTITIES OF ziss_i_film IN LOCAL MODE
    ENTITY Film
      FIELDS ( Currency Price ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_film).
    LOOP AT lt_booking INTO DATA(ls_booking).
      ASSIGN lt_film[ KEY entity COMPONENTS FilmUUID = ls_booking-FilmUUID ]
          TO FIELD-SYMBOL(<fs_film>).
      MODIFY ENTITIES OF ziss_i_film IN LOCAL MODE
          ENTITY Booking
      UPDATE FROM VALUE #( FOR key IN keys ( BookingUUID = key-BookingUUID
                                              FilmUUID = key-FilmUUID
                                              Currency = <fs_film>-Currency
                                              Netamount = <fs_film>-Price * ls_booking-Quantity
                                    %control-Currency = if_abap_behv=>mk-on
                                     %control-Netamount = if_abap_behv=>mk-on ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD calculateBookingID.
  SELECT SINGLE FROM ziss_booking FIELDS MAX( bookingid )
          INTO @DATA(lv_booking_id).
    IF lv_booking_id IS INITIAL.
      lv_booking_id = 0.
    ENDIF.
    MODIFY ENTITIES OF ziss_i_film IN LOCAL MODE
        ENTITY Booking
    UPDATE FROM VALUE #( FOR key IN keys ( FilmUUID = key-FilmUUID
                                           BookingUUID = key-BookingUUID
                                            BookingID = lv_booking_id + 1
                                     %control-BookingID = if_abap_behv=>mk-on ) ).
  ENDMETHOD.

  METHOD validateFilmDate.
  READ ENTITIES OF ziss_i_film IN LOCAL MODE
            ENTITY Booking
            FIELDS ( FilmDate )
            WITH CORRESPONDING #( keys )
            RESULT DATA(lt_booking).
    READ ENTITIES OF ziss_i_film IN LOCAL MODE
    ENTITY Film
    FIELDS ( StartDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_film).
    LOOP AT lt_booking INTO DATA(ls_booking).
      IF ls_booking-FilmDate IS NOT INITIAL.
        ASSIGN lt_film[ KEY entity COMPONENTS FilmUUID = ls_booking-FilmUUID ]
                TO FIELD-SYMBOL(<fs_film>).
        IF ls_booking-FilmDate <= <fs_film>-StartDate.
          APPEND VALUE #( bookinguuid = ls_booking-BookingUUID ) TO failed-booking.
          APPEND VALUE #( bookinguuid = ls_booking-BookingUUID
                      %msg = new_message( id = zcm_cinema_iss=>less_start_date-msgid
                                      number = zcm_cinema_iss=>less_start_date-msgno
                                          v1 = ls_booking-FilmDate
                                          v2 = <fs_film>-StartDate
                                    severity = if_abap_behv_message=>severity-error )
                      %element-filmdate = if_abap_behv=>mk-on ) TO reported-booking.
        ELSEIF ls_booking-FilmDate > <fs_film>-EndDate.
          APPEND VALUE #( bookinguuid = ls_booking-BookingUUID ) TO failed-booking.
          APPEND VALUE #( bookinguuid = ls_booking-BookingUUID
                      %msg = new_message( id = zcm_cinema_iss=>greater_end_date-msgid
                                      number = zcm_cinema_iss=>greater_end_date-msgno
                                          v1 = ls_booking-FilmDate
                                          v2 = <fs_film>-Enddate
                                    severity = if_abap_behv_message=>severity-error )
                      %element-filmdate = if_abap_behv=>mk-on ) TO reported-booking.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
