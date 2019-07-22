
select /* query_templates/query41.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0041.1.0:CF! */  distinct(i_product_name)
 from item i1
 where i_manufact_id between 900 and 900+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'cream' or i_color = 'blue') and 
        (i_units = 'Ton' or i_units = 'Each') and
        (i_size = 'N/A' or i_size = 'extra large')
        ) or
        (i_category = 'Women' and
        (i_color = 'cornsilk' or i_color = 'metallic') and
        (i_units = 'Dozen' or i_units = 'Cup') and
        (i_size = 'large' or i_size = 'small')
        ) or
        (i_category = 'Men' and
        (i_color = 'cornflower' or i_color = 'navajo') and
        (i_units = 'Bundle' or i_units = 'Case') and
        (i_size = 'economy' or i_size = 'medium')
        ) or
        (i_category = 'Men' and
        (i_color = 'maroon' or i_color = 'papaya') and
        (i_units = 'Carton' or i_units = 'Unknown') and
        (i_size = 'N/A' or i_size = 'extra large')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'frosted' or i_color = 'smoke') and 
        (i_units = 'Dram' or i_units = 'Ounce') and
        (i_size = 'N/A' or i_size = 'extra large')
        ) or
        (i_category = 'Women' and
        (i_color = 'tan' or i_color = 'dark') and
        (i_units = 'Pallet' or i_units = 'Pound') and
        (i_size = 'large' or i_size = 'small')
        ) or
        (i_category = 'Men' and
        (i_color = 'purple' or i_color = 'puff') and
        (i_units = 'Tsp' or i_units = 'Lb') and
        (i_size = 'economy' or i_size = 'medium')
        ) or
        (i_category = 'Men' and
        (i_color = 'orchid' or i_color = 'salmon') and
        (i_units = 'Box' or i_units = 'Bunch') and
        (i_size = 'N/A' or i_size = 'extra large')
        )))) > 0
 order by i_product_name
 limit 100;
