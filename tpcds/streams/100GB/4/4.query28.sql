-- start query 28 in stream 4 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 0 and 0+10 
             or ss_coupon_amt between 5709 and 5709+1000
             or ss_wholesale_cost between 18 and 18+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 71 and 71+10
          or ss_coupon_amt between 5575 and 5575+1000
          or ss_wholesale_cost between 63 and 63+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 116 and 116+10
          or ss_coupon_amt between 13472 and 13472+1000
          or ss_wholesale_cost between 17 and 17+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 151 and 151+10
          or ss_coupon_amt between 3314 and 3314+1000
          or ss_wholesale_cost between 4 and 4+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 50 and 50+10
          or ss_coupon_amt between 17060 and 17060+1000
          or ss_wholesale_cost between 3 and 3+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 20 and 20+10
          or ss_coupon_amt between 16053 and 16053+1000
          or ss_wholesale_cost between 45 and 45+20)) B6
limit 100;

