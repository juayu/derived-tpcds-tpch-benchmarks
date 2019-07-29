
select /* query_templates/query82.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0082.1.0:CF! */  i_item_id
       ,i_item_desc
       ,i_current_price
 from item,inventory,date_dim, store_sales
 where i_current_price between 47 and 47+30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between cast('1998-03-30' as date) and (cast('1998-03-30' as date) +  interval '60 days')
 and i_manufact_id in (68,555,43,151)
 and inv_quantity_on_hand between 100 and 500
 and ss_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 limit 100;
