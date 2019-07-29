
select /* query_templates/query32.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0032.1.0:CF! */  sum(cs_ext_discount_amt)  as "excess discount amount" 
from 
   catalog_sales 
   ,item 
   ,date_dim
where
i_manufact_id = 530
and i_item_sk = cs_item_sk 
and d_date between '2001-01-21' and 
        (cast('2001-01-21' as date) + interval '90 days')
and d_date_sk = cs_sold_date_sk 
and cs_ext_discount_amt  
     > ( 
         select 
            1.3 * avg(cs_ext_discount_amt) 
         from 
            catalog_sales 
           ,date_dim
         where 
              cs_item_sk = i_item_sk 
          and d_date between '2001-01-21' and
                             (cast('2001-01-21' as date) + interval '90 days')
          and d_date_sk = cs_sold_date_sk 
      ) 
limit 100;
