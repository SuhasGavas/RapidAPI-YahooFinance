CLASS zcl_yahoo_finance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS : initial_steup IMPORTING VALUE(iv_url)             TYPE string
                            RETURNING VALUE(ro_web_http_client) TYPE REF TO if_web_http_client.
ENDCLASS.

CLASS zcl_yahoo_finance IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

*--Initial setup
    initial_steup(
      EXPORTING
        iv_url             = 'https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-summary' " API ENDPOINT
      RECEIVING
        ro_web_http_client = DATA(lo_web_http_client)
    ).

*--Returns the underlying HTTP Request
    lo_web_http_client->get_http_request(
      RECEIVING
        r_http_request = DATA(lo_http_request)
    ).

*--Sets all header fields from the given list
    DATA lt_header_fields TYPE if_web_http_request=>name_value_pairs.
    lt_header_fields = VALUE #( ( name = 'X-RapidAPI-Key'  value = '<<Your API Key provided by the RAPIDAPI>>' )
                                ( name = 'X-RapidAPI-Host' value = '<<Hostname provided by RAPIDAPI>>' ) ).

    TRY.
        lo_http_request->set_header_fields(
          EXPORTING
            i_fields = lt_header_fields
        ).
      CATCH cx_web_message_error.
    ENDTRY.

*--Sets all form fields from the given list
    DATA lt_form_fields TYPE if_web_http_request=>name_value_pairs.
    lt_form_fields = VALUE #( ( name = 'symbol' value = 'AMRN' )
                              ( name = 'region' value = 'US' ) ).

    TRY.
        lo_http_request->set_form_fields(
          EXPORTING
            i_fields     = lt_form_fields
*            i_multivalue = 0
*          RECEIVING
*            r_value      =
        ).
      CATCH cx_web_message_error.
    ENDTRY.

*--Sends underlying HTTP Request and returns HTTP Response
    TRY.
        lo_web_http_client->execute(
          EXPORTING
            i_method   = if_web_http_client=>get
*           i_timeout  = 0
          RECEIVING
            r_response = DATA(lo_http_response)
        ).
      CATCH cx_web_http_client_error.
    ENDTRY.

    TRY.
        lo_http_response->get_status(
          RECEIVING
            r_value = DATA(lv_response_value)
        ).
      CATCH cx_web_message_error.
    ENDTRY.

    TRY.
        lo_http_response->get_text(
            RECEIVING
            r_value = DATA(lv_response_text)
        ).
      CATCH cx_web_message_error.
    ENDTRY.
  ENDMETHOD.

  METHOD initial_steup.
*--URL-based HTTP Destination
    TRY.
        cl_http_destination_provider=>create_by_url(
          EXPORTING
            i_url              = iv_url
          RECEIVING
            r_http_destination = DATA(lo_http_destination)
        ).
      CATCH cx_http_dest_provider_error.
    ENDTRY.

*--Creates an HTTP Client for a given HTTP Destination Object
    TRY.
        cl_web_http_client_manager=>create_by_http_destination(
          EXPORTING
            i_destination = lo_http_destination
          RECEIVING
            r_client      = ro_web_http_client
        ).
      CATCH cx_web_http_client_error.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
