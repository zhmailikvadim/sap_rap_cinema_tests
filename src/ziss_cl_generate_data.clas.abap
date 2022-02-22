CLASS ziss_cl_generate_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZISS_CL_GENERATE_DATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA: lt_film_grs  TYPE TABLE OF ziss_group.

*** FILM GROUPS
*   fill internal table (itab)

    lt_film_grs = VALUE #(
        ( groupid  = '1' groupname = 'Fantasy'       )
        ( groupid  = '2' groupname = 'Action' )
        ( groupid  = '3' groupname = 'Comedy'   )
        ( groupid  = '4' groupname = 'Drama'    )
        ( groupid  = '5' groupname = 'Thriller'      )
     ).

*   Delete the possible entries in the database table - in case it was already filled
    DELETE FROM ziss_group.
*   insert the new table entries
    INSERT ziss_group FROM TABLE @lt_film_grs.

*   check the result
    SELECT * FROM ziss_group INTO TABLE @lt_film_grs.
    out->write( sy-dbcnt ).
    out->write( 'film groups data inserted successfully!').

  ENDMETHOD.
ENDCLASS.
