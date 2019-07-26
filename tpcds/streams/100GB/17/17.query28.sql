-- start query 28 in stream 17 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 141 and 141+10 
             or ss_coupon_amt between 11832 and 11832+1000
             or ss_wholesale_cost between 62 and 62+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 25 and 25+10
          or ss_coupon_amt between 2802 and 2802+1000
          or ss_wholesale_cost between 68 and 68+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 133 and 133+10
          or ss_coupon_amt between 6696 and 6696+1000
          or ss_wholesale_cost between 0 and 0+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 67 and 67+10
          or ss_coupon_amt between 7620 and 7620+1000
          or ss_wholesale_cost between 76 and 76+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 10 and 10+10
          or ss_coupon_amt between 10729 and 10729+1000
          or ss_wholesale_cost between 56 and 56+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 190 and 190+10
          or ss_coupon_amt between 7970 and 7970+1000
          or ss_wholesale_cost between 58 and 58+20)) B6
limit 100;

