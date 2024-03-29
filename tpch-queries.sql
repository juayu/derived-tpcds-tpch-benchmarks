/* Disable results caching */
set enable_result_cache_for_session to off;

/* TPC_H  Query 1 - Pricing Summary Report */
 set query_group='RSPERF TPC-H 1.1';
SELECT L_RETURNFLAG,
 L_LINESTATUS,
 SUM(L_QUANTITY)     AS SUM_QTY,
 SUM(L_EXTENDEDPRICE)    AS SUM_BASE_PRICE,
 SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT))  AS SUM_DISC_PRICE,
 SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)*(1+L_TAX)) AS SUM_CHARGE,
 AVG(L_QUANTITY)     AS AVG_QTY,
 AVG(L_EXTENDEDPRICE)    AS AVG_PRICE,
 AVG(L_DISCOUNT)     AS AVG_DISC,
 COUNT(*)     AS COUNT_ORDER
FROM LINEITEM
WHERE L_SHIPDATE <= cast ( date '1998-12-01' - interval '62 days' as date )
GROUP BY L_RETURNFLAG,
  L_LINESTATUS
ORDER BY L_RETURNFLAG,
  L_LINESTATUS
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 2 - Minimum Cost Supplier */
set query_group='RSPERF TPC-H 1.2';
SELECT    TOP 100
    S_ACCTBAL,
    S_NAME,
    N_NAME,
    P_PARTKEY,
    P_MFGR,
    S_ADDRESS,
    S_PHONE,
    S_COMMENT
FROM    PART,
    SUPPLIER,
    PARTSUPP,
    NATION,
    REGION
WHERE    P_PARTKEY    = PS_PARTKEY AND
    S_SUPPKEY    = PS_SUPPKEY AND
    P_SIZE        = 34 AND
    P_TYPE        LIKE '%COPPER' AND
    S_NATIONKEY    = N_NATIONKEY AND
    N_REGIONKEY    = R_REGIONKEY AND
    R_NAME        = 'MIDDLE EAST' AND
    PS_SUPPLYCOST    = (    SELECT    MIN(PS_SUPPLYCOST)
                FROM    PARTSUPP,
                    SUPPLIER,
                    NATION,
                    REGION
                WHERE    P_PARTKEY    = PS_PARTKEY AND
                    S_SUPPKEY    = PS_SUPPKEY AND
                    S_NATIONKEY    = N_NATIONKEY AND
                    N_REGIONKEY    = R_REGIONKEY AND
                    R_NAME        = 'MIDDLE EAST'
              )
ORDER    BY    S_ACCTBAL DESC,
        N_NAME,
        S_NAME,
        P_PARTKEY
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 3 - Shipping Priority */
set query_group='RSPERF TPC-H 1.3';
SELECT    TOP 10
    L_ORDERKEY,
    SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT))    AS REVENUE,
    O_ORDERDATE,
    O_SHIPPRIORITY
FROM    CUSTOMER,
    ORDERS,
    LINEITEM
WHERE    C_MKTSEGMENT    = 'FURNITURE' AND
    C_CUSTKEY    = O_CUSTKEY AND
    L_ORDERKEY    = O_ORDERKEY AND
    O_ORDERDATE    < '1995-03-28' AND
    L_SHIPDATE    > '1995-03-28'
GROUP    BY    L_ORDERKEY,
        O_ORDERDATE,
        O_SHIPPRIORITY
ORDER    BY    REVENUE DESC,
        O_ORDERDATE
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 4 - Order Priority Checking */
set query_group='RSPERF TPC-H 1.4';
SELECT    O_ORDERPRIORITY,
    COUNT(*)        AS ORDER_COUNT
FROM    ORDERS
WHERE    O_ORDERDATE    >= '1997-04-01' AND
    O_ORDERDATE    < cast (date '1997-04-01' + interval '3 months' as date) AND
    EXISTS        (    SELECT    *
                FROM    LINEITEM
                WHERE    L_ORDERKEY    = O_ORDERKEY AND
                    L_COMMITDATE    < L_RECEIPTDATE
            )
GROUP    BY    O_ORDERPRIORITY
ORDER    BY    O_ORDERPRIORITY
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 5 - Local Supplier Volume */
set query_group='RSPERF TPC-H 1.5';
SELECT    N_NAME,
    SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT))    AS REVENUE
FROM    CUSTOMER,
    ORDERS,
    LINEITEM,
    SUPPLIER,
    NATION,
    REGION
WHERE    C_CUSTKEY    = O_CUSTKEY AND
    L_ORDERKEY    = O_ORDERKEY AND
    L_SUPPKEY    = S_SUPPKEY AND
    C_NATIONKEY    = S_NATIONKEY AND
    S_NATIONKEY    = N_NATIONKEY AND
    N_REGIONKEY    = R_REGIONKEY AND
    R_NAME        = 'MIDDLE EAST' AND
        o_orderdate >= date '1994-01-01' and 
     o_orderdate < cast (date '1994-01-01' + interval '1 year' as date)
GROUP    BY    N_NAME
ORDER    BY    REVENUE DESC;
-- using 821113222 as a seed to the RNG

/* TPC_H  Query 6 - Forecasting Revenue Change */
set query_group='RSPERF TPC-H 1.6';
SELECT    SUM(L_EXTENDEDPRICE*L_DISCOUNT)    AS REVENUE
FROM    LINEITEM
WHERE    L_SHIPDATE    >= '1994-01-01' AND
    L_SHIPDATE    < cast (date '1994-01-01' + interval '1 year' as date)     AND
    L_DISCOUNT    BETWEEN 0.09 - 0.01 AND 0.09 + 0.01 AND
    L_QUANTITY    < 24
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 7 - Volume Shipping */
set query_group='RSPERF TPC-H 1.7';
SELECT    SUPP_NATION,
    CUST_NATION,
    L_YEAR,
    SUM(VOLUME)    AS REVENUE
FROM    (    SELECT    N1.N_NAME            AS SUPP_NATION,
            N2.N_NAME            AS CUST_NATION,
            extract(year from L_SHIPDATE) as L_YEAR,
            L_EXTENDEDPRICE*(1-L_DISCOUNT)    AS VOLUME
        FROM    SUPPLIER,
            LINEITEM,
            ORDERS,
            CUSTOMER,
            NATION N1,
            NATION N2
        WHERE    S_SUPPKEY    = L_SUPPKEY AND
            O_ORDERKEY    = L_ORDERKEY AND
            C_CUSTKEY    = O_CUSTKEY AND
            S_NATIONKEY    = N1.N_NATIONKEY AND
            C_NATIONKEY    = N2.N_NATIONKEY AND
            (    (N1.N_NAME    = 'UNITED STATES'    AND N2.N_NAME    = 'JAPAN')
                OR
                (N1.N_NAME    = 'JAPAN'    AND N2.N_NAME    = 'UNITED STATES')
            ) AND
            L_SHIPDATE    BETWEEN '1995-01-01' AND '1996-12-31'
    )    AS SHIPPING
GROUP    BY    SUPP_NATION,
        CUST_NATION,
        L_YEAR
ORDER    BY    SUPP_NATION,
        CUST_NATION,
        L_YEAR
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 8 - National Market Share */
set query_group='RSPERF TPC-H 1.8';

SELECT    O_YEAR,
    SUM(CASE    WHEN    NATION    = 'JAPAN'
            THEN    VOLUME
            ELSE    0
            END) / SUM(VOLUME)    AS MKT_SHARE
FROM    (    SELECT    
                      extract(year from o_orderdate) as o_year,
            L_EXTENDEDPRICE * (1-L_DISCOUNT)    AS VOLUME,
            N2.N_NAME                AS NATION
        FROM    PART,
            SUPPLIER,
            LINEITEM,
            ORDERS,
            CUSTOMER,
            NATION N1,
            NATION N2,
            REGION
        WHERE    P_PARTKEY    = L_PARTKEY AND
            S_SUPPKEY    = L_SUPPKEY AND
            L_ORDERKEY    = O_ORDERKEY AND
            O_CUSTKEY    = C_CUSTKEY AND
            C_NATIONKEY    = N1.N_NATIONKEY AND
            N1.N_REGIONKEY    = R_REGIONKEY AND
            R_NAME        = 'ASIA' AND
            S_NATIONKEY    = N2.N_NATIONKEY AND
            O_ORDERDATE    BETWEEN '1995-01-01' AND '1996-12-31' AND
            P_TYPE        = 'MEDIUM ANODIZED COPPER'
    )    AS    ALL_NATIONS
GROUP    BY    O_YEAR
ORDER    BY    O_YEAR
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 9 - Product Type Profit Measure */
set query_group='RSPERF TPC-H 1.9';

SELECT    NATION,
    O_YEAR,
    SUM(AMOUNT)    AS SUM_PROFIT
FROM    (    SELECT    N_NAME                            AS NATION,
            extract(year from o_orderdate) as o_year,
            L_EXTENDEDPRICE*(1-L_DISCOUNT)-PS_SUPPLYCOST*L_QUANTITY    AS AMOUNT
        FROM    PART,
            SUPPLIER,
            LINEITEM,
            PARTSUPP,
            ORDERS,
            NATION
        WHERE    S_SUPPKEY    = L_SUPPKEY AND
            PS_SUPPKEY    = L_SUPPKEY AND
            PS_PARTKEY    = L_PARTKEY AND
            P_PARTKEY    = L_PARTKEY AND
            O_ORDERKEY    = L_ORDERKEY AND
            S_NATIONKEY    = N_NATIONKEY AND
            P_NAME        LIKE '%green%'
    )    AS PROFIT
GROUP    BY    NATION,
        O_YEAR
ORDER    BY    NATION,
        O_YEAR    DESC;
-- using 821113222 as a seed to the RNG

/* TPC_H  Query 10 - Returned Item Reporting */
set query_group='RSPERF TPC-H 1.10';

SELECT    TOP 20
    C_CUSTKEY,
    C_NAME,
    SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT))    AS REVENUE,
    C_ACCTBAL,
    N_NAME,
    C_ADDRESS,
    C_PHONE,
    C_COMMENT
FROM    CUSTOMER,
    ORDERS,
    LINEITEM,
    NATION
WHERE    C_CUSTKEY    = O_CUSTKEY        AND
    L_ORDERKEY    = O_ORDERKEY        AND
    O_ORDERDATE    >= '1994-01-01'            AND
    O_ORDERDATE < cast (date '1994-01-01' + interval '3 months' as date) AND
    L_RETURNFLAG    = 'R'            AND
    C_NATIONKEY    = N_NATIONKEY
GROUP    BY    C_CUSTKEY,
        C_NAME,
        C_ACCTBAL,
        C_PHONE,
        N_NAME,
        C_ADDRESS,
        C_COMMENT
ORDER    BY    REVENUE    DESC
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 11 - Important Stock Indentification */
set query_group='RSPERF TPC-H 1.11';

SELECT    PS_PARTKEY,
    SUM(PS_SUPPLYCOST*PS_AVAILQTY)    AS VALUE
FROM    PARTSUPP,
    SUPPLIER,
    NATION
WHERE    PS_SUPPKEY    = S_SUPPKEY    AND
    S_NATIONKEY    = N_NATIONKEY    AND
    N_NAME        = 'SAUDI ARABIA'
GROUP    BY    PS_PARTKEY
HAVING    SUM(PS_SUPPLYCOST*PS_AVAILQTY) >
        (    SELECT    SUM(PS_SUPPLYCOST*PS_AVAILQTY) * 0.0000000333
            FROM    PARTSUPP,
                SUPPLIER,
                NATION
            WHERE    PS_SUPPKEY    = S_SUPPKEY    AND
                S_NATIONKEY    = N_NATIONKEY    AND
                N_NAME        = 'SAUDI ARABIA'
        )
ORDER    BY    VALUE    DESC
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 12 - Shipping Modes and Order Priority */
set query_group='RSPERF TPC-H 1.12';

SELECT    L_SHIPMODE,
    SUM(    CASE    WHEN O_ORDERPRIORITY  = '1-URGENT'    OR
                 O_ORDERPRIORITY  = '2-HIGH'
            THEN 1
            ELSE 0
        END)    AS HIGH_LINE_COUNT,
    SUM(    CASE    WHEN O_ORDERPRIORITY <> '1-URGENT'    AND
                 O_ORDERPRIORITY <> '2-HIGH'
            THEN 1
            ELSE 0
        END)    AS LOW_LINE_COUNT
FROM    ORDERS,
    LINEITEM
WHERE    O_ORDERKEY    = L_ORDERKEY        AND
    L_SHIPMODE    IN ('FOB','REG AIR')        AND
    L_COMMITDATE    < L_RECEIPTDATE        AND
    L_SHIPDATE    < L_COMMITDATE        AND
    L_RECEIPTDATE    >= '1995-01-01'            AND
    L_RECEIPTDATE < cast (date '1995-01-01' + interval '1 year' as date)
GROUP    BY    L_SHIPMODE
ORDER    BY    L_SHIPMODE
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 13 - Customer Distribution */
set query_group='RSPERF TPC-H 1.13';

SELECT    C_COUNT,
    COUNT(*)    AS CUSTDIST
FROM    (    SELECT    C_CUSTKEY,
            COUNT(O_ORDERKEY)
        FROM    CUSTOMER left outer join ORDERS on
            C_CUSTKEY    = O_CUSTKEY        AND
            O_COMMENT    not like '%special%requests%'
        GROUP    BY    C_CUSTKEY
    )    AS C_ORDERS (C_CUSTKEY, C_COUNT)
GROUP    BY    C_COUNT
ORDER    BY    CUSTDIST    DESC,
        C_COUNT        DESC
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 14 - Promotion Effect */
set query_group='RSPERF TPC-H 1.14';

SELECT    100.00 * SUM    (    CASE    WHEN P_TYPE LIKE 'PROMO%'
                    THEN L_EXTENDEDPRICE*(1-L_DISCOUNT)
                    ELSE 0
                END) / SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT))    AS PROMO_REVENUE
FROM    LINEITEM,
    PART
WHERE    L_PARTKEY    = P_PARTKEY    AND
    L_SHIPDATE    >= '1995-01-01'        AND
        L_SHIPDATE < cast (date '1995-01-01' + interval '1 month' as date)
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 15 - Create View for Top Supplier Query */
set query_group='RSPERF TPC-H 1.15';
WITH revenue1 AS (
    select
        l_suppkey as supplier_no,
        sum(l_extendedprice * (1 - l_discount)) as total_revenue
    from
        lineitem
    where
        L_SHIPDATE    >= '1995-02-01' AND
    L_SHIPDATE    < cast (date '1995-02-01' + interval '3 months' as date)
    group by
        l_suppkey)

select /*  #RSPERF TPC-H 1.15  */
    s_suppkey,
    s_name,
    s_address,
    s_phone,
    total_revenue
from
    supplier,
    revenue1
where
    s_suppkey = supplier_no
    and total_revenue = (
        select
            max(total_revenue)
        from
            revenue1
    )
order by
    s_suppkey;
-- using 821113222 as a seed to the RNG

/* TPC_H  Query 16 - Parts/Supplier Relationship */
set query_group='RSPERF TPC-H 1.16';
SELECT    P_BRAND,
    P_TYPE,
    P_SIZE,
    COUNT(DISTINCT PS_SUPPKEY)    AS SUPPLIER_CNT
FROM    PARTSUPP,
    PART
WHERE    P_PARTKEY    = PS_PARTKEY                AND
    P_BRAND        <> 'Brand#23'                    AND
    P_TYPE        NOT LIKE 'MEDIUM ANODIZED%'                AND
    P_SIZE        IN (1, 32, 33, 46, 7, 42, 21, 40)    AND
    PS_SUPPKEY    NOT IN    (    SELECT    S_SUPPKEY
                    FROM    SUPPLIER
                    WHERE    S_COMMENT    LIKE '%Customer%Complaints%'
                )
GROUP    BY    P_BRAND,
        P_TYPE,
        P_SIZE
ORDER    BY    SUPPLIER_CNT    DESC,
        P_BRAND,
        P_TYPE,
        P_SIZE
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 17 - Small-Quantity-Order Revenue */
set query_group='RSPERF TPC-H 1.17';
SELECT    SUM(L_EXTENDEDPRICE)/7.0    AS AVG_YEARLY
FROM    LINEITEM,
    PART
WHERE    P_PARTKEY    = L_PARTKEY    AND
    P_BRAND        = 'Brand#32'        AND
    P_CONTAINER    = 'SM CASE'        AND
    L_QUANTITY    <    (    SELECT    0.2 * AVG(L_QUANTITY)
                    FROM    LINEITEM
                    WHERE    L_PARTKEY    = P_PARTKEY
                )
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 18 - Large Volume Customer */
set query_group='RSPERF TPC-H 1.18';
SELECT    TOP 100
    C_NAME,
    C_CUSTKEY,
    O_ORDERKEY,
    O_ORDERDATE,
    O_TOTALPRICE,
    SUM(L_QUANTITY)
FROM    CUSTOMER,
    ORDERS,
    LINEITEM
WHERE    O_ORDERKEY    IN    (    SELECT    L_ORDERKEY
                    FROM    LINEITEM
                    GROUP    BY    L_ORDERKEY HAVING SUM(L_QUANTITY) > 313
                )    AND
    C_CUSTKEY    = O_CUSTKEY    AND
    O_ORDERKEY    = L_ORDERKEY
GROUP    BY    C_NAME,
        C_CUSTKEY,
        O_ORDERKEY,
        O_ORDERDATE,
        O_TOTALPRICE
ORDER    BY    O_TOTALPRICE    DESC,
        O_ORDERDATE
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 19 - Discounted Revenue */
set query_group='RSPERF TPC-H 1.19';
SELECT     SUM(L_EXTENDEDPRICE* (1 - L_DISCOUNT))    AS REVENUE
FROM    LINEITEM,
    PART
WHERE    (    P_PARTKEY    = L_PARTKEY                        AND
        P_BRAND        = 'Brand#14'                            AND
        P_CONTAINER    IN ( 'SM CASE', 'SM BOX', 'SM PACK', 'SM PKG')        AND
        L_QUANTITY    >= 4                            AND
        L_QUANTITY    <= 4 + 10                        AND
        P_SIZE        BETWEEN 1 AND 5                        AND
        L_SHIPMODE    IN ('AIR', 'AIR REG')                    AND
        L_SHIPINSTRUCT    = 'DELIVER IN PERSON'
    )
    OR
    (    P_PARTKEY    = L_PARTKEY                        AND
        P_BRAND        = 'Brand#45'                            AND
        P_CONTAINER    IN ( 'MED BAG', 'MED BOX', 'MED PKG', 'MED PACK')    AND
        L_QUANTITY    >= 18                            AND
        L_QUANTITY    <= 18 + 10                        AND
        P_SIZE        BETWEEN 1 AND 10                    AND
        L_SHIPMODE    IN ('AIR', 'AIR REG')                    AND
        L_SHIPINSTRUCT    = 'DELIVER IN PERSON'
    )
    OR
    (    P_PARTKEY    = L_PARTKEY                        AND
        P_BRAND        = 'Brand#15'                            AND
        P_CONTAINER    IN ( 'LG CASE', 'LG BOX', 'LG PACK', 'LG PKG')        AND
        L_QUANTITY    >= 20                            AND
        L_QUANTITY    <= 20 + 10                        AND
        P_SIZE        BETWEEN 1 AND 15                    AND
        L_SHIPMODE    IN ('AIR', 'AIR REG')                    AND
        L_SHIPINSTRUCT    = 'DELIVER IN PERSON'
    )
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 20 - Potential Part Promotion */
set query_group='RSPERF TPC-H 1.20';
SELECT    S_NAME,
    S_ADDRESS
FROM    SUPPLIER,
    NATION
WHERE    S_SUPPKEY    IN    (    SELECT    PS_SUPPKEY
                    FROM    PARTSUPP
                    WHERE    PS_PARTKEY in    (    SELECT    P_PARTKEY
                                    FROM    PART
                                    WHERE    P_NAME like 'olive%'
                                )    AND
                    PS_AVAILQTY    >    (    SELECT    0.5 * sum(L_QUANTITY)
                                    FROM    LINEITEM
                                    WHERE    L_PARTKEY    = PS_PARTKEY    AND
                                        L_SUPPKEY     = PS_SUPPKEY    AND
                                        L_SHIPDATE    >= '1996-01-01'        AND
                                        L_SHIPDATE    < cast (date '1996-01-01' + interval '1 year' as date)
                                )
                )    AND
    S_NATIONKEY    = N_NATIONKEY    AND
    N_NAME        = 'RUSSIA'
ORDER    BY    S_NAME
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 21 - Suppliers Who Kept Orders Waiting */
set query_group='RSPERF TPC-H 1.21';
SELECT    TOP 100
    S_NAME,
    COUNT(*)    AS NUMWAIT
FROM    SUPPLIER,
    LINEITEM L1,
    ORDERS,
    NATION
WHERE    S_SUPPKEY        = L1.L_SUPPKEY        AND
    O_ORDERKEY        = L1.L_ORDERKEY        AND
    O_ORDERSTATUS        = 'F'            AND
    L1.L_RECEIPTDATE    > L1.L_COMMITDATE    AND
    EXISTS    (    SELECT    *
            FROM    LINEITEM L2
            WHERE    L2.L_ORDERKEY    = L1.L_ORDERKEY    AND
                L2.L_SUPPKEY    <> L1.L_SUPPKEY
        )    AND
    NOT EXISTS    (    SELECT    *
                FROM    LINEITEM L3
                WHERE    L3.L_ORDERKEY        = L1.L_ORDERKEY        AND
                    L3.L_SUPPKEY        <> L1.L_SUPPKEY        AND
                    L3.L_RECEIPTDATE    > L3.L_COMMITDATE
            )    AND
    S_NATIONKEY    = N_NATIONKEY    AND
    N_NAME        = 'MOROCCO'
GROUP    BY    S_NAME
ORDER    BY    NUMWAIT    DESC,
        S_NAME
;-- using 821113222 as a seed to the RNG

/* TPC_H  Query 22 - Global Sales Opportunity */
set query_group='RSPERF TPC-H 1.22';
SELECT    CNTRYCODE,
    COUNT(*)    AS NUMCUST,
    SUM(C_ACCTBAL)    AS TOTACCTBAL
FROM    (    SELECT    SUBSTRING(C_PHONE,1,2)    AS CNTRYCODE,
            C_ACCTBAL
        FROM    CUSTOMER
        WHERE    SUBSTRING(C_PHONE,1,2)    IN    ('32', '12', '30', '20', '29', '16', '13')    AND
            C_ACCTBAL        >    (    SELECT    AVG(C_ACCTBAL)
                                FROM    CUSTOMER
                                WHERE    C_ACCTBAL    > 0.00    AND
                                    SUBSTRING(C_PHONE,1,2)    IN    ('32', '12', '30', '20', '29', '16', '13')
                            )    AND
            NOT EXISTS    (    SELECT    *
                        FROM    ORDERS
                        WHERE    O_CUSTKEY    = C_CUSTKEY
                    )
    )    AS CUSTSALE
GROUP    BY    CNTRYCODE
ORDER    BY    CNTRYCODE;

