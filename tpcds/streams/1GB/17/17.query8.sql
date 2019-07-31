-- start query 8 in stream 17 using template query8.tpl
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
                          '41155','10811','97597','53040','99158','14293',
                          '32900','42155','45220','88012','71722',
                          '58378','97774','54122','15185','75784',
                          '75953','21127','58981','81779','94753',
                          '70440','40510','58936','83747','15633',
                          '91555','40709','84585','23557','15441',
                          '89559','76341','13313','72919','13658',
                          '86590','30335','22977','24160','47099',
                          '92300','12842','58998','42755','73863',
                          '40648','74195','50863','34712','12966',
                          '96273','52118','28518','74019','24693',
                          '65007','83023','30984','21120','88858',
                          '21116','40941','29928','39528','22993',
                          '34135','30277','51507','30678','13446',
                          '92290','58621','25582','47794','85823',
                          '46231','92238','59326','84968','98390',
                          '98731','53644','18883','82916','33592',
                          '89532','67330','60036','76403','82536',
                          '28092','88420','85251','15911','45110',
                          '28568','30631','47286','86658','53044',
                          '20473','19108','37470','37667','65723',
                          '72833','51840','78291','79681','60634',
                          '52712','88555','12224','69119','97148',
                          '91866','85250','96793','85064','60070',
                          '55426','38354','42715','31445','93035',
                          '79697','83152','35663','35526','46997',
                          '53337','83755','34174','51985','16399',
                          '56585','28112','77083','34311','59496',
                          '61342','43177','89613','35093','95658',
                          '68936','30147','73580','80499','37077',
                          '66779','21782','59699','73467','16010',
                          '51425','69250','73548','12905','25807',
                          '16347','80750','26258','92126','94127',
                          '51611','97539','12064','46059','33823',
                          '91573','22012','15391','52436','40390',
                          '38436','35352','49295','10579','98814',
                          '96632','49313','61820','80927','16517',
                          '78103','12377','90698','85944','64512',
                          '51111','94116','10466','58522','98992',
                          '11819','82949','44518','96296','90719',
                          '63527','96029','53426','37961','36260',
                          '43312','19754','30873','13827','80822',
                          '50269','72574','37267','84911','88247',
                          '70216','46276','83246','13181','42890',
                          '69066','72731','31101','90690','43989',
                          '49848','82192','78445','92440','51554',
                          '43085','11353','51443','15513','59371',
                          '70975','56755','33179','79733','58496',
                          '21683','21441','94702','77605','80596',
                          '88481','12487','25683','10432','11678',
                          '59904','79089','41245','67131','38149',
                          '58544','27183','83816','48830','77368',
                          '65488','87370','50883','32823','11905',
                          '55155','27285','32554','16537','73502',
                          '42795','28028','86507','40831','52165',
                          '62992','34275','47500','30336','79209',
                          '74013','33784','55280','65137','68170',
                          '74595','77471','36061','12303','70284',
                          '68752','49175','74412','53964','74942',
                          '85657','71746','97159','37181','64929',
                          '30816','83837','17746','23971','41537',
                          '38277','69845','38615','83225','43998',
                          '63264','55617','66640','89594','87481',
                          '37837','29319','80858','85685','84285',
                          '85597','94381','85774','56525','50046',
                          '84511','46043','84971','33045','86505',
                          '70314','64809','89243','33881','43260',
                          '20479','91902','24472','88574','24264',
                          '20298','89114','20076','67434','68862',
                          '22978','58355','87201','39120','26667',
                          '95693','63269','39694','98344','72260',
                          '24713','42494','70079','23437','76323',
                          '24462','84866','72021','26040','79572',
                          '10048','87666','67016','18121','96779',
                          '59064','26875','28684','65367','32045',
                          '40341','81086','92980','54545','27672',
                          '90465','46418','39666','26534','27339',
                          '26844','90424','12725','81956','44803',
                          '90529','63993','61219','30370','89160',
                          '81538','10358','72934','12068')
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
