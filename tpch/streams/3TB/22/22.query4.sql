-- TPC TPC-H Parameter Substitution (Version 2.17.3 build 0)
-- using 1563999664 as a seed to the RNG


select
	o_orderpriority,
	count(*) as order_count
from
	orders
where
	o_orderdate >= date '1994-06-01'
	and o_orderdate < cast (date '1994-06-01' + interval '3 months' as date)
	and exists (
		select
			*
		from
			lineitem
		where
			l_orderkey = o_orderkey
			and l_commitdate < l_receiptdate
	)
group by
	o_orderpriority
order by
	o_orderpriority;