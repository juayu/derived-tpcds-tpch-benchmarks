-- start query 28 in stream 20 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 119 and 119+10 
             or ss_coupon_amt between 15887 and 15887+1000
             or ss_wholesale_cost between 49 and 49+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 110 and 110+10
          or ss_coupon_amt between 17933 and 17933+1000
          or ss_wholesale_cost between 46 and 46+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 60 and 60+10
          or ss_coupon_amt between 9335 and 9335+1000
          or ss_wholesale_cost between 45 and 45+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 45 and 45+10
          or ss_coupon_amt between 16364 and 16364+1000
          or ss_wholesale_cost between 64 and 64+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 46 and 46+10
          or ss_coupon_amt between 11992 and 11992+1000
          or ss_wholesale_cost between 15 and 15+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 142 and 142+10
          or ss_coupon_amt between 11607 and 11607+1000
          or ss_wholesale_cost between 54 and 54+20)) B6
limit 100;

