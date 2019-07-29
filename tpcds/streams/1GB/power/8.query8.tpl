
select /* query_templates/query08.tpl.0 !CF:IR-815dab58-a393-11e9-a528-06872b3fecc8.power_run01.power-query.power-0000.i0008.1.0:CF! */  s_store_name
      ,sum(ss_net_profit)
 from store_sales
     ,date_dim
     ,store,
     (select ca_zip
     from (
      SELECT substring(ca_zip,1,5) ca_zip
      FROM customer_address
      WHERE substring(ca_zip,1,5) IN (
                          '11543','63059','61794','52788','16294','59301',
                          '60211','75189','95628','35204','49809',
                          '99328','25459','76337','65611','22575',
                          '80268','27186','81596','18975','55380',
                          '33182','48902','27400','38201','12968',
                          '64058','69059','57640','41637','11892',
                          '95809','59615','63482','46074','27915',
                          '59888','27593','34648','55903','40304',
                          '69088','32088','29375','12526','98153',
                          '80785','57057','87048','36297','72191',
                          '92687','10683','23452','51439','15065',
                          '26522','30984','58515','72370','74289',
                          '47388','29839','69812','27149','49730',
                          '32322','35870','36184','20296','62671',
                          '36580','58526','20431','93186','42505',
                          '22970','24812','62116','19478','46130',
                          '95077','15898','45583','30419','99161',
                          '49415','37966','82489','35764','22229',
                          '47958','38750','71415','70952','47717',
                          '11220','13551','16912','75646','64009',
                          '89208','93325','87521','23201','46797',
                          '37445','63583','45436','54147','49847',
                          '23691','48444','78650','29287','40205',
                          '16134','73620','61569','90653','62456',
                          '17874','74088','86647','58473','48128',
                          '81892','62841','24891','49663','11524',
                          '15300','59526','34821','96672','48542',
                          '57349','73702','49718','31791','61203',
                          '54601','22893','66088','53833','13487',
                          '39546','48506','17935','63966','72667',
                          '16476','88648','46480','90731','49705',
                          '22049','28697','53525','35631','41511',
                          '71797','83991','73379','77025','72677',
                          '17404','77705','37131','74561','16620',
                          '23481','63371','61310','26048','14398',
                          '20199','28581','35701','16799','81446',
                          '19000','77157','90548','50584','14956',
                          '53382','38480','42636','23464','76559',
                          '67967','16095','17149','17780','31966',
                          '53028','16372','83801','42612','24145',
                          '40736','84246','28852','18263','21270',
                          '81627','36936','33021','25051','29938',
                          '39521','64054','51936','89913','87371',
                          '22968','11168','64193','60173','97602',
                          '39824','75140','46583','96716','18577',
                          '75478','28331','43488','23988','66850',
                          '54266','78331','55710','71624','69500',
                          '47852','17957','73994','52265','11157',
                          '18880','98562','17039','97799','79966',
                          '10048','43520','17943','86184','39465',
                          '37045','59869','12498','42490','68233',
                          '54552','90773','52657','16126','79324',
                          '86665','24709','51421','14232','39993',
                          '29237','60299','38102','51706','66237',
                          '46339','41500','26197','83222','69570',
                          '55953','53490','33048','52609','92139',
                          '18983','11567','27481','38297','60720',
                          '75902','70889','20426','19333','32029',
                          '73897','52586','98656','41011','89445',
                          '58603','46508','72486','69511','25739',
                          '46017','42990','42211','59446','38099',
                          '81719','79197','65952','44884','32591',
                          '28347','48865','60337','95357','37681',
                          '50644','15578','31193','10655','93923',
                          '39044','11765','47939','11702','37567',
                          '34852','29614','67489','75329','13045',
                          '40662','26180','85983','38477','22191',
                          '49033','20283','52177','11161','65403',
                          '31731','12982','34252','96052','20994',
                          '45524','44251','15287','48892','16542',
                          '47327','46412','80405','68080','82989',
                          '76874','80440','95319','66514','67168',
                          '96656','70781','95942','96073','54685',
                          '10472','17278','23238','42778','46165',
                          '64088','83790','40679','57414','12990',
                          '27720','67505','96764','95175','69424',
                          '13701','55707','90431','66646','61404',
                          '20935','66973','58314','62021','17271',
                          '14928','31976','53201','80894','37470',
                          '36614','85457','15523','42324')
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
  and d_qoy = 2 and d_year = 2001
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;
