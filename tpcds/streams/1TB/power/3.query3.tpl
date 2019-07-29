
select /* query_templates/query03.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0003.1.0:CF! */  dt.d_year 
       ,item.i_brand_id brand_id 
       ,item.i_brand brand
       ,sum(ss_sales_price) sum_agg
 from  date_dim dt 
      ,store_sales store_sales
      ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
   and store_sales.ss_item_sk = item.i_item_sk
   and item.i_manufact_id = 852
   and dt.d_moy=12
 group by dt.d_year
      ,item.i_brand
      ,item.i_brand_id
 order by dt.d_year
         ,sum_agg desc
         ,brand_id
 limit 100;
