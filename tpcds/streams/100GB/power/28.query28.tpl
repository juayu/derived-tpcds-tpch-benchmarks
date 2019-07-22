
select /* query_templates/query28.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0028.1.0:CF! */  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 80 and 80+10 
             or ss_coupon_amt between 4962 and 4962+1000
             or ss_wholesale_cost between 56 and 56+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 117 and 117+10
          or ss_coupon_amt between 1463 and 1463+1000
          or ss_wholesale_cost between 43 and 43+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 71 and 71+10
          or ss_coupon_amt between 17299 and 17299+1000
          or ss_wholesale_cost between 62 and 62+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 90 and 90+10
          or ss_coupon_amt between 4727 and 4727+1000
          or ss_wholesale_cost between 31 and 31+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 93 and 93+10
          or ss_coupon_amt between 2255 and 2255+1000
          or ss_wholesale_cost between 78 and 78+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 140 and 140+10
          or ss_coupon_amt between 7797 and 7797+1000
          or ss_wholesale_cost between 69 and 69+20)) B6
limit 100;
