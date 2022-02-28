CLASS ltcl_film DEFINITION DEFERRED FOR TESTING.
CLASS lhc_Film DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltcl_film.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF film_status,
        planned  TYPE c LENGTH 1 VALUE 'P', "Planned
        accepted TYPE c LENGTH 1 VALUE 'A', "Accepted
        canceled TYPE c LENGTH 1 VALUE 'X', "Canceled
      END OF film_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Film RESULT result.
    METHODS set_first_status FOR DETERMINE ON MODIFY
      IMPORTING keys FOR film~set_first_status.
    METHODS acceptfilm FOR MODIFY
      IMPORTING keys FOR ACTION film~acceptfilm RESULT result.

    METHODS cancelfilm FOR MODIFY
      IMPORTING keys FOR ACTION film~cancelfilm RESULT result.
    METHODS calculatefilmid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR film~calculatefilmid.
    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR film~validatedates.

    METHODS validategroup FOR VALIDATE ON SAVE
      IMPORTING keys FOR film~validategroup.
    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR film~validatestatus.

    "
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR film RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR film RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR film RESULT result.

    METHODS is_create_granted
      RETURNING VALUE(create_granted) TYPE abap_bool.
    METHODS is_update_granted
      RETURNING VALUE(update_granted) TYPE abap_bool.
    METHODS is_delete_granted
      RETURNING VALUE(delete_granted) TYPE abap_bool.

ENDCLASS.

CLASS lhc_Film IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD set_first_status.
    READ ENTITIES OF ziss_i_film IN LOCAL MODE
           ENTITY Film
             FIELDS ( Status ) WITH CORRESPONDING #( keys )
           RESULT DATA(films).

    DELETE films WHERE Status IS NOT INITIAL.
    CHECK films IS NOT INITIAL.

    MODIFY ENTITIES OF ziss_i_film IN LOCAL MODE
    ENTITY Film
      UPDATE
        FIELDS ( Status )
        WITH VALUE #( FOR film IN films
                      ( %tky         = film-%tky
                        Status = 'P' ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD acceptFilm.
    " modify film instance
    MODIFY ENTITIES OF ziss_i_film IN LOCAL MODE
      ENTITY Film
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( %tky           = key-%tky
                                        Status = film_status-accepted ) )  " 'A'
    FAILED failed
    REPORTED reported.

    " read changed data for action result
    READ ENTITIES OF ziss_i_film IN LOCAL MODE
      ENTITY Film
        ALL FIELDS WITH
        CORRESPONDING #( keys )
      RESULT DATA(films).

    result = VALUE #( FOR film IN films ( %tky   = film-%tky
                                              %param = film ) ).
  ENDMETHOD.

  METHOD cancelFilm.
    " modify film instance
    MODIFY ENTITIES OF ziss_i_film IN LOCAL MODE
      ENTITY Film
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( %tky           = key-%tky
                                        Status = film_status-canceled ) )  " 'X'
    FAILED failed
    REPORTED reported.

    " read changed data for action result
    READ ENTITIES OF ziss_i_film IN LOCAL MODE
      ENTITY Film
        ALL FIELDS WITH
        CORRESPONDING #( keys )
      RESULT DATA(lt_film).

    result = VALUE #( FOR ls_film IN lt_film ( %tky   = ls_film-%tky
                                                   %param = ls_film ) ).
  ENDMETHOD.

  METHOD calculateFilmID.
    SELECT SINGLE FROM ziss_film FIELDS MAX( filmid )
            INTO @DATA(lv_film_id).
    IF lv_film_id IS INITIAL.
      lv_film_id = 0.
    ENDIF.
    MODIFY ENTITIES OF ziss_i_film IN LOCAL MODE
        ENTITY Film
    UPDATE FROM VALUE #( FOR key IN keys ( FilmUUID = key-FilmUUID
                                            FilmID = lv_film_id + 1
                                     %control-FilmID = if_abap_behv=>mk-on ) ).
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF ziss_i_film IN LOCAL MODE
       ENTITY Film
         FIELDS ( StartDate EndDate )
         WITH CORRESPONDING #( keys )
       RESULT DATA(lt_film_result).

    LOOP AT lt_film_result INTO DATA(ls_film_result).

      IF ls_film_result-EndDate < ls_film_result-StartDate.  "end_date before start_date

        APPEND VALUE #( %key        = ls_film_result-%key
                        filmuuid    = ls_film_result-FilmUUID ) TO failed-film.

        APPEND VALUE #( %key = ls_film_result-%key
                        %msg     = new_message( id       = zcm_cinema_iss=>enddate_not_greater_startdate-msgid
                                                number   = zcm_cinema_iss=>enddate_not_greater_startdate-msgno
                                                v1       = ls_film_result-StartDate
                                                v2       = ls_film_result-EndDate
                                                severity = if_abap_behv_message=>severity-error )
                        %element-StartDate = if_abap_behv=>mk-on
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-film.

      ELSEIF ls_film_result-StartDate < cl_abap_context_info=>get_system_date( ).  "start_date must be in the future

        APPEND VALUE #( %key       = ls_film_result-%key
                        filmuuid   = ls_film_result-FilmUUID ) TO failed-film.

        APPEND VALUE #( %key = ls_film_result-%key
                        %msg = new_message( id       = zcm_cinema_iss=>start_date_less_then_today-msgid
                                            number   = zcm_cinema_iss=>start_date_less_then_today-msgno
                                            severity = if_abap_behv_message=>severity-error )
                        %element-StartDate = if_abap_behv=>mk-on
                        %element-EndDate   = if_abap_behv=>mk-on )
                        TO reported-film.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateGroup.
    READ ENTITIES OF ziss_i_film IN LOCAL MODE
    ENTITY Film
     FIELDS ( GroupID )
     WITH CORRESPONDING #(  keys )
    RESULT DATA(lt_film).

    DATA lt_group TYPE SORTED TABLE OF ziss_group WITH UNIQUE KEY groupid.

    lt_group = CORRESPONDING #(  lt_film DISCARDING DUPLICATES MAPPING groupid = GroupID EXCEPT * ).

    DELETE lt_group WHERE groupid IS INITIAL.

    IF  lt_group IS NOT INITIAL.

      SELECT FROM ziss_group FIELDS groupid
        FOR ALL ENTRIES IN @lt_group
        WHERE groupid = @lt_group-groupid
        INTO TABLE @DATA(lt_group_db).
    ENDIF.

    LOOP AT lt_film INTO DATA(ls_film).

      IF ls_film-GroupID IS INITIAL OR NOT line_exists( lt_group_db[ groupid = ls_film-GroupID ] ).
        APPEND VALUE #( %tky = ls_film-%tky ) TO failed-film.

        APPEND VALUE #( %tky = ls_film-%tky
                        %msg = new_message( id        = zcm_cinema_iss=>film_group-msgid
                                            number    = zcm_cinema_iss=>film_group-msgno
                                            severity  = if_abap_behv_message=>severity-error )
                        %element-GroupID = if_abap_behv=>mk-on )

          TO reported-film.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITIES OF ziss_i_film IN LOCAL MODE
          ENTITY Film
            FIELDS ( Status )
            WITH CORRESPONDING #( keys )
          RESULT DATA(lt_film_result).

    LOOP AT lt_film_result INTO DATA(ls_film_result).
      CASE ls_film_result-Status.
        WHEN film_status-planned OR film_status-canceled OR film_status-accepted.
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_film_result-%key ) TO failed-film.
          APPEND VALUE #( %key = ls_film_result-%key
                          %msg = new_message( id       = zcm_cinema_iss=>status_is_not_valid-msgid
                                              number   = zcm_cinema_iss=>status_is_not_valid-msgno
                                              v1       = ls_film_result-Status
                                              severity = if_abap_behv_message=>severity-error )
                          %element-Status = if_abap_behv=>mk-on ) TO reported-film.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.



  METHOD get_global_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.
      IF is_create_granted( ) = abap_true.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg    = NEW zcm_cinema_iss(
                                       textid   = zcm_cinema_iss=>not_authorized
                                       severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on
                      ) TO reported-film.

      ENDIF.
    ENDIF.

    "Edit is treated like update
    IF requested_authorizations-%update                =  if_abap_behv=>mk-on OR
       requested_authorizations-%action-Edit           =  if_abap_behv=>mk-on OR
       requested_authorizations-%action-acceptFilm     =  if_abap_behv=>mk-on OR
       requested_authorizations-%action-cancelFilm     =  if_abap_behv=>mk-on.

      IF  is_update_granted( ) = abap_true.
        result-%update                =  if_abap_behv=>auth-allowed.
        result-%action-Edit           =  if_abap_behv=>auth-allowed.

      ELSE.
        result-%update                =  if_abap_behv=>auth-unauthorized.
        result-%action-Edit           =  if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg    = NEW zcm_cinema_iss(
                                       textid   = zcm_cinema_iss=>not_authorized
                                       severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on
                      ) TO reported-film.
      ENDIF.
    ENDIF.

    IF requested_authorizations-%delete =  if_abap_behv=>mk-on.
      IF is_delete_granted( ) = abap_true.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg    = NEW zcm_cinema_iss(
                                       textid   = zcm_cinema_iss=>not_authorized
                                       severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on
                       ) TO reported-film.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD is_create_granted.
    AUTHORITY-CHECK OBJECT 'Z_AUTH_TST' ID 'ACTVT' FIELD '01'.
    create_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
    "create_granted = abap_true.
  ENDMETHOD.

  METHOD is_delete_granted.
    AUTHORITY-CHECK OBJECT 'Z_AUTH_TST' ID 'ACTVT' FIELD '06'.
    delete_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
    "delete_granted = abap_true.
  ENDMETHOD.

  METHOD is_update_granted.
    AUTHORITY-CHECK OBJECT 'Z_AUTH_TST' ID 'ACTVT' FIELD '02'.
    update_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
    "update_granted = abap_true.
  ENDMETHOD.
ENDCLASS.
