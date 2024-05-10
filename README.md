# SAP Call Transaction
SAP call transaction and list parameters captured in ABAP class, useful for implementing hotspot/double click.


```
  data(call_tcode) = zcl_call_tcode=>create( ).

  call_tcode->va43( <lv_vbeln ).

  call_tcode->fb03(
    i_bukrs = LV_bukrs
    i_belnr = lv_belnr
    i_gjahr = lv_gjahr ).
```
