-- start query 28 in stream 8 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 67 and 67+10 
             or ss_coupon_amt between 14804 and 14804+1000
             or ss_wholesale_cost between 45 and 45+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 145 and 145+10
          or ss_coupon_amt between 1205 and 1205+1000
          or ss_wholesale_cost between 80 and 80+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 37 and 37+10
          or ss_coupon_amt between 3620 and 3620+1000
          or ss_wholesale_cost between 0 and 0+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 122 and 122+10
          or ss_coupon_amt between 2739 and 2739+1000
          or ss_wholesale_cost between 30 and 30+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 49 and 49+10
          or ss_coupon_amt between 5888 and 5888+1000
          or ss_wholesale_cost between 63 and 63+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 15 and 15+10
          or ss_coupon_amt between 10786 and 10786+1000
          or ss_wholesale_cost between 42 and 42+20)) B6
limit 100;

