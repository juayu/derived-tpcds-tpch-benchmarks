-- start query 28 in stream 9 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 30 and 30+10 
             or ss_coupon_amt between 13858 and 13858+1000
             or ss_wholesale_cost between 24 and 24+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 65 and 65+10
          or ss_coupon_amt between 2034 and 2034+1000
          or ss_wholesale_cost between 46 and 46+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 118 and 118+10
          or ss_coupon_amt between 13281 and 13281+1000
          or ss_wholesale_cost between 58 and 58+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 18 and 18+10
          or ss_coupon_amt between 12905 and 12905+1000
          or ss_wholesale_cost between 40 and 40+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 162 and 162+10
          or ss_coupon_amt between 16215 and 16215+1000
          or ss_wholesale_cost between 21 and 21+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 4 and 4+10
          or ss_coupon_amt between 12688 and 12688+1000
          or ss_wholesale_cost between 11 and 11+20)) B6
limit 100;

