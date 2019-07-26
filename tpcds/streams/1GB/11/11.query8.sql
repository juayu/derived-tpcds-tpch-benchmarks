-- start query 8 in stream 11 using template query8.tpl
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
                          '34912','72151','24937','68772','47409','46500',
                          '91809','62554','89835','46957','42757',
                          '39468','51368','14598','31935','52104',
                          '92458','96325','13319','42360','49278',
                          '96543','30770','24805','23989','59341',
                          '68930','74099','32920','89288','15416',
                          '53760','75952','44575','23995','29028',
                          '30616','43559','86927','81749','78366',
                          '93324','99363','94070','80110','88650',
                          '83819','36066','72722','93045','78819',
                          '24545','72778','50867','45444','74093',
                          '69204','59256','60487','59962','51411',
                          '25742','92735','24328','69650','28293',
                          '49941','11148','83205','57082','52187',
                          '85752','20026','80677','40184','51936',
                          '87086','95753','29084','75580','62309',
                          '98924','84049','70514','86534','88313',
                          '68927','27408','97311','28904','62840',
                          '58528','60981','86143','14142','59389',
                          '81335','18509','17238','59166','22646',
                          '64446','87055','56831','75098','21853',
                          '66823','99082','17856','76384','52189',
                          '41352','98079','37914','44240','40597',
                          '68457','27064','85759','91174','27181',
                          '15728','98914','81204','93772','21825',
                          '17895','51631','32673','63642','12454',
                          '69057','86160','94508','41303','21596',
                          '80222','56184','82922','90464','73747',
                          '49148','93443','40044','44517','98798',
                          '37599','57063','37908','42442','19535',
                          '14672','87162','80994','49691','47918',
                          '53745','58382','93559','31840','94340',
                          '79066','86895','72329','95224','68586',
                          '37278','53951','77564','16765','38112',
                          '70401','69784','56477','61021','84827',
                          '43082','16974','38747','54778','92728',
                          '96404','34612','89340','47323','79331',
                          '29760','31422','54481','34910','96222',
                          '56570','15141','78068','47496','24718',
                          '67185','77983','97653','49323','28583',
                          '83269','73523','78322','14499','78327',
                          '64477','89236','91720','15808','77256',
                          '52194','89183','43682','76397','63475',
                          '12753','73404','36001','39940','96083',
                          '11332','32426','73357','98123','72152',
                          '40539','18261','31828','47087','74393',
                          '59278','24902','74868','86402','63132',
                          '45916','27984','21177','30710','18489',
                          '21052','65426','89234','81009','59641',
                          '74627','77381','14955','55812','18206',
                          '24201','20180','76533','81898','37465',
                          '76826','56232','91359','64452','62266',
                          '80356','88938','32595','25551','14824',
                          '96167','53818','65143','78055','49782',
                          '94719','56641','40160','85998','49909',
                          '73773','77547','62826','77802','71415',
                          '50113','33324','51756','40087','96157',
                          '73128','34738','73703','33259','81613',
                          '25014','88602','76097','22339','99744',
                          '52336','47762','72437','19412','56623',
                          '13175','37152','44726','41834','89458',
                          '92265','55885','48219','97862','55427',
                          '86997','48584','19420','64996','57616',
                          '85303','99824','97906','32304','50378',
                          '53267','60932','69900','91462','25812',
                          '21695','61786','48012','12967','95086',
                          '23979','42615','71299','26118','68038',
                          '93987','45907','65919','60312','51718',
                          '30990','55197','43010','48176','88103',
                          '62099','63892','17370','29960','15791',
                          '60176','89837','59074','58620','55191',
                          '17492','66473','79171','54510','29195',
                          '80347','86422','46339','21264','36764',
                          '93358','27709','89884','29420','57347',
                          '26074','68421','47020','76027','69242',
                          '15485','35199','86385','71146','54123',
                          '88453','41625','29736','62828','44083',
                          '83967','53222','67989','46937','59205',
                          '51047','31469','62793','24662','12154',
                          '46545','19891','58614','31130')
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

