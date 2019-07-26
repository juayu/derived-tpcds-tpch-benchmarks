-- start query 41 in stream 17 using template query41.tpl
select  distinct(i_product_name)
 from item i1
 where i_manufact_id between 866 and 866+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'burnished' or i_color = 'black') and 
        (i_units = 'Pound' or i_units = 'Oz') and
        (i_size = 'extra large' or i_size = 'petite')
        ) or
        (i_category = 'Women' and
        (i_color = 'goldenrod' or i_color = 'hot') and
        (i_units = 'Gross' or i_units = 'Gram') and
        (i_size = 'small' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'peach' or i_color = 'tomato') and
        (i_units = 'Bunch' or i_units = 'Each') and
        (i_size = 'medium' or i_size = 'large')
        ) or
        (i_category = 'Men' and
        (i_color = 'blush' or i_color = 'burlywood') and
        (i_units = 'Bundle' or i_units = 'Dozen') and
        (i_size = 'extra large' or i_size = 'petite')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'moccasin' or i_color = 'slate') and 
        (i_units = 'Tsp' or i_units = 'Case') and
        (i_size = 'extra large' or i_size = 'petite')
        ) or
        (i_category = 'Women' and
        (i_color = 'sienna' or i_color = 'beige') and
        (i_units = 'Cup' or i_units = 'Unknown') and
        (i_size = 'small' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'powder' or i_color = 'bisque') and
        (i_units = 'Lb' or i_units = 'Ounce') and
        (i_size = 'medium' or i_size = 'large')
        ) or
        (i_category = 'Men' and
        (i_color = 'blue' or i_color = 'seashell') and
        (i_units = 'Tbl' or i_units = 'Box') and
        (i_size = 'extra large' or i_size = 'petite')
        )))) > 0
 order by i_product_name
 limit 100;

