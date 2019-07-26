-- start query 28 in stream 13 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 80 and 80+10 
             or ss_coupon_amt between 3559 and 3559+1000
             or ss_wholesale_cost between 36 and 36+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 159 and 159+10
          or ss_coupon_amt between 6257 and 6257+1000
          or ss_wholesale_cost between 12 and 12+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 13 and 13+10
          or ss_coupon_amt between 5140 and 5140+1000
          or ss_wholesale_cost between 73 and 73+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 95 and 95+10
          or ss_coupon_amt between 14066 and 14066+1000
          or ss_wholesale_cost between 70 and 70+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 133 and 133+10
          or ss_coupon_amt between 17271 and 17271+1000
          or ss_wholesale_cost between 67 and 67+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 12 and 12+10
          or ss_coupon_amt between 14823 and 14823+1000
          or ss_wholesale_cost between 76 and 76+20)) B6
limit 100;

