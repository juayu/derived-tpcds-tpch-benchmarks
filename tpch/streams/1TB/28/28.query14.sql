-- TPC TPC-H Parameter Substitution (Version 2.17.3 build 0)
-- using 1563999611 as a seed to the RNG


select
	100.00 * sum(case
		when p_type like 'PROMO%'
			then l_extendedprice * (1 - l_discount)
		else 0
	end) / sum(l_extendedprice * (1 - l_discount)) as promo_revenue
from
	lineitem,
	part
where
	l_partkey = p_partkey
	and l_shipdate >= date '1995-01-01'
	and l_shipdate < date '1995-01-01' + interval '1' month;
