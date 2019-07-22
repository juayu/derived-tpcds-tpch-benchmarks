
select /* query_templates/query96.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0096.1.0:CF! */  count(*) 
from store_sales
    ,household_demographics 
    ,time_dim
    ,store
where ss_sold_time_sk = time_dim.t_time_sk   
    and ss_hdemo_sk = household_demographics.hd_demo_sk 
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 16
    and time_dim.t_minute >= 30
    and household_demographics.hd_dep_count = 3
    and store.s_store_name = 'ese'
order by count(*)
limit 100;
