-- start query 8 in stream 2 using template query8.tpl
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
                          '62625','31840','54304','10157','69938','84442',
                          '82360','64573','31051','92443','50799',
                          '88986','12386','79245','69062','50469',
                          '39780','24047','72514','68996','89345',
                          '44458','41431','75640','31014','14632',
                          '49983','82772','91613','57337','30956',
                          '35926','51324','35619','10311','76110',
                          '34974','57313','90062','52198','99547',
                          '76238','84017','10219','96724','36117',
                          '53245','16808','85649','45287','63862',
                          '48861','37317','88226','17748','30887',
                          '32197','36536','14336','93368','49751',
                          '26198','95305','61317','80372','57737',
                          '51962','59754','58919','73118','20800',
                          '81251','28761','39627','68041','85168',
                          '97725','28171','87466','93191','88114',
                          '61043','38778','22133','29174','54534',
                          '76135','80874','71539','71054','52172',
                          '88905','55475','54049','10882','16715',
                          '80135','44194','24191','68189','28986',
                          '42155','76422','28980','46387','57974',
                          '39555','69714','34294','72733','14182',
                          '70232','13124','75187','16174','63197',
                          '99831','18471','93312','50021','53377',
                          '65349','66281','97213','53636','87894',
                          '95450','96998','21892','41306','22400',
                          '93243','27085','72425','35891','78311',
                          '18955','34859','88139','98542','95416',
                          '35094','33546','69230','67281','22284',
                          '82210','39779','59050','87283','73053',
                          '83445','56648','35070','39420','84256',
                          '23247','23531','27560','68104','84425',
                          '25236','69244','84625','26924','77141',
                          '81545','22104','36060','26267','67172',
                          '46276','92328','22278','21345','80672',
                          '16207','47471','41823','17341','76157',
                          '10577','49259','89032','69417','57455',
                          '51155','51570','66300','30042','83646',
                          '42089','86101','56881','67466','40011',
                          '20268','45581','94445','10826','58694',
                          '18429','62299','50805','15189','26781',
                          '75433','49113','36149','52194','27826',
                          '42488','57925','65591','84559','16088',
                          '79043','77927','50107','86145','10883',
                          '75723','23803','63964','19323','62129',
                          '17094','27242','24414','78954','37318',
                          '56654','26775','59828','84547','74166',
                          '35137','35503','53039','88946','93751',
                          '94106','43304','10613','96948','47231',
                          '50099','80394','54795','67910','50808',
                          '21665','71935','65744','12999','71977',
                          '22903','99080','31043','25521','81440',
                          '90924','89355','19352','95203','37072',
                          '51691','15436','28937','96657','10588',
                          '47807','38915','42646','31671','94809',
                          '32920','60432','15371','36612','71640',
                          '60160','37132','88804','41927','94180',
                          '37575','35498','89893','16814','52778',
                          '53011','23838','75280','21639','44095',
                          '19350','71087','39351','47653','79382',
                          '13534','66611','10118','19578','48532',
                          '90902','49537','92835','10457','78415',
                          '88538','65299','80171','67969','85065',
                          '67566','14761','66349','93324','55705',
                          '18686','25089','71719','75163','47593',
                          '25761','74789','17257','56788','41428',
                          '38332','76158','37267','53420','86856',
                          '34226','80793','71529','69750','46023',
                          '51781','57444','78996','68818','67568',
                          '17626','97323','50135','31460','44874',
                          '60472','19487','99746','99960','24088',
                          '42962','65204','94390','41912','29888',
                          '64306','12948','64805','59293','53069',
                          '48518','41504','43252','70287','42969',
                          '85129','52384','91094','49343','11608',
                          '40706','79362','54935','27967','49220',
                          '16142','44173','90232','44888','71321',
                          '24286','64971','89148','74103','16039',
                          '90160','89767','35381','65364','64362',
                          '74444','10183','76567','45101')
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
  and d_qoy = 2 and d_year = 2000
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;
