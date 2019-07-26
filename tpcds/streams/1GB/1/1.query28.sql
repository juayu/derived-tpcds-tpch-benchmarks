-- start query 28 in stream 1 using template query28.tpl
select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 160 and 160+10 
             or ss_coupon_amt between 11563 and 11563+1000
             or ss_wholesale_cost between 62 and 62+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 87 and 87+10
          or ss_coupon_amt between 8373 and 8373+1000
          or ss_wholesale_cost between 1 and 1+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 189 and 189+10
          or ss_coupon_amt between 14560 and 14560+1000
          or ss_wholesale_cost between 15 and 15+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 187 and 187+10
          or ss_coupon_amt between 8344 and 8344+1000
          or ss_wholesale_cost between 51 and 51+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 24 and 24+10
          or ss_coupon_amt between 14336 and 14336+1000
          or ss_wholesale_cost between 2 and 2+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 186 and 186+10
          or ss_coupon_amt between 15001 and 15001+1000
          or ss_wholesale_cost between 22 and 22+20)) B6
limit 100;

