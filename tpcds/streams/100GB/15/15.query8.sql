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
                          '92222','30940','29025','60099','71989','41572',
                          '49592','91743','96130','96471','78652',
                          '41959','76404','90117','71130','15383',
                          '10097','27419','83929','49909','48339',
                          '25204','70304','82134','67738','13331',
                          '13442','13338','65545','68082','65059',
                          '24861','66172','71486','32950','82078',
                          '18226','23341','26442','41802','29404',
                          '95732','78371','85588','65506','28828',
                          '92506','28117','45833','62137','24548',
                          '58336','37217','49518','90325','16464',
                          '54801','68413','94501','13422','19473',
                          '74875','51301','68589','85882','70393',
                          '76010','54956','34427','25077','84682',
                          '22561','85475','99788','36781','94329',
                          '61480','59063','69450','98755','91260',
                          '41981','85860','65840','42034','67506',
                          '65584','15138','65294','45221','80952',
                          '28444','11209','93642','71531','33689',
                          '17737','98299','67635','66898','44862',
                          '42557','28004','14800','47581','10096',
                          '48659','96340','11300','56053','95849',
                          '24701','12307','34054','89521','74199',
                          '55417','16347','13856','35861','19273',
                          '74398','68107','44602','42482','29165',
                          '80325','63437','36613','87619','73018',
                          '64922','28666','23245','75057','62190',
                          '31951','92933','74378','40901','38861',
                          '66494','27942','81098','83949','70556',
                          '82629','15668','47261','97474','19297',
                          '33177','23076','27530','36651','75378',
                          '25345','29000','80724','19428','61693',
                          '16681','48472','44820','63012','89315',
                          '19546','34592','56136','49221','34997',
                          '38714','15040','74125','72800','50988',
                          '71151','17761','61556','44895','72076',
                          '82931','57504','82802','19279','64188',
                          '24487','11765','40489','40833','55750',
                          '32189','88561','96502','26113','81536',
                          '71673','16600','91369','15084','40642',
                          '26786','72030','95218','48184','15395',
                          '93037','62571','18244','48463','12664',
                          '85752','41899','44565','83973','30509',
                          '91890','29092','42957','55781','39936',
                          '73783','51767','23957','78182','41914',
                          '62106','67967','54005','53065','85629',
                          '66173','67413','66019','68940','43234',
                          '65887','53481','37666','28052','19774',
                          '79668','57692','99327','99765','64598',
                          '30465','49439','78151','90070','63645',
                          '60186','15881','78451','33871','64077',
                          '55029','89812','72286','44292','96490',
                          '28336','93049','36465','83377','84021',
                          '76939','53553','77796','50664','22896',
                          '87289','81339','12523','18693','30359',
                          '32792','46897','56084','72382','53639',
                          '58261','17802','44302','17266','90990',
                          '59972','60464','27753','44453','23992',
                          '77493','69327','93230','79114','40931',
                          '38869','95205','69064','77245','24462',
                          '37422','11151','56811','71170','68247',
                          '28678','99271','49593','89067','98996',
                          '45746','81713','22480','81398','41331',
                          '59161','14257','61007','49454','94131',
                          '17004','64220','17892','79375','59642',
                          '36009','91724','53505','86366','97156',
                          '96545','92820','31199','20478','44852',
                          '96617','59804','96187','17949','38267',
                          '55552','73650','25799','95306','16356',
                          '57436','89391','15878','29358','20220',
                          '81306','52687','72475','20069','29957',
                          '54682','89897','87079','17577','38658',
                          '68089','23328','91765','24449','70094',
                          '42620','57195','66032','52673','14041',
                          '87043','69502','45776','87520','46353',
                          '94592','87300','86076','75629','25145',
                          '76221','97218','33199','50222','80235',
                          '66189','84240','49182','61517','21288',
                          '28179','19162','42771','67609','55958',
                          '33902','57160','14206','15679')
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

