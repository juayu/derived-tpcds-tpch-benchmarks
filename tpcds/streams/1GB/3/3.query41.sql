-- start query 41 in stream 3 using template query41.tpl
select  distinct(i_product_name)
 from item i1
 where i_manufact_id between 682 and 682+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'puff' or i_color = 'burnished') and 
        (i_units = 'Dram' or i_units = 'Box') and
        (i_size = 'medium' or i_size = 'petite')
        ) or
        (i_category = 'Women' and
        (i_color = 'pale' or i_color = 'peach') and
        (i_units = 'Bunch' or i_units = 'Gross') and
        (i_size = 'extra large' or i_size = 'small')
        ) or
        (i_category = 'Men' and
        (i_color = 'cyan' or i_color = 'khaki') and
        (i_units = 'Each' or i_units = 'N/A') and
        (i_size = 'large' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'seashell' or i_color = 'metallic') and
        (i_units = 'Tbl' or i_units = 'Cup') and
        (i_size = 'medium' or i_size = 'petite')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'gainsboro' or i_color = 'tomato') and 
        (i_units = 'Unknown' or i_units = 'Bundle') and
        (i_size = 'medium' or i_size = 'petite')
        ) or
        (i_category = 'Women' and
        (i_color = 'chartreuse' or i_color = 'bisque') and
        (i_units = 'Dozen' or i_units = 'Gram') and
        (i_size = 'extra large' or i_size = 'small')
        ) or
        (i_category = 'Men' and
        (i_color = 'beige' or i_color = 'cream') and
        (i_units = 'Pound' or i_units = 'Carton') and
        (i_size = 'large' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'white' or i_color = 'indian') and
        (i_units = 'Ounce' or i_units = 'Case') and
        (i_size = 'medium' or i_size = 'petite')
        )))) > 0
 order by i_product_name
 limit 100;

