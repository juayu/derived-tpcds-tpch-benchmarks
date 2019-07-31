-- start query 8 in stream 6 using template query8.tpl
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
                          '61941','17366','54423','48074','89953','47339',
                          '10041','53307','98354','46642','72779',
                          '41159','97405','71774','58958','58119',
                          '24228','50844','76423','29287','80934',
                          '22662','21023','80435','20096','99476',
                          '91429','22603','27901','12538','32836',
                          '79504','61504','31351','63344','59000',
                          '82802','13463','86071','52491','57530',
                          '96556','93720','24916','69390','91581',
                          '49568','64398','43437','17594','53022',
                          '56381','45818','87166','29328','21195',
                          '27414','11274','36358','34355','63287',
                          '10119','96528','77390','26975','60220',
                          '49336','43057','35694','39668','57031',
                          '91592','35157','30191','20875','59759',
                          '66228','96061','37502','52896','22970',
                          '57293','16752','82307','60703','61194',
                          '37318','48036','95264','92435','15310',
                          '69579','70366','17326','50053','31703',
                          '55133','85370','39343','30197','44176',
                          '80330','80378','56214','31522','19248',
                          '72049','91723','67369','97052','82247',
                          '92446','99422','54107','83676','51282',
                          '70274','58014','67893','33621','61970',
                          '28348','63068','40888','12943','36739',
                          '79309','29966','33518','47779','76896',
                          '75681','31620','77212','60746','30408',
                          '20704','22535','21308','90759','43907',
                          '12666','32082','54913','49572','38564',
                          '19846','44281','72977','56910','92254',
                          '36476','21566','29800','70214','81834',
                          '11045','39268','98119','28589','25613',
                          '21368','38291','74366','67071','31781',
                          '97023','88632','24210','69014','89851',
                          '46156','54221','94983','24451','44240',
                          '91234','50149','69239','30854','76218',
                          '81947','27042','23181','76364','42565',
                          '63994','92449','61599','11249','47703',
                          '76319','83877','89839','54452','99783',
                          '72957','93303','92325','55104','73365',
                          '21480','65124','59446','25122','48623',
                          '16562','98951','61707','11910','59918',
                          '53882','52757','81115','22470','85790',
                          '31829','33244','22671','74425','41174',
                          '97369','81602','17076','67712','24041',
                          '60381','33626','69542','73941','35642',
                          '70709','10810','61608','96652','83903',
                          '19364','41062','14481','58078','89058',
                          '78187','67581','59670','66331','91311',
                          '71566','80830','17265','67376','97008',
                          '49830','73493','98525','96339','56216',
                          '44891','62477','30432','93911','48625',
                          '19173','33170','87642','98859','47958',
                          '43997','64530','38013','80053','76861',
                          '42979','69618','62154','74634','49786',
                          '13134','40282','62142','64222','79899',
                          '53241','17153','93274','65890','54292',
                          '93500','26966','47950','20713','70316',
                          '63186','15506','89585','31977','31949',
                          '98430','47615','28751','62844','19435',
                          '64119','65252','55419','93649','79614',
                          '47686','31762','58988','28781','41823',
                          '90728','21687','30099','55661','86694',
                          '31379','52021','41509','55227','75660',
                          '58151','78920','65698','22453','70816',
                          '78632','73009','10652','40505','52477',
                          '43378','58504','29625','11689','27944',
                          '48370','91856','58973','58731','15686',
                          '61011','75085','56368','64952','36107',
                          '94511','74960','40501','18529','50361',
                          '90161','13312','24499','20072','56968',
                          '54105','89600','96873','38803','89636',
                          '99508','16716','56333','94665','75591',
                          '69550','20844','91493','50641','31857',
                          '84098','64834','71008','38056','25213',
                          '52550','19437','54615','10738','55825',
                          '26567','15904','49024','98124','27059',
                          '89906','60195','36066','53909','33293',
                          '59082','37292','73459','36393','74867',
                          '15656','25217','29871','43031')
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
  and d_qoy = 1 and d_year = 1998
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;
