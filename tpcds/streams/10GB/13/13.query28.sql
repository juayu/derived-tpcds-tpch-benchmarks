-- start query 28 in stream 13 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 63 and 63+10 
             or ss_coupon_amt between 504 and 504+1000
             or ss_wholesale_cost between 23 and 23+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 14 and 14+10
          or ss_coupon_amt between 4443 and 4443+1000
          or ss_wholesale_cost between 29 and 29+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 83 and 83+10
          or ss_coupon_amt between 8072 and 8072+1000
          or ss_wholesale_cost between 6 and 6+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 75 and 75+10
          or ss_coupon_amt between 1930 and 1930+1000
          or ss_wholesale_cost between 19 and 19+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 187 and 187+10
          or ss_coupon_amt between 16724 and 16724+1000
          or ss_wholesale_cost between 78 and 78+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 15 and 15+10
          or ss_coupon_amt between 6182 and 6182+1000
          or ss_wholesale_cost between 22 and 22+20)) B6
limit 100;

