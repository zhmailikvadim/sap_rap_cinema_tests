CLASS zcm_cinema_iss DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      BEGIN OF film_group,
        msgid TYPE symsgid VALUE 'ZISS_CINEMA_MSG',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'GROUPID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF film_group .

    CONSTANTS:
      BEGIN OF enddate_not_greater_startdate,
        msgid TYPE symsgid VALUE 'ZISS_CINEMA_MSG',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'StartDate',
        attr2 TYPE scx_attrname VALUE 'EndDate',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enddate_not_greater_startdate .

    CONSTANTS:
      BEGIN OF start_date_less_then_today,
        msgid TYPE symsgid VALUE 'ZISS_CINEMA_MSG',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'StartDate',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF start_date_less_then_today .

    CONSTANTS:
      BEGIN OF less_start_date,
        msgid TYPE symsgid VALUE 'ZISS_CINEMA_MSG',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'FilmDate',
        attr2 TYPE scx_attrname VALUE 'Enddate',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF less_start_date .

    CONSTANTS:
      BEGIN OF greater_end_date,
        msgid TYPE symsgid VALUE 'ZISS_CINEMA_MSG',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'FilmDate',
        attr2 TYPE scx_attrname VALUE 'StartDate',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF greater_end_date .

    CONSTANTS:
      BEGIN OF status_is_not_valid,
        msgid TYPE symsgid VALUE 'ZISS_CINEMA_MSG',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'Status',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_is_not_valid.

    CONSTANTS:                "Authority
      BEGIN OF not_authorized,
        msgid TYPE symsgid VALUE 'ZISS_CINEMA_MSG',
        msgno TYPE symsgno VALUE '020',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_authorized.

    METHODS constructor
      IMPORTING
        severity  TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous TYPE REF TO cx_root OPTIONAL
        groupid   TYPE ziss_group-groupid OPTIONAL
        enddate   TYPE ziss_i_film-EndDate OPTIONAL
        startdate TYPE ziss_i_film-Startdate OPTIONAL
        filmdate  TYPE ziss_i_booking-FilmDate OPTIONAL
        status    TYPE ziss_i_film-Status OPTIONAL.

    DATA groupid         TYPE string READ-ONLY.
    DATA enddate         TYPE ziss_i_film-EndDate READ-ONLY.
    DATA startdate       TYPE ziss_i_film-Startdate READ-ONLY.
    DATA filmdate        TYPE ziss_i_booking-FilmDate READ-ONLY.
    DATA status          TYPE string READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_cinema_iss IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = severity.
    me->groupid         = groupid.
    me->enddate         = enddate.
    me->startdate       = startdate.
    me->filmdate        = filmdate.
    me->status          = status.

  ENDMETHOD.
ENDCLASS.
