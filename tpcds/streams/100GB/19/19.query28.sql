-- start query 28 in stream 19 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 31 and 31+10 
             or ss_coupon_amt between 7767 and 7767+1000
             or ss_wholesale_cost between 44 and 44+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 131 and 131+10
          or ss_coupon_amt between 8646 and 8646+1000
          or ss_wholesale_cost between 31 and 31+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 78 and 78+10
          or ss_coupon_amt between 318 and 318+1000
          or ss_wholesale_cost between 8 and 8+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 9 and 9+10
          or ss_coupon_amt between 6111 and 6111+1000
          or ss_wholesale_cost between 60 and 60+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 0 and 0+10
          or ss_coupon_amt between 1075 and 1075+1000
          or ss_wholesale_cost between 10 and 10+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 12 and 12+10
          or ss_coupon_amt between 14750 and 14750+1000
          or ss_wholesale_cost between 67 and 67+20)) B6
limit 100;

