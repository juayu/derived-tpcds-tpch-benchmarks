-- start query 41 in stream 7 using template query41.tpl
select  distinct(i_product_name)
 from item i1
 where i_manufact_id between 828 and 828+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'indian' or i_color = 'almond') and 
        (i_units = 'Oz' or i_units = 'Each') and
        (i_size = 'economy' or i_size = 'extra large')
        ) or
        (i_category = 'Women' and
        (i_color = 'light' or i_color = 'linen') and
        (i_units = 'Lb' or i_units = 'Box') and
        (i_size = 'small' or i_size = 'medium')
        ) or
        (i_category = 'Men' and
        (i_color = 'navajo' or i_color = 'olive') and
        (i_units = 'Carton' or i_units = 'Tsp') and
        (i_size = 'petite' or i_size = 'N/A')
        ) or
        (i_category = 'Men' and
        (i_color = 'royal' or i_color = 'sienna') and
        (i_units = 'Bunch' or i_units = 'Bundle') and
        (i_size = 'economy' or i_size = 'extra large')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'honeydew' or i_color = 'saddle') and 
        (i_units = 'Cup' or i_units = 'Ton') and
        (i_size = 'economy' or i_size = 'extra large')
        ) or
        (i_category = 'Women' and
        (i_color = 'blush' or i_color = 'lavender') and
        (i_units = 'Ounce' or i_units = 'Pound') and
        (i_size = 'small' or i_size = 'medium')
        ) or
        (i_category = 'Men' and
        (i_color = 'navy' or i_color = 'azure') and
        (i_units = 'Gross' or i_units = 'Case') and
        (i_size = 'petite' or i_size = 'N/A')
        ) or
        (i_category = 'Men' and
        (i_color = 'dark' or i_color = 'peru') and
        (i_units = 'Dram' or i_units = 'Gram') and
        (i_size = 'economy' or i_size = 'extra large')
        )))) > 0
 order by i_product_name
 limit 100;

