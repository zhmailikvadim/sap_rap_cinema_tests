**"* use this source file for your ABAP unit test classes
*"* use this source file for your ABAP unit test classes
"! @testing BDEF:ZISS_I_FILM
CLASS ltcl_film DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA:
      class_under_test     TYPE REF TO lhc_film,               " the class to be tested
      cds_test_environment TYPE REF TO if_cds_test_environment,  " cds test double framework
      sql_test_environment TYPE REF TO if_osql_test_environment. " abap sql test double framework
    CLASS-METHODS:
      " setup test double framework
      class_setup,
      " stop test doubles
      class_teardown.

    METHODS:
      " reset test doubles
      setup RAISING cx_abap_auth_check_exception,
      " rollback any changes
      teardown,

      " CUT: validation method validate_status
      validate_status FOR TESTING,

      set_status_to_accepted FOR TESTING RAISING cx_static_check,

      set_status_to_plan FOR TESTING RAISING cx_static_check,

      set_up_authorization_double RAISING cx_abap_auth_check_exception.

ENDCLASS.


CLASS ltcl_film IMPLEMENTATION.

  METHOD class_setup.
    CREATE OBJECT class_under_test FOR TESTING.
    cds_test_environment = cl_cds_test_environment=>create( i_for_entity = 'ZISS_I_FILM' ).
    cds_test_environment->enable_double_redirection( ).
    sql_test_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'ZISS_GROUP' ) ) ).

    DATA(access_control) = cds_test_environment->get_access_control_double(  ).
    DATA(auth_objset_may_create) = cl_aunit_authority_check=>create_auth_object_set( ).
    DATA(cds_access_control_may_display) = cl_cds_test_data=>create_access_control_data( i_role_authorizations  =
                                                      VALUE #( ( object = 'Z_AUTH_TST'
                                                               authorizations =
                                                                VALUE #(
                                                                ( VALUE
                                                                 #( ( fieldname = 'ACTVT'
                                                                fieldvalues =
                                                               VALUE #( ( lower_value = '03' ) ) ) ) ) ) ) ) ).

    access_control->enable_access_control( cds_access_control_may_display ).
  ENDMETHOD.

  METHOD class_teardown.
    cds_test_environment->destroy( ).
    sql_test_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    " clear the content of the test double per test
    set_up_authorization_double(  ).
    cds_test_environment->clear_doubles( ).
    sql_test_environment->clear_doubles( ).
  ENDMETHOD.

  METHOD teardown.
    DATA(auth_controller) = cl_aunit_authority_check=>get_controller( ).
    "auth_controller->assert_expectations(  ).
    auth_controller->get_auth_check_execution_log( )->get_execution_status(
    IMPORTING
      passed_execution = DATA(passed_execution)
      failed_execution = DATA(failed_execution)
  ).
    auth_controller->reset(  ).
    " Clean up any involved entity
    ROLLBACK ENTITIES.
  ENDMETHOD.

  METHOD validate_status.
    " fill in test data
    DATA film_mock_data TYPE STANDARD TABLE OF ziss_film.
    film_mock_data = VALUE #( ( filmuuid = 0000000000000002 status = 'A' )
                                          ( filmuuid = 0000000000000003 status = 'B' ) " invalid status
                                          ( filmuuid = 0000000000000004 status = 'P' ) ).
    " insert test data into the cds test doubles
    cds_test_environment->insert_test_data( i_data = film_mock_data ).
    " call the method to be tested
    TYPES: BEGIN OF ty_entity_key,
             FilmUUID TYPE sysuuid_x16,
           END OF ty_entity_key.


    DATA: failed      TYPE RESPONSE FOR FAILED LATE ziss_i_film,
          reported    TYPE RESPONSE FOR REPORTED LATE ziss_i_film,
          entity_keys TYPE STANDARD TABLE OF ty_entity_key.


    " specify test entity keys
    entity_keys = VALUE #( ( filmuuid = '00000000000000000000000000000002' ) ( filmuuid = '00000000000000000000000000000003' ) ( filmuuid = '00000000000000000000000000000004'  ) ).


    " execute the validation
    class_under_test->validateStatus(
      EXPORTING
        keys     = CORRESPONDING #( entity_keys )
      CHANGING
        failed   = failed
        reported = reported
    ).


    " check that failed has the relevant travel_id
    cl_abap_unit_assert=>assert_not_initial( msg = 'failed' act = failed ).
    cl_abap_unit_assert=>assert_equals( msg = 'failed-film-uuid' act = failed-film[ 1 ]-FilmUUID exp = '00000000000000000000000000000003' ).


    " check that reported also has the correct travel_id, the %element flagged and a message posted
    cl_abap_unit_assert=>assert_not_initial( msg = 'reported' act = reported ).
    DATA(ls_reported_film) = reported-film[ 1 ].
    cl_abap_unit_assert=>assert_equals( msg = 'reported-film-id' act = ls_reported_film-FilmUUID exp = '00000000000000000000000000000003' ).
    cl_abap_unit_assert=>assert_equals( msg = 'reported-%element' act = ls_reported_film-%element-Status exp = if_abap_behv=>mk-on ).
    cl_abap_unit_assert=>assert_bound( msg = 'reported-%msg' act = ls_reported_film-%msg ).

  ENDMETHOD.

  METHOD set_status_to_accepted.
    " fill in test data
    DATA film_mock_data TYPE STANDARD TABLE OF ziss_film.
    film_mock_data = VALUE #( ( filmuuid = '00000000000000000000000000000002' status = 'A' )
    ( filmuuid = '00000000000000000000000000000003' status = 'P' )
    ( filmuuid = '00000000000000000000000000000004' status = 'X' ) ).
    " insert test data into the cds test doubles
    cds_test_environment->insert_test_data( i_data = film_mock_data ).


    " call the method to be tested
    TYPES: BEGIN OF  ty_entity_key,
             FilmUUID TYPE sysuuid_x16,
           END OF ty_entity_key.


    DATA: result      TYPE TABLE    FOR ACTION RESULT ziss_i_film\\Film~acceptFilm,
          mapped      TYPE RESPONSE FOR MAPPED EARLY ziss_i_film,
          failed      TYPE RESPONSE FOR FAILED EARLY ziss_i_film,
          reported    TYPE RESPONSE FOR REPORTED EARLY ziss_i_film,
          entity_keys TYPE STANDARD TABLE OF ty_entity_key.


    " specify entity keys
    entity_keys = VALUE #( ( filmuuid = '00000000000000000000000000000002' ) ( filmuuid = '00000000000000000000000000000003' ) ( filmuuid = '00000000000000000000000000000004'  ) ).


    " execute the action
    class_under_test->acceptfilm(
      EXPORTING
        keys     = CORRESPONDING #( entity_keys )
      CHANGING
        result   = result
        mapped   = mapped
        failed   = failed
        reported = reported
    ).


    cl_abap_unit_assert=>assert_initial( msg = 'mapped' act = mapped ).
    cl_abap_unit_assert=>assert_initial( msg = 'failed' act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).


    " expect input keys and output keys to be same and Status everywhere = 'A' (Accepted)
    DATA exp LIKE result.
    exp = VALUE #(  ( FilmUUID = '00000000000000000000000000000002'  %param-FilmUUID = '00000000000000000000000000000002'  %param-Status = 'A' )
    ( FilmUUID = '00000000000000000000000000000003'  %param-FilmUUID = '00000000000000000000000000000003'  %param-Status = 'A' )
    ( FilmUUID = '00000000000000000000000000000004'  %param-FilmUUID = '00000000000000000000000000000004'  %param-Status = 'A' ) ).


    " current result; copy only fields of interest - i.e. FilmUUID, %param-filmuuid and %param-Status.
    DATA act LIKE result.
    act = CORRESPONDING #( result MAPPING FilmUUID = FilmUUID
    (  %param = %param MAPPING FilmUUID      = FilmUUID
    Status = Status
    EXCEPT * )
    EXCEPT * ).
    " sort data by film uuid
    SORT act ASCENDING BY FilmUUID.
    cl_abap_unit_assert=>assert_equals( msg = 'action result' exp = exp act = act ).


    " additionally check by reading entity state
    READ ENTITY ziss_i_film
    FIELDS ( FilmUUID Status ) WITH CORRESPONDING #( entity_keys )
    RESULT DATA(read_result).
    act = VALUE #( FOR t IN read_result ( FilmUUID             = t-FilmUUID
    %param-FilmUUID      = t-FilmUUID
    %param-Status = t-Status ) ).
    " sort read data
    SORT act ASCENDING BY FilmUUID.
    cl_abap_unit_assert=>assert_equals( msg = 'read result' exp = exp act = act ).
  ENDMETHOD.

  METHOD set_status_to_plan.
    AUTHORITY-CHECK OBJECT 'Z_AUTH_TST' ID 'ACTVT' FIELD '01'.
    " fill in test data
    DATA film_mock_data TYPE STANDARD TABLE OF ziss_film.
    film_mock_data = VALUE #( ( filmuuid = '00000000000000000000000000000002' status = 'A' )
                                ( filmuuid = '00000000000000000000000000000003' status = '' )  " empty status
                                ( filmuuid = '00000000000000000000000000000004' status = 'X' ) ).
    " insert test data into the cds test doubles
    cds_test_environment->insert_test_data( i_data = film_mock_data ).
    " call the method to be tested
    TYPES: BEGIN OF  ty_entity_key,
             FilmUUID TYPE sysuuid_x16,
           END OF ty_entity_key.

    DATA: reported    TYPE RESPONSE FOR REPORTED LATE ziss_i_film,
          entity_keys TYPE STANDARD TABLE OF ty_entity_key.

    " specify entity keys
    entity_keys = VALUE #( ( filmuuid = '00000000000000000000000000000002' ) ( filmuuid = '00000000000000000000000000000003' ) ( filmuuid = '00000000000000000000000000000004'  ) ).

    " execute the determination
    class_under_test->set_first_status(
      EXPORTING
        keys     = CORRESPONDING #( entity_keys )
      CHANGING
        reported = reported
    ).

    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    "check by reading entity state
    READ ENTITY ziss_i_film
      FIELDS ( FilmUUID Status ) WITH CORRESPONDING #( entity_keys )
      RESULT DATA(lt_read_result).

    " current result; copy only fields of interest - i.e. TravelID, OverallStatus.
    DATA act LIKE lt_read_result.
    act = CORRESPONDING #( lt_read_result MAPPING FilmUUID      = FilmUUID
                                                  Status = Status
                                                  EXCEPT * ).
    " sort result by travel id
    SORT act ASCENDING BY FilmUUID.

    "expected result
    DATA exp LIKE lt_read_result.
    exp = VALUE #( ( FilmUUID = '00000000000000000000000000000002' Status = 'A' )
                   ( FilmUUID = '00000000000000000000000000000003' Status = 'P' )
                   ( FilmUUID = '00000000000000000000000000000004' Status = 'X' ) ).

    " assert result
    cl_abap_unit_assert=>assert_equals( msg = 'read result' exp = exp act = act ).
  ENDMETHOD.

  METHOD set_up_authorization_double.
    DATA(auth_objset_may_create) = cl_aunit_authority_check=>create_auth_object_set( ).

    auth_objset_may_create->add_authobj_with_fldvals( object = 'S_DEVELOP'
                                                      fields =
                                                               VALUE #(
                                                               ( VALUE
                                                                #( ( fieldname = 'ACTVT'
                                                               fieldvalues =
                                                              VALUE #( ( lower_value = '03' ) ) ) ) ) ) ).

    DATA(auth_controller) = cl_aunit_authority_check=>get_controller( ).

    auth_controller->restrict_authorizations_to( auth_objset_may_create ).

    auth_controller->authorizations_expected_to(
      EXPORTING
        pass_execution = auth_objset_may_create
    ).
  ENDMETHOD.
ENDCLASS.
