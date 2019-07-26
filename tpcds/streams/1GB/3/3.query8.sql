-- start query 8 in stream 3 using template query8.tpl
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
                          '16661','57317','91334','10135','96111','92383',
                          '83865','69357','52756','87768','23320',
                          '40089','81589','82031','97706','25730',
                          '14658','19683','59406','41383','36106',
                          '38263','92661','54296','72481','80270',
                          '91583','38957','34057','89510','12852',
                          '44338','10503','88167','81757','56130',
                          '41264','72528','40545','95538','53221',
                          '84942','96238','86890','34793','59746',
                          '54023','14460','19599','66849','66603',
                          '10043','18011','67806','48131','17932',
                          '57423','84747','46415','67939','41944',
                          '16897','86158','85399','23305','54590',
                          '14380','19466','70258','62881','70349',
                          '46633','27290','76996','88650','71402',
                          '24173','35311','96290','17507','45488',
                          '37849','17299','13688','60158','19983',
                          '39569','73730','28091','78443','24200',
                          '77791','17654','23699','65377','61327',
                          '23021','67172','23373','10157','42639',
                          '19403','77374','56573','35266','13408',
                          '48093','69885','68123','18471','43042',
                          '88764','96808','83791','74759','55468',
                          '60081','26845','54546','71487','11291',
                          '14002','91495','24766','89563','73660',
                          '58842','90448','37993','60757','26459',
                          '26733','53841','47766','51503','30442',
                          '23553','87354','58111','99934','89904',
                          '61701','90790','32354','79840','27181',
                          '72141','91779','22972','48554','63257',
                          '26250','11735','80533','60016','83532',
                          '95141','46634','29551','43595','84706',
                          '69383','39787','93765','64402','13493',
                          '96885','47521','33136','31377','52840',
                          '88486','18063','58457','81583','92634',
                          '16078','69088','84442','39530','80941',
                          '35400','24143','92875','25498','63451',
                          '56162','66730','96571','49454','18807',
                          '36973','34259','34270','78695','14833',
                          '24932','24340','99663','31500','44494',
                          '47828','39215','73626','26988','17137',
                          '67591','87170','42754','97157','57730',
                          '27240','97949','18024','45550','31665',
                          '83387','49796','61624','42240','25280',
                          '33135','64594','19888','82769','88696',
                          '49873','98062','97350','18747','78954',
                          '43651','86754','46069','15465','10046',
                          '24737','51603','18311','14367','97279',
                          '29571','51658','57314','18385','82226',
                          '19604','46449','72036','39753','23671',
                          '80593','42409','83815','68047','83300',
                          '45728','90782','92034','93193','45492',
                          '48083','11768','26977','44575','94508',
                          '23867','30578','86561','77378','66382',
                          '82481','98667','49150','10968','59160',
                          '77842','10972','37824','99962','55268',
                          '80850','69774','45369','50725','27673',
                          '84962','85699','89692','63432','54517',
                          '95286','37654','44153','43503','19060',
                          '55984','44663','33837','10429','19107',
                          '70850','95212','21929','99707','37253',
                          '95591','50888','99495','58406','15643',
                          '79687','37067','98210','80908','35761',
                          '86908','29032','30783','88028','10614',
                          '77915','62959','91186','36836','19802',
                          '78122','62235','59775','73864','62451',
                          '90353','96804','30302','91732','75016',
                          '44860','71466','95863','93696','23079',
                          '96679','26974','13719','82781','59303',
                          '75484','53585','74438','60516','13482',
                          '15386','34003','87814','14733','31406',
                          '73047','51134','50156','17828','75887',
                          '63817','15387','64092','87456','88905',
                          '87124','61654','28590','84859','93256',
                          '16088','49895','25353','71564','27046',
                          '65091','88654','93174','74325','21496',
                          '25774','56336','81951','43742','95138',
                          '82243','35845','30660','38540','15766',
                          '82940','39804','68038','26053','78783',
                          '84926','63097','73029','55866')
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
  and d_qoy = 2 and d_year = 1999
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;
