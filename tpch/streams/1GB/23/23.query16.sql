-- TPC TPC-H Parameter Substitution (Version 2.17.3 build 0)
-- using 1563997070 as a seed to the RNG


select
	p_brand,
	p_type,
	p_size,
	count(distinct ps_suppkey) as supplier_cnt
from
	partsupp,
	part
where
	p_partkey = ps_partkey
	and p_brand <> 'Brand#24'
	and p_type not like 'MEDIUM BURNISHED%'
	and p_size in (32, 42, 45, 38, 31, 27, 17, 37)
	and ps_suppkey not in (
		select
			s_suppkey
		from
			supplier
		where
			s_comment like '%Customer%Complaints%'
	)
group by
	p_brand,
	p_type,
	p_size
order by
	supplier_cnt desc,
	p_brand,
	p_type,
	p_size;
