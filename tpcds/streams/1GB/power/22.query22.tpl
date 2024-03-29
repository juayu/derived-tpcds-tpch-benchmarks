
with /* query_templates/query22.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0022.1.0:CF! */ results as
(select  i_product_name
             ,i_brand
             ,i_class
             ,i_category
             ,inv_quantity_on_hand qoh
       from inventory
           ,date_dim
           ,item
           ,warehouse
       where  inv_date_sk=d_date_sk
              and inv_item_sk=i_item_sk
              and inv_warehouse_sk = w_warehouse_sk
              and d_month_seq between 1219 and 1219 + 11
       group by i_product_name,i_brand,i_class,i_category,inv_quantity_on_hand),
results_rollup as
(select i_product_name, i_brand, i_class, i_category,avg(qoh) qoh
from results
group by i_product_name,i_brand,i_class,i_category
union all
select i_product_name, i_brand, i_class, null i_category,avg(qoh) qoh
from results
group by i_product_name,i_brand,i_class
union all
select i_product_name, i_brand, null i_class, null i_category,avg(qoh) qoh
from results
group by i_product_name,i_brand
union all
select i_product_name, null i_brand, null i_class, null i_category,avg(qoh)  qoh
from results
group by i_product_name
union all
select null i_product_name, null i_brand, null i_class, null i_category,avg(qoh) qoh
from results)
 select  i_product_name, i_brand, i_class, i_category,qoh
      from results_rollup
      order by qoh, i_product_name, i_brand, i_class, i_category
limit 100;
