-- start query 8 in stream 12 using template query8.tpl
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
                          '22766','85334','43098','11928','20358','91891',
                          '35082','17469','80693','41657','63787',
                          '58133','26521','79639','62962','91239',
                          '66106','83111','10074','44886','44302',
                          '70197','63772','14539','94942','32180',
                          '81684','39159','61753','36375','47837',
                          '29769','33488','90175','11617','41672',
                          '21822','51778','99790','41157','52981',
                          '63433','50538','81659','26814','93213',
                          '14016','77093','20198','32217','45471',
                          '55117','34817','81039','64669','96861',
                          '95093','86910','27162','98786','41070',
                          '26904','92258','25045','11862','64489',
                          '95424','41875','27610','57321','48773',
                          '78364','21007','86368','17674','61070',
                          '52621','60266','85404','24241','72900',
                          '63187','78816','11369','60592','88746',
                          '47244','62528','82868','25671','82562',
                          '80106','26719','82953','77413','25719',
                          '87226','98481','32248','86469','38812',
                          '59546','71663','16212','74086','17823',
                          '60080','52788','99271','90495','23917',
                          '20387','38487','33340','77348','78413',
                          '51225','76113','62104','73159','74533',
                          '64412','26560','87762','65594','66595',
                          '15539','12757','84510','57977','82826',
                          '58547','10416','89480','79857','18377',
                          '54172','36274','28775','20312','72737',
                          '84165','95900','34102','76911','58812',
                          '46362','95259','96803','61186','29954',
                          '81345','58507','47002','26569','61193',
                          '24204','53531','31700','57192','17418',
                          '68749','42748','71228','63115','81208',
                          '86352','53037','89454','25544','21013',
                          '11493','92220','67222','28453','36297',
                          '86405','16088','74161','88362','85552',
                          '86861','26738','87632','34934','84130',
                          '54611','77904','80181','81867','57585',
                          '48055','93907','35197','36510','42237',
                          '15063','21606','41662','12420','84294',
                          '73301','40635','49122','83451','39374',
                          '61269','74572','71076','80776','88732',
                          '99837','72503','95281','99889','91273',
                          '76582','26025','98352','43310','22853',
                          '79918','31856','79615','77044','10850',
                          '91725','76499','90223','98906','99238',
                          '75763','30016','50696','55409','51989',
                          '58000','59452','32525','39788','88202',
                          '44949','56331','27784','37934','85583',
                          '32704','87619','84849','80836','73242',
                          '19937','52023','29015','89289','69013',
                          '98029','10164','33199','88414','35888',
                          '36860','26369','22078','30109','86827',
                          '61388','41403','10201','54104','36920',
                          '37552','16385','55947','13281','43032',
                          '71177','37070','15199','31371','92675',
                          '73488','56804','76742','62638','82906',
                          '23925','16198','24405','55420','74562',
                          '79199','26322','80601','30826','10558',
                          '71571','83838','18468','72982','73154',
                          '79745','49251','12241','84080','98935',
                          '73719','79015','59237','17029','23658',
                          '27829','43685','73733','24737','73250',
                          '38248','72381','22234','78572','40349',
                          '27910','22739','13415','74484','72326',
                          '23273','39393','73361','41451','99461',
                          '36638','59658','52993','64427','31061',
                          '45200','84820','23298','99113','54746',
                          '52122','21661','21503','81883','62605',
                          '31451','66994','92994','15659','97569',
                          '49977','87332','36655','10770','18327',
                          '97858','42007','40008','41464','51251',
                          '50887','39564','38858','37463','15925',
                          '79960','92697','94338','83684','16652',
                          '88831','43168','71913','88451','14703',
                          '75640','95601','45409','94264','77763',
                          '63950','72390','80025','11505','70653',
                          '97066','38581','12569','28810','47038',
                          '62153','55266','77354','93599','94189',
                          '64635','97608','93024','65889')
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
