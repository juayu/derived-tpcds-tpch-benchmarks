-- start query 28 in stream 18 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 121 and 121+10 
             or ss_coupon_amt between 7833 and 7833+1000
             or ss_wholesale_cost between 37 and 37+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 5 and 5+10
          or ss_coupon_amt between 2762 and 2762+1000
          or ss_wholesale_cost between 56 and 56+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 122 and 122+10
          or ss_coupon_amt between 842 and 842+1000
          or ss_wholesale_cost between 54 and 54+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 14 and 14+10
          or ss_coupon_amt between 4572 and 4572+1000
          or ss_wholesale_cost between 33 and 33+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 185 and 185+10
          or ss_coupon_amt between 5855 and 5855+1000
          or ss_wholesale_cost between 11 and 11+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 166 and 166+10
          or ss_coupon_amt between 8357 and 8357+1000
          or ss_wholesale_cost between 18 and 18+20)) B6
limit 100;

