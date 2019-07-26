-- start query 8 in stream 13 using template query8.tpl
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
                          '40067','60177','18992','54496','67806','87020',
                          '61631','59144','46240','32592','77874',
                          '74810','26477','52250','34329','78386',
                          '59627','59731','57718','98982','15234',
                          '16078','22258','60033','74619','49877',
                          '42814','51471','27988','25214','69915',
                          '94259','41106','20351','95697','92626',
                          '29872','17166','64740','37372','46631',
                          '63317','20931','90566','86907','41513',
                          '30481','23557','60528','94208','21329',
                          '93867','58604','58320','18482','83245',
                          '95226','41418','60543','17223','56489',
                          '99887','94739','50922','48190','68258',
                          '30373','36768','53040','87440','31745',
                          '21378','15554','83681','16835','76619',
                          '90092','21581','33911','39997','81045',
                          '34109','56912','32511','77114','80802',
                          '26683','77123','77604','82818','46193',
                          '76796','94964','76133','25438','64402',
                          '22489','30645','50358','44325','24051',
                          '86147','91948','37324','59858','57765',
                          '31085','19829','10328','74763','79679',
                          '61164','75229','20497','41965','73599',
                          '59794','12475','12751','84234','12406',
                          '72980','50290','33165','47533','16714',
                          '87466','54862','43023','13685','51053',
                          '84861','99304','84809','71043','65838',
                          '11904','28345','40742','12130','22218',
                          '40058','43488','34951','18612','29258',
                          '96012','12959','42856','58100','90867',
                          '28872','88667','98706','40357','43297',
                          '50725','48328','64055','31212','41504',
                          '80837','89984','21906','10943','42644',
                          '44409','80529','21763','23799','78095',
                          '93903','78247','59286','15364','99220',
                          '38649','11124','91305','50849','21139',
                          '24733','33553','82479','77489','19779',
                          '70942','19634','84602','71592','82606',
                          '58358','27701','58671','34761','69049',
                          '69220','87833','64738','64602','15784',
                          '68815','77764','53084','95849','58228',
                          '49406','19182','48031','36373','47237',
                          '66804','72305','12926','71483','45362',
                          '35766','44301','32842','17490','26423',
                          '48458','94210','63101','25991','51274',
                          '63118','45111','33091','30143','12352',
                          '74284','77166','59763','28307','80146',
                          '79174','59364','79272','94905','96432',
                          '85628','83669','27562','78469','54417',
                          '43199','10397','26672','41756','56007',
                          '60513','90069','36954','50756','28145',
                          '20400','10629','71207','15299','64306',
                          '79702','28299','74624','30828','72242',
                          '24105','57792','90876','41372','24937',
                          '91572','83223','75109','90890','15171',
                          '44425','13760','25558','78808','42702',
                          '52232','47280','87868','49822','99323',
                          '34985','79214','46792','68193','59210',
                          '73835','86953','83639','72478','52639',
                          '67501','61154','11239','65121','44680',
                          '49112','82209','44742','77008','78488',
                          '96844','39214','31106','56792','40324',
                          '83193','40711','64535','84070','28218',
                          '60011','18930','39424','28429','30003',
                          '81850','19884','35923','22134','10853',
                          '82535','27601','89474','58378','78305',
                          '28754','36155','59025','18270','91723',
                          '49806','51748','92069','21884','37511',
                          '66926','70216','67177','48853','94205',
                          '31001','33571','89754','43677','78982',
                          '67666','54482','24530','95767','36894',
                          '46002','83350','14790','54920','92594',
                          '38598','66225','74506','40310','14841',
                          '82243','43512','96509','38481','59972',
                          '70476','25716','50086','35354','20989',
                          '66824','25867','43862','91206','41034',
                          '24374','14559','17924','31544','38815',
                          '58911','81303','36042','40503','70531',
                          '47801','50986','59619','17669','47896',
                          '69600','54989','20247','45434')
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
