-- TPC TPC-H Parameter Substitution (Version 2.17.3 build 0)
-- using 1563999397 as a seed to the RNG


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
	and p_brand <> 'Brand#53'
	and p_type not like 'LARGE PLATED%'
	and p_size in (9, 17, 3, 16, 37, 29, 24, 5)
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
