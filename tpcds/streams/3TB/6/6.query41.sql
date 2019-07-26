-- start query 41 in stream 6 using template query41.tpl
select  distinct(i_product_name)
 from item i1
 where i_manufact_id between 828 and 828+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'steel' or i_color = 'spring') and 
        (i_units = 'Box' or i_units = 'Dozen') and
        (i_size = 'economy' or i_size = 'N/A')
        ) or
        (i_category = 'Women' and
        (i_color = 'orange' or i_color = 'deep') and
        (i_units = 'Pallet' or i_units = 'Bunch') and
        (i_size = 'extra large' or i_size = 'large')
        ) or
        (i_category = 'Men' and
        (i_color = 'burnished' or i_color = 'maroon') and
        (i_units = 'Tbl' or i_units = 'Carton') and
        (i_size = 'medium' or i_size = 'petite')
        ) or
        (i_category = 'Men' and
        (i_color = 'dim' or i_color = 'plum') and
        (i_units = 'N/A' or i_units = 'Ton') and
        (i_size = 'economy' or i_size = 'N/A')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'peru' or i_color = 'puff') and 
        (i_units = 'Bundle' or i_units = 'Gram') and
        (i_size = 'economy' or i_size = 'N/A')
        ) or
        (i_category = 'Women' and
        (i_color = 'yellow' or i_color = 'violet') and
        (i_units = 'Tsp' or i_units = 'Cup') and
        (i_size = 'extra large' or i_size = 'large')
        ) or
        (i_category = 'Men' and
        (i_color = 'firebrick' or i_color = 'midnight') and
        (i_units = 'Gross' or i_units = 'Case') and
        (i_size = 'medium' or i_size = 'petite')
        ) or
        (i_category = 'Men' and
        (i_color = 'khaki' or i_color = 'purple') and
        (i_units = 'Lb' or i_units = 'Unknown') and
        (i_size = 'economy' or i_size = 'N/A')
        )))) > 0
 order by i_product_name
 limit 100;

