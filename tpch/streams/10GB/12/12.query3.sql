-- TPC TPC-H Parameter Substitution (Version 2.17.3 build 0)
-- using 1563999391 as a seed to the RNG


select
	l_orderkey,
	sum(l_extendedprice * (1 - l_discount)) as revenue,
	o_orderdate,
	o_shippriority
from
	customer,
	orders,
	lineitem
where
	c_mktsegment = 'AUTOMOBILE'
	and c_custkey = o_custkey
	and l_orderkey = o_orderkey
	and o_orderdate < date '1995-03-27'
	and l_shipdate > date '1995-03-27'
group by
	l_orderkey,
	o_orderdate,
	o_shippriority
order by
	revenue desc,
	o_orderdate
limit 10;
