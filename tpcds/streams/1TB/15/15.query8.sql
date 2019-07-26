-- start query 8 in stream 15 using template query8.tpl
select  s_store_name
      ,sum(ss_net_profit)
 from store_sales
     ,date_dim
     ,store,
     (select ca_zip
     from (
      SELECT substring(ca_zip,1,5) ca_zip
      FROM customer_address
      WHERE substring(ca_zip,1,5) IN (
                          '20345','72018','96825','72385','93826','89050',
                          '31550','59025','90985','95473','98017',
                          '68187','17799','52592','70058','33276',
                          '54409','97045','14796','91302','66018',
                          '82223','72271','50883','50724','97902',
                          '66096','22167','14858','74510','22835',
                          '94228','73893','43963','20085','37327',
                          '94334','86512','67857','92285','34476',
                          '10277','31893','81863','41605','22092',
                          '24989','70525','47484','84768','72426',
                          '63406','49135','20078','86150','68360',
                          '28160','48999','11494','99049','39712',
                          '93503','36402','55976','71561','18520',
                          '65449','50488','29450','99016','64900',
                          '95896','41889','77995','23526','93631',
                          '90645','83164','31371','21872','72938',
                          '28381','84466','37199','36354','22715',
                          '49383','57642','28389','79063','11361',
                          '13987','31158','12094','10035','60086',
                          '10196','65532','81584','11708','55042',
                          '11819','28651','83678','94928','35528',
                          '39383','70130','32525','16140','61124',
                          '23691','25486','99845','43792','19559',
                          '28638','88624','97761','71709','12109',
                          '56108','73732','39169','48715','53267',
                          '30352','26821','67739','55144','56690',
                          '22774','55413','41921','80203','70566',
                          '70523','85718','90567','15938','66259',
                          '46578','43227','18910','39751','59180',
                          '62462','25958','20153','43676','56876',
                          '21950','11507','26162','51814','86018',
                          '28561','71924','96904','25226','98909',
                          '42831','86837','27902','87823','44706',
                          '86326','91731','65181','79235','94730',
                          '56269','22673','88947','60499','84322',
                          '58286','77950','69615','60664','94468',
                          '64181','47127','14212','40766','82161',
                          '83810','30138','83188','82367','71992',
                          '18434','76778','97268','29136','29943',
                          '37059','54426','34025','66135','50889',
                          '11669','71929','88611','11204','54556',
                          '54881','52367','22868','16969','41432',
                          '35978','54381','53086','54538','61201',
                          '67721','47848','33789','96813','67792',
                          '45375','87412','40546','38862','91992',
                          '35695','92576','87257','15613','64695',
                          '84098','99427','47739','32805','92250',
                          '81908','13961','93712','92251','28327',
                          '96969','99804','93450','80345','19148',
                          '52667','20052','35726','43679','96760',
                          '75440','31790','81039','98816','78316',
                          '48513','68356','17170','52926','21428',
                          '66943','93051','32817','11363','58469',
                          '66451','29250','86464','11150','66128',
                          '12516','26643','40907','52691','33887',
                          '81156','32833','51431','17661','46510',
                          '74487','58182','27747','94141','78424',
                          '17280','47206','62488','79712','60911',
                          '93693','82485','56203','97415','97552',
                          '32093','49725','42716','46463','89938',
                          '13257','29119','57891','65662','25535',
                          '35760','33577','30260','71637','32938',
                          '33379','78813','71705','37864','64163',
                          '53804','74850','95900','34317','34802',
                          '12322','44249','54829','11070','44649',
                          '21075','65724','34747','49412','38062',
                          '27718','58395','28821','72787','64874',
                          '34845','26689','37236','95670','58699',
                          '48240','54851','98259','10911','92019',
                          '35434','74426','11080','15660','14302',
                          '17724','82743','30899','28221','39280',
                          '85624','46697','12305','55367','73728',
                          '34482','54816','17005','96773','13742',
                          '65962','62799','68706','34767','28808',
                          '75850','11407','12649','58109','83922',
                          '59824','51973','90400','24186','59009',
                          '53714','93269','18194','21118','60058',
                          '54115','75914','17646','41333','51724',
                          '97729','95497','97827','87373','86328',
                          '46641','77237','72239','25840')
     intersect
      select ca_zip
      from (SELECT substring(ca_zip,1,5) ca_zip,count(*) cnt
            FROM customer_address, customer
            WHERE ca_address_sk = c_current_addr_sk and
                  c_preferred_cust_flag='Y'
            group by ca_zip
            having count(*) > 10)A1)A2) V1
 where ss_store_sk = s_store_sk
  and ss_sold_date_sk = d_date_sk
  and d_qoy = 1 and d_year = 2001
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;

