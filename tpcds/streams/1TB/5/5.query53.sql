-- start query 53 in stream 5 using template query53.tpl
select  * from 
(select i_manufact_id,
sum(ss_sales_price) sum_sales,
avg(sum(ss_sales_price)) over (partition by i_manufact_id) avg_quarterly_sales
from item, store_sales, date_dim, store
where ss_item_sk = i_item_sk and
ss_sold_date_sk = d_date_sk and
ss_store_sk = s_store_sk and
d_month_seq in (1217,1217+1,1217+2,1217+3,1217+4,1217+5,1217+6,1217+7,1217+8,1217+9,1217+10,1217+11) and
((i_category in ('Books','Children','Electronics') and
i_class in ('personal','portable','reference','self-help') and
i_brand in ('scholaramalgamalg #14','scholaramalgamalg #7',
		'exportiunivamalg #9','scholaramalgamalg #9'))
or(i_category in ('Women','Music','Men') and
i_class in ('accessories','classical','fragrances','pants') and
i_brand in ('amalgimporto #1','edu packscholar #1','exportiimporto #1',
		'importoamalg #1')))
group by i_manufact_id, d_qoy ) tmp1
where case when avg_quarterly_sales > 0 
	then abs (sum_sales - avg_quarterly_sales)/ avg_quarterly_sales 
	else null end > 0.1
order by avg_quarterly_sales,
	 sum_sales,
	 i_manufact_id
limit 100;

