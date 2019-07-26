-- start query 28 in stream 1 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 141 and 141+10 
             or ss_coupon_amt between 12891 and 12891+1000
             or ss_wholesale_cost between 47 and 47+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 170 and 170+10
          or ss_coupon_amt between 16120 and 16120+1000
          or ss_wholesale_cost between 74 and 74+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 16 and 16+10
          or ss_coupon_amt between 2651 and 2651+1000
          or ss_wholesale_cost between 61 and 61+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 184 and 184+10
          or ss_coupon_amt between 12440 and 12440+1000
          or ss_wholesale_cost between 27 and 27+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 179 and 179+10
          or ss_coupon_amt between 3125 and 3125+1000
          or ss_wholesale_cost between 43 and 43+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 1 and 1+10
          or ss_coupon_amt between 3367 and 3367+1000
          or ss_wholesale_cost between 54 and 54+20)) B6
limit 100;

