-- start query 28 in stream 6 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 149 and 149+10 
             or ss_coupon_amt between 9656 and 9656+1000
             or ss_wholesale_cost between 34 and 34+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 124 and 124+10
          or ss_coupon_amt between 15685 and 15685+1000
          or ss_wholesale_cost between 46 and 46+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 95 and 95+10
          or ss_coupon_amt between 6970 and 6970+1000
          or ss_wholesale_cost between 77 and 77+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 159 and 159+10
          or ss_coupon_amt between 7954 and 7954+1000
          or ss_wholesale_cost between 31 and 31+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 152 and 152+10
          or ss_coupon_amt between 249 and 249+1000
          or ss_wholesale_cost between 23 and 23+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 145 and 145+10
          or ss_coupon_amt between 8995 and 8995+1000
          or ss_wholesale_cost between 14 and 14+20)) B6
limit 100;

