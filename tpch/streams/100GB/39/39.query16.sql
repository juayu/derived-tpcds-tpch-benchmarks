-- TPC TPC-H Parameter Substitution (Version 2.17.3 build 0)
-- using 1563999536 as a seed to the RNG


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
	and p_type not like 'PROMO BURNISHED%'
	and p_size in (24, 18, 25, 10, 6, 12, 35, 28)
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
