
select /* query_templates/query09.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0009.1.0:CF! */ case when (select count(*) 
                  from store_sales 
                  where ss_quantity between 1 and 20) > 82038080
            then (select avg(ss_ext_list_price) 
                  from store_sales 
                  where ss_quantity between 1 and 20) 
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 1 and 20) end bucket1 ,
       case when (select count(*)
                  from store_sales
                  where ss_quantity between 21 and 40) > 17695998
            then (select avg(ss_ext_list_price)
                  from store_sales
                  where ss_quantity between 21 and 40) 
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 21 and 40) end bucket2,
       case when (select count(*)
                  from store_sales
                  where ss_quantity between 41 and 60) > 74944694
            then (select avg(ss_ext_list_price)
                  from store_sales
                  where ss_quantity between 41 and 60)
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 41 and 60) end bucket3,
       case when (select count(*)
                  from store_sales
                  where ss_quantity between 61 and 80) > 9286551
            then (select avg(ss_ext_list_price)
                  from store_sales
                  where ss_quantity between 61 and 80)
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 61 and 80) end bucket4,
       case when (select count(*)
                  from store_sales
                  where ss_quantity between 81 and 100) > 51526761
            then (select avg(ss_ext_list_price)
                  from store_sales
                  where ss_quantity between 81 and 100)
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 81 and 100) end bucket5
from reason
where r_reason_sk = 1
;
