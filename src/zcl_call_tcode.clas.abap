CLASS zcl_call_tcode DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS create
      RETURNING
        VALUE(r_call_tcode) TYPE REF TO zcl_call_tcode.

    METHODS:
      va43 IMPORTING i_vbeln TYPE vbak-vbeln,

      vf03 IMPORTING i_vbeln TYPE vbrk-vbeln,

      va03 IMPORTING i_vbeln TYPE vbrk-vbeln,

      xd03 IMPORTING i_kunnr TYPE kunnr
                     i_bukrs TYPE bukrs OPTIONAL
                     i_vkorg TYPE vkorg OPTIONAL,

      fk03 IMPORTING i_lifnr TYPE lifnr
                     i_bukrs TYPE bukrs OPTIONAL,

      fb03 IMPORTING i_bukrs TYPE bukrs
                     i_belnr TYPE belnr_d
                     i_gjahr TYPE gjahr,

      j1b3n IMPORTING i_nfdocnum TYPE j_1bdocnum,

      acc_doc_popup IMPORTING i_awtyp TYPE acchd-awtyp
                              i_awref TYPE acchd-awref
                              i_aworg TYPE acchd-aworg
                              i_bukrs TYPE accit-bukrs,

      ke23n IMPORTING docnr_fi TYPE acc_docnr
                      bukrs    TYPE bukrs
                      awtyp    TYPE acchd-awtyp
                      awref    TYPE acchd-awref
                      aworg    TYPE acchd-aworg.

    PROTECTED SECTION.
    PRIVATE SECTION.

      METHODS:
        call_transaction IMPORTING tcode TYPE sy-tcode.

ENDCLASS.

CLASS ZCL_CALL_TCODE IMPLEMENTATION.

  METHOD acc_doc_popup.
    DATA lt_documents TYPE STANDARD TABLE OF acc_doc.

    CALL FUNCTION 'COPA_DOCUMENT_RECORD'
      EXPORTING
        i_awtyp        = i_awtyp           " Reference Category of Callup Application
        i_awref        = i_awref           " Reference Key of Callup Application
        i_aworg        = i_aworg           " Reference Organization of Callup Application
        i_bukrs        = i_bukrs           " Limit to Documents of Company Code
      TABLES
        t_documents    = lt_documents              " Table of Selected Documents
      EXCEPTIONS
        no_entry_tka00 = 1
        no_entry_tka01 = 2
        error_erkrs    = 3
        OTHERS         = 4.
    IF sy-subrc = 0.
      CALL FUNCTION 'AC_DOCUMENT_RECORD'
        EXPORTING
          i_awtyp      = i_awtyp
          i_awref      = i_awref
          i_aworg      = i_aworg
          i_bukrs      = i_bukrs
*        TABLES
*         t_documents  = lt_documents              " Table of Selected Documents
        EXCEPTIONS
          no_reference = 1
          no_document  = 2
          OTHERS       = 3.
      IF sy-subrc <> 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD call_transaction.
    TRY.
        CALL TRANSACTION tcode WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      CATCH cx_sy_authorization_error.
        MESSAGE s172(00) WITH tcode.
    ENDTRY.

  ENDMETHOD.

  METHOD create.
    r_call_tcode = NEW zcl_call_tcode( ).
  ENDMETHOD.

  METHOD fb03.

    IF i_belnr IS NOT INITIAL AND i_bukrs IS NOT INITIAL.
      SET PARAMETER ID 'BLN' FIELD i_belnr.
      SET PARAMETER ID 'BUK' FIELD i_bukrs.
      SET PARAMETER ID 'GJR' FIELD i_gjahr.

      call_transaction( 'FB03' ).
    ENDIF.
  ENDMETHOD.

  METHOD fk03.

    IF i_lifnr IS NOT INITIAL.
      SET PARAMETER: ID 'LIF' FIELD i_lifnr,
                     ID 'BUK' FIELD i_bukrs.

      call_transaction( 'FK03' ).
    ENDIF.
  ENDMETHOD.

  METHOD j1b3n.

    IF i_nfdocnum NE 0.
      SET PARAMETER ID 'JEF' FIELD i_nfdocnum.
      call_transaction( 'J1B3N' ).
    ENDIF.

  ENDMETHOD.

  METHOD ke23n.

    DATA t_documents TYPE STANDARD TABLE OF acc_doc.

    t_documents =
      VALUE #( (
        docnr =  docnr_fi
        awtyp = 'COPA'
        display = 'X'
        bukrs = bukrs ) ).

    CALL FUNCTION 'COPA_DOCUMENT_RECORD'
      EXPORTING
        i_awtyp        = awtyp  " Reference Category of Callup Application
        i_awref        = awref  " Reference Key of Callup Application
        i_aworg        = aworg  " Reference Organization of Callup Application
        i_bukrs        = bukrs  " Limit to Documents of Company Code
      TABLES
        t_documents    = t_documents  " Table of Selected Documents
      EXCEPTIONS
        no_entry_tka00 = 1
        no_entry_tka01 = 2
        error_erkrs    = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.

  METHOD va03.

    IF i_vbeln IS NOT INITIAL.
      SET PARAMETER ID 'AUN' FIELD i_vbeln.
      call_transaction( 'VA03' ).
    ENDIF.
  ENDMETHOD.

  METHOD va43.

    IF i_vbeln IS NOT INITIAL.
      SET PARAMETER ID 'KTN' FIELD i_vbeln.
      call_transaction( 'VA43' ).
    ENDIF.
  ENDMETHOD.

  METHOD vf03.

    IF i_vbeln IS NOT INITIAL.
      SET PARAMETER ID 'VF' FIELD i_vbeln.
      call_transaction( 'VF03' ).
    ENDIF.
  ENDMETHOD.

  METHOD xd03.

    IF i_kunnr IS NOT INITIAL.
      SET PARAMETER: ID 'KUN' FIELD i_kunnr,
                     ID 'BUK' FIELD i_bukrs,
                     ID 'VKO' FIELD i_vkorg.
      call_transaction( 'XD03' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
