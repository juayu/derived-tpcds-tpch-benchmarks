
select /* query_templates/query37.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0037.1.0:CF! */  i_item_id
       ,i_item_desc
       ,i_current_price
 from item,inventory,date_dim, catalog_sales
 where i_current_price between 65 and 65 + 30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between cast('1999-01-31' as date) and (cast('1999-01-31' as date) +  interval '60 days')
 and i_manufact_id in (937,918,861,916)
 and inv_quantity_on_hand between 100 and 500
 and cs_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 limit 100;
