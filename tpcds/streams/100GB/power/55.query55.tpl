
select /* query_templates/query55.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0055.1.0:CF! */  i_brand_id brand_id, i_brand brand,
 	sum(ss_ext_sales_price) ext_price
 from date_dim,store_sales, item
 where d_date_sk = ss_sold_date_sk
 	and ss_item_sk = i_item_sk
 	and i_manager_id=11
 	and d_moy=11
 	and d_year=2000
 group by i_brand, i_brand_id
 order by ext_price desc, i_brand_id
limit 100 ;
