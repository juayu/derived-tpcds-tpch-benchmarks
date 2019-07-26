-- start query 28 in stream 5 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 12 and 12+10 
             or ss_coupon_amt between 2952 and 2952+1000
             or ss_wholesale_cost between 66 and 66+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 27 and 27+10
          or ss_coupon_amt between 11496 and 11496+1000
          or ss_wholesale_cost between 18 and 18+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 118 and 118+10
          or ss_coupon_amt between 6546 and 6546+1000
          or ss_wholesale_cost between 42 and 42+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 34 and 34+10
          or ss_coupon_amt between 12451 and 12451+1000
          or ss_wholesale_cost between 40 and 40+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 187 and 187+10
          or ss_coupon_amt between 8756 and 8756+1000
          or ss_wholesale_cost between 7 and 7+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 37 and 37+10
          or ss_coupon_amt between 10417 and 10417+1000
          or ss_wholesale_cost between 70 and 70+20)) B6
limit 100;

