CLASS zcl_call_tcode DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en">Create instance</p>
    CLASS-METHODS create
      RETURNING
        VALUE(r_call_tcode) TYPE REF TO zcl_call_tcode.
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Display Sales Contract</p>
      va43
        IMPORTING
          sales_contract TYPE vbak-vbeln,
      "! <p class="shorttext synchronized" lang="en">Sales Billing Document</p>
      vf03
        IMPORTING
          billing_document TYPE vbrk-vbeln,
      "! <p class="shorttext synchronized" lang="en">Display Sales Order</p>
      va03
        IMPORTING
          sales_contract TYPE vbrk-vbeln,
      "! <p class="shorttext synchronized" lang="en">Display Customer</p>
      xd03
        IMPORTING
          customer_number TYPE kunnr
          company_code    TYPE bukrs OPTIONAL
          sales_org       TYPE vkorg OPTIONAL,
      "! <p class="shorttext synchronized" lang="en">Display Vendor</p>
      fk03
        IMPORTING
          vendor_number TYPE lifnr
          company_code  TYPE bukrs OPTIONAL,
      "! <p class="shorttext synchronized" lang="en">Display Account Document</p>
      fb03
        IMPORTING
          company_code       TYPE bukrs
          fi_document_number TYPE belnr_d
          fiscal_year        TYPE gjahr,
      "! <p class="shorttext synchronized" lang="en">Display Nota Fiscal</p>
      j1b3n
        IMPORTING
          nota_fiscal_docno TYPE j_1bdocnum,
      "! <p class="shorttext synchronized" lang="en">List of Documents in Accounting pop up</p>
      acc_doc_popup
        IMPORTING
          reference_procedure TYPE acchd-awtyp
          ref_doc_number      TYPE acchd-awref
          ref_organisation    TYPE acchd-aworg
          company_code        TYPE accit-bukrs,
      "! <p class="shorttext synchronized" lang="en">CO-PA Line Item Display</p>
      ke23n
        IMPORTING
          fi_document_number  TYPE acc_docnr
          company_code        TYPE bukrs
          reference_procedure TYPE acchd-awtyp
          ref_doc_number      TYPE acchd-awref
          ref_organisation    TYPE acchd-aworg,
      "! <p class="shorttext synchronized" lang="en">Display Outbound Delivery</p>
      vl03n
        IMPORTING
          outbound_delivery TYPE likp-vbeln,
      "! <p class="shorttext synchronized" lang="en">Display Inbound Delivery</p>
      vl33n
        IMPORTING
          inbound_delivery TYPE likp-vbeln,
      "! <p class="shorttext synchronized" lang="en">Transfer Order</p>
      lt21
        IMPORTING
          transfer_order      TYPE ltak-tanum
          warehouse           TYPE ltak-lgnum
          transfer_order_line TYPE rl03t-tapos,
      "! <p class="shorttext synchronized" lang="en">MM Invoice</p>
      mir4
        IMPORTING
          invoice_no  TYPE rbkp-belnr
          fiscal_year TYPE rbkp-gjahr,
      "! <p class="shorttext synchronized" lang="en">Display Purchase Order</p>
      me23n
        IMPORTING
          purchase_order TYPE ekko-ebeln,
      "! <p class="shorttext synchronized" lang="en">Material, Tabs Basic Data 1</p>
      mm03_basicdata1
        IMPORTING
          material_code TYPE mara-matnr,
      "! <p class="shorttext synchronized" lang="en">Material, Tabs Classification</p>
      mm03_classification
        IMPORTING
          material_code TYPE mara-matnr,
      "! <p class="shorttext synchronized" lang="en">Material, Tabs salesorgdata1</p>
      mm03_salesorgdata1
        IMPORTING
          material_code TYPE mara-matnr
          sales_org     TYPE mvke-vkorg
          dist_chanl    TYPE mvke-vtweg,
      "! <p class="shorttext synchronized" lang="en">Material, Tabs purchasing</p>
      mm03_purchasing
        IMPORTING
          material_code TYPE mara-matnr
          plant         TYPE marc-werks,
      "! <p class="shorttext synchronized" lang="en">Material, Tabs MRP 1</p>
      mm03_mrp1
        IMPORTING
          material_code TYPE mara-matnr
          storg_loc     TYPE mard-lgort,
      "! <p class="shorttext synchronized" lang="en">Material, Tabs general plant data storage 1 </p>
      mm03_gen_plant_data_storage1
        IMPORTING
          material_code TYPE mara-matnr
          plant         TYPE marc-werks
          storg_loc     TYPE mard-lgort,
      "! <p class="shorttext synchronized" lang="en">Material, Tabs warehouse management1</p>
      mm03_warehouse_management1
        IMPORTING
          material_code TYPE mara-matnr
          plant         TYPE marc-werks
          warehouse     TYPE mlgn-lgnum,
      "! <p class="shorttext synchronized" lang="en">Material, Tabs accounting1</p>
      mm03_accounting1
        IMPORTING
          material_code TYPE mara-matnr
          plant         TYPE marc-werks,
      "! <p class="shorttext synchronized" lang="en">Material, Tabs costing1</p>
      mm03_costing1
        IMPORTING
          material_code TYPE mara-matnr
          plant         TYPE marc-werks,
      "! <p class="shorttext synchronized" lang="en">IDOC Display</p>
      idoc_disp
        IMPORTING
          idocnum TYPE edi_docnum,
      "! <p class="shorttext synchronized" lang="en">Display HR Master Data</p>
      pa20
        IMPORTING
          HR_Master_key type pskey.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS:
      "! <p class="shorttext synchronized" lang="en">Call Transaction</p>
      call_transaction
        IMPORTING
          tcode TYPE sy-tcode .
ENDCLASS.



CLASS zcl_call_tcode IMPLEMENTATION.

  METHOD acc_doc_popup.
    DATA lt_documents TYPE STANDARD TABLE OF acc_doc.

    CALL FUNCTION 'COPA_DOCUMENT_RECORD'
      EXPORTING
        i_awtyp        = reference_procedure           " Reference Category of Callup Application
        i_awref        = ref_doc_number           " Reference Key of Callup Application
        i_aworg        = ref_organisation           " Reference Organization of Callup Application
        i_bukrs        = company_code           " Limit to Documents of Company Code
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
          i_awtyp      = reference_procedure
          i_awref      = ref_doc_number
          i_aworg      = ref_organisation
          i_bukrs      = company_code
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
    IF fi_document_number IS NOT INITIAL AND company_code IS NOT INITIAL.
      SET PARAMETER ID 'BLN' FIELD fi_document_number.
      SET PARAMETER ID 'BUK' FIELD company_code.
      SET PARAMETER ID 'GJR' FIELD fiscal_year.
      call_transaction( 'FB03' ).
    ENDIF.
  ENDMETHOD.

  METHOD fk03.
    IF vendor_number IS NOT INITIAL.
      SET PARAMETER: ID 'LIF' FIELD vendor_number,
                     ID 'BUK' FIELD company_code.
      call_transaction( 'FK03' ).
    ENDIF.
  ENDMETHOD.

  METHOD j1b3n.
    IF nota_fiscal_docno NE 0.
      SET PARAMETER ID 'JEF' FIELD nota_fiscal_docno.
      call_transaction( 'J1B3N' ).
    ENDIF.
  ENDMETHOD.

  METHOD ke23n.
    DATA t_documents TYPE STANDARD TABLE OF acc_doc.

    t_documents =
      VALUE #( (
        docnr =  fi_document_number
        awtyp = 'COPA'
        display = 'X'
        bukrs = company_code ) ).

    CALL FUNCTION 'COPA_DOCUMENT_RECORD'
      EXPORTING
        i_awtyp        = reference_procedure  " Reference Category of Callup Application
        i_awref        = ref_doc_number  " Reference Key of Callup Application
        i_aworg        = ref_organisation  " Reference Organization of Callup Application
        i_bukrs        = company_code  " Limit to Documents of Company Code
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
    IF sales_contract IS NOT INITIAL.
      SET PARAMETER ID 'AUN' FIELD sales_contract.
      call_transaction( 'VA03' ).
    ENDIF.
  ENDMETHOD.

  METHOD va43.
    IF sales_contract  IS NOT INITIAL.
      SET PARAMETER ID 'KTN' FIELD sales_contract .
      call_transaction( 'VA43' ).
    ENDIF.
  ENDMETHOD.

  METHOD vf03.
    IF billing_document IS NOT INITIAL.
      SET PARAMETER ID 'VF' FIELD billing_document.
      call_transaction( 'VF03' ).
    ENDIF.
  ENDMETHOD.

  METHOD xd03.
    IF customer_number IS NOT INITIAL.
      SET PARAMETER: ID 'KUN' FIELD customer_number,
                     ID 'BUK' FIELD company_code,
                     ID 'VKO' FIELD sales_org.
      call_transaction( 'XD03' ).
    ENDIF.
  ENDMETHOD.

  METHOD vl03n.
    IF outbound_delivery IS NOT INITIAL.
      SET PARAMETER ID 'VL' FIELD outbound_delivery.
      call_transaction( 'VL03N' ).
    ENDIF.
  ENDMETHOD.

  METHOD vl33n.
    IF inbound_delivery IS NOT INITIAL.
      SET PARAMETER ID 'VLM' FIELD inbound_delivery.
      call_transaction( 'VL33N' ).
    ENDIF.
  ENDMETHOD.

  METHOD lt21.
    IF transfer_order IS NOT INITIAL.
      SET PARAMETER ID 'TAN' FIELD transfer_order.
      SET PARAMETER ID 'LGN' FIELD warehouse.
      SET PARAMETER ID 'TAP' FIELD transfer_order_line.
      call_transaction( 'LT21' ).
    ENDIF.
  ENDMETHOD.

  METHOD mir4.
    IF invoice_no IS NOT INITIAL.
      SET PARAMETER ID 'RBN' FIELD invoice_no.
      SET PARAMETER ID 'GJR' FIELD fiscal_year.
      call_transaction( 'MIR4' ).
    ENDIF.
  ENDMETHOD.

  METHOD me23n.
    "Purchase Order
    IF purchase_order IS NOT INITIAL.
      SET PARAMETER ID 'BES' FIELD purchase_order.
      call_transaction( 'ME23N'  ).
    ENDIF.
  ENDMETHOD.

  METHOD mm03_basicdata1.
    "Material BasicData1
    IF material_code IS NOT INITIAL.
      SET PARAMETER ID 'MAT' FIELD material_code.
      SET PARAMETER ID 'MXX' FIELD 'K' .
      call_transaction( 'MM03' ).
    ENDIF.
  ENDMETHOD.

  METHOD mm03_classification.
    "Material Classification
    IF material_code IS NOT INITIAL.
      SET PARAMETER ID 'MAT' FIELD material_code .
      SET PARAMETER ID 'MXX' FIELD 'C' .
      call_transaction( 'MM03' ).
    ENDIF.
  ENDMETHOD.

  METHOD mm03_salesorgdata1.
    IF material_code IS NOT INITIAL.
      SET PARAMETER ID 'MAT' FIELD material_code .
      SET PARAMETER ID 'VKO' FIELD sales_org .
      SET PARAMETER ID 'VTW' FIELD dist_chanl .
      SET PARAMETER ID 'MXX' FIELD 'V' .
      call_transaction( 'MM03' ).
    ENDIF.
  ENDMETHOD.

  METHOD mm03_purchasing.
    IF material_code IS NOT INITIAL.
      SET PARAMETER ID 'MAT' FIELD material_code .
      SET PARAMETER ID 'WRK' FIELD plant .
      SET PARAMETER ID 'MXX' FIELD 'E' .
      call_transaction( 'MM03' ).
    ENDIF.
  ENDMETHOD.

  METHOD mm03_mrp1.
    IF material_code IS NOT INITIAL.
      SET PARAMETER ID 'MAT' FIELD material_code .
      SET PARAMETER ID 'LAG' FIELD storg_loc .
      SET PARAMETER ID 'MXX' FIELD 'D' .
      call_transaction( 'MM03' ).
    ENDIF.
  ENDMETHOD.

  METHOD mm03_gen_plant_data_storage1.
    IF material_code IS NOT INITIAL.
      SET PARAMETER ID 'MAT' FIELD material_code .
      SET PARAMETER ID 'WRK' FIELD plant .
      SET PARAMETER ID 'LAG' FIELD storg_loc .
      SET PARAMETER ID 'MXX' FIELD 'L' .
      call_transaction( 'MM03' ).
    ENDIF.
  ENDMETHOD.

  METHOD mm03_warehouse_management1.
    IF material_code IS NOT INITIAL.
      SET PARAMETER ID 'MAT' FIELD material_code .
      SET PARAMETER ID 'WRK' FIELD plant .
      SET PARAMETER ID 'LGN' FIELD warehouse .
      SET PARAMETER ID 'MXX' FIELD 'S' .
      call_transaction( 'MM03' ).
    ENDIF.
  ENDMETHOD.

  METHOD mm03_accounting1.
    IF material_code IS NOT INITIAL.
      SET PARAMETER ID 'MAT' FIELD material_code .
      SET PARAMETER ID 'WRK' FIELD plant .
      SET PARAMETER ID 'MXX' FIELD 'B' .
      call_transaction( 'MM03' ).
    ENDIF.
  ENDMETHOD.

  METHOD mm03_costing1.
    IF material_code IS NOT INITIAL.
      SET PARAMETER ID 'MAT' FIELD material_code .
      SET PARAMETER ID 'WRK' FIELD plant.
      SET PARAMETER ID 'MXX' FIELD 'G' .
      call_transaction( 'MM03' ).
    ENDIF.
  ENDMETHOD.

  METHOD idoc_disp.
    CHECK idocnum IS NOT INITIAL.
    SUBMIT idoc_tree_control WITH docnum = idocnum
              AND RETURN.
  ENDMETHOD.

  METHOD pa20.
    IF HR_Master_key-pernr IS NOT INITIAL.
      SET PARAMETER ID 'PER' FIELD HR_Master_key-pernr.
      SET PARAMETER ID 'BEG' FIELD HR_Master_key-begda.
      SET PARAMETER ID 'END' FIELD HR_Master_key-endda.
      SET PARAMETER ID 'INF' FIELD HR_Master_key-infty.
      SET PARAMETER ID 'ITP' FIELD HR_Master_key-infty.
      SET PARAMETER ID 'SUB' FIELD HR_Master_key-subty.
      SET PARAMETER ID 'FCD' FIELD 'DIS '.
      SET PARAMETER ID 'OPS' FIELD HR_Master_key-objps.
      SET PARAMETER ID 'SPP' FIELD HR_Master_key-sprps.
      SET PARAMETER ID 'PSQ' FIELD HR_Master_key-seqnr.
      "SET PARAMETER ID 'PAK' FIELD askey.

      call_transaction( 'PA20' ).
    ENDIF.

  ENDMETHOD..
ENDCLASS.
