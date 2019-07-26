-- start query 28 in stream 20 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 84 and 84+10 
             or ss_coupon_amt between 3941 and 3941+1000
             or ss_wholesale_cost between 31 and 31+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 80 and 80+10
          or ss_coupon_amt between 4713 and 4713+1000
          or ss_wholesale_cost between 21 and 21+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 8 and 8+10
          or ss_coupon_amt between 16242 and 16242+1000
          or ss_wholesale_cost between 61 and 61+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 91 and 91+10
          or ss_coupon_amt between 17404 and 17404+1000
          or ss_wholesale_cost between 49 and 49+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 181 and 181+10
          or ss_coupon_amt between 4434 and 4434+1000
          or ss_wholesale_cost between 24 and 24+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 135 and 135+10
          or ss_coupon_amt between 9532 and 9532+1000
          or ss_wholesale_cost between 17 and 17+20)) B6
limit 100;

