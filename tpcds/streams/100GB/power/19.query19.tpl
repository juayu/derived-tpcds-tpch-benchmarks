
select /* query_templates/query19.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0019.1.0:CF! */  i_brand_id brand_id, i_brand brand, i_manufact_id, i_manufact,
 	sum(ss_ext_sales_price) ext_price
 from date_dim,store_sales,item,customer,customer_address,store
 where d_date_sk = ss_sold_date_sk
   and ss_item_sk = i_item_sk
   and i_manager_id=24
   and d_moy=11
   and d_year=1999
   and ss_customer_sk = c_customer_sk 
   and c_current_addr_sk = ca_address_sk
   and substring(ca_zip,1,5) <> substring(s_zip,1,5) 
   and ss_store_sk = s_store_sk 
 group by i_brand
      ,i_brand_id
      ,i_manufact_id
      ,i_manufact
 order by ext_price desc
         ,i_brand
         ,i_brand_id
         ,i_manufact_id
         ,i_manufact
limit 100 ;
