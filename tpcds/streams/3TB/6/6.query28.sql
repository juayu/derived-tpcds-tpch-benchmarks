-- start query 28 in stream 6 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 151 and 151+10 
             or ss_coupon_amt between 10140 and 10140+1000
             or ss_wholesale_cost between 78 and 78+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 180 and 180+10
          or ss_coupon_amt between 15348 and 15348+1000
          or ss_wholesale_cost between 5 and 5+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 9 and 9+10
          or ss_coupon_amt between 17030 and 17030+1000
          or ss_wholesale_cost between 51 and 51+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 57 and 57+10
          or ss_coupon_amt between 2194 and 2194+1000
          or ss_wholesale_cost between 74 and 74+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 90 and 90+10
          or ss_coupon_amt between 6354 and 6354+1000
          or ss_wholesale_cost between 75 and 75+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 175 and 175+10
          or ss_coupon_amt between 3497 and 3497+1000
          or ss_wholesale_cost between 80 and 80+20)) B6
limit 100;

