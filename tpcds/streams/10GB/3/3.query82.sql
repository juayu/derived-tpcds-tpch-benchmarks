-- start query 82 in stream 3 using template query82.tpl
select  i_item_id
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, store_sales
 where i_current_price between 63 and 63+30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between cast('2001-06-28' as date) and (cast('2001-06-28' as date) +  interval '60 days')
 and i_manufact_id in (26,866,725,612)
 and inv_quantity_on_hand between 100 and 500
 and ss_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 limit 100;

