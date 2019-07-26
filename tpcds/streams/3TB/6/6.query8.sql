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
                          '22212','65127','80089','64990','56362','96005',
                          '76822','82536','86718','48053','78858',
                          '43324','26640','27218','39297','23386',
                          '93505','24918','41709','46181','35171',
                          '22898','55888','20391','21090','84976',
                          '19385','33203','81550','41799','98196',
                          '96298','22458','95355','71377','40128',
                          '14673','82380','19353','93197','13679',
                          '46199','82352','12717','25602','21856',
                          '77020','80185','92474','53517','94578',
                          '99008','22505','97996','57810','59839',
                          '80805','43726','19162','66073','71563',
                          '70759','10479','89402','69429','28134',
                          '22103','18217','20695','35088','21577',
                          '82196','87273','10320','42293','80589',
                          '71361','36780','35334','61554','96757',
                          '24418','80241','55769','59979','81534',
                          '96045','87342','17799','16209','26155',
                          '42591','53715','30903','12576','33514',
                          '12127','98803','87973','61060','57965',
                          '64060','34488','70359','77623','60260',
                          '81639','39238','79245','18792','36409',
                          '41433','59166','15849','36363','25834',
                          '19264','22274','95870','94196','77466',
                          '69661','74788','61719','59649','23237',
                          '80472','35096','70031','95358','28623',
                          '92568','53865','54371','80644','23787',
                          '31577','51575','13181','19925','51989',
                          '47102','27443','40663','37670','38662',
                          '85685','96856','62336','91587','97347',
                          '35535','22211','75792','33729','39743',
                          '16672','85510','27155','23775','77885',
                          '94321','90959','83556','28777','59362',
                          '89990','75526','21115','61005','60513',
                          '48176','11453','36407','82674','35043',
                          '29530','19510','68933','89565','30250',
                          '34481','13047','58833','84159','93402',
                          '66374','65010','99218','79440','67161',
                          '35352','81405','73366','43134','69442',
                          '65930','19313','20031','53991','44574',
                          '27637','92976','58837','23022','47540',
                          '59153','52429','43756','70269','90819',
                          '46909','49855','15740','16586','88412',
                          '84288','28122','77037','62570','59052',
                          '49657','84106','56869','33425','91461',
                          '92732','68863','60434','34571','40173',
                          '76276','67535','14535','77565','43194',
                          '35704','57951','70420','91873','40447',
                          '93049','14533','71045','54638','94009',
                          '79918','34373','28809','72875','31921',
                          '94199','96050','39585','79019','32560',
                          '87873','73569','94649','67709','70594',
                          '36175','94735','84098','95940','49985',
                          '32552','35906','20631','75849','38007',
                          '26093','77879','83619','90658','29195',
                          '24355','23812','20447','24798','59985',
                          '30307','11774','62605','98172','15472',
                          '29746','71881','60452','45010','10138',
                          '25335','79399','76618','31160','37338',
                          '43665','42257','29217','20114','54883',
                          '71177','48405','78101','14196','58978',
                          '46365','58226','38235','31691','47279',
                          '54047','60876','20951','38633','79063',
                          '12517','28591','51375','49636','89198',
                          '43213','73968','29941','57062','72216',
                          '25633','20799','79861','57931','16999',
                          '87921','62701','44113','90118','81406',
                          '74359','43288','16623','70383','81587',
                          '80445','23846','63299','94987','11718',
                          '85477','57299','33796','96687','48891',
                          '93095','95414','37314','69214','49171',
                          '21604','20696','56160','46088','49074',
                          '46095','36474','83795','35684','79798',
                          '26090','44931','11292','74562','15432',
                          '89654','19272','31073','56996','26743',
                          '95546','36376','51911','20033','17719',
                          '60467','38066','50108','91101','94182',
                          '34739','19801','77310','80665','14002',
                          '68005','60811','71618','87011','58135',
                          '96008','69565','49510','66352')
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
