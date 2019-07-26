-- start query 28 in stream 9 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 79 and 79+10 
             or ss_coupon_amt between 4476 and 4476+1000
             or ss_wholesale_cost between 6 and 6+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 14 and 14+10
          or ss_coupon_amt between 15735 and 15735+1000
          or ss_wholesale_cost between 67 and 67+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 74 and 74+10
          or ss_coupon_amt between 11359 and 11359+1000
          or ss_wholesale_cost between 10 and 10+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 169 and 169+10
          or ss_coupon_amt between 116 and 116+1000
          or ss_wholesale_cost between 31 and 31+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 166 and 166+10
          or ss_coupon_amt between 16552 and 16552+1000
          or ss_wholesale_cost between 41 and 41+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 129 and 129+10
          or ss_coupon_amt between 13845 and 13845+1000
          or ss_wholesale_cost between 40 and 40+20)) B6
limit 100;

