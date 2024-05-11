# SAP Call Transaction
SAP call transaction and list parameters captured in ABAP class, useful for implementing hotspot/double click.


```
  data(call_tcode) = zcl_call_tcode=>create( ).

  call_tcode->va43( <lv_vbeln ).

  call_tcode->fb03(
    company_code       = lv_bukrs
    fi_document_number = lv_belnr
    fiscal_year        = lv_gjahr ).

```
