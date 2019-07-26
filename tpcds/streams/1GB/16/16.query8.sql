-- start query 8 in stream 16 using template query8.tpl
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
                          '19022','12802','39684','48454','56092','34020',
                          '36413','96303','86265','59800','44541',
                          '89204','35372','26374','84675','97993',
                          '71197','49538','74080','14992','95506',
                          '35446','93037','96718','70262','12878',
                          '86513','13620','92542','25963','96621',
                          '63980','53536','36380','35345','59385',
                          '77646','74288','21741','25491','73838',
                          '78841','46939','72951','77393','29140',
                          '82803','44114','10682','29909','90560',
                          '99545','70012','63728','87821','84746',
                          '53840','50055','46941','21264','56172',
                          '87753','70654','50154','16449','41934',
                          '47288','78920','24818','48101','39599',
                          '82034','93300','49390','40091','38072',
                          '58160','38035','64772','23314','62251',
                          '45253','46860','22580','32979','99517',
                          '77196','33453','86181','33712','16988',
                          '39051','13405','92073','67968','67008',
                          '11027','72744','79582','93012','39808',
                          '68853','58341','18508','14298','15079',
                          '69356','23219','95826','58198','61022',
                          '37616','18395','94174','32512','66850',
                          '89962','72404','15902','65433','65212',
                          '26143','57481','41252','12365','95650',
                          '77411','10312','26908','47339','66385',
                          '17323','51073','20242','88318','36706',
                          '62389','33828','35747','49169','73795',
                          '43962','46184','54482','60075','33391',
                          '78855','68627','61284','56365','11242',
                          '11666','74809','24015','20455','69947',
                          '56218','47075','40360','52897','94599',
                          '58905','93860','83370','48322','94364',
                          '50943','33655','63598','82962','71693',
                          '11147','45000','33566','52919','93417',
                          '57859','27717','23355','74897','84518',
                          '75471','65359','51390','29669','68767',
                          '28645','95981','60394','83590','47022',
                          '94293','36796','40634','57857','93328',
                          '17829','66290','49744','32010','66237',
                          '95164','21141','56552','93295','85405',
                          '23463','61052','46587','27482','35586',
                          '92395','22621','25571','40745','66084',
                          '90841','77743','77545','42191','46426',
                          '96675','92861','38333','96732','54107',
                          '48017','98653','44087','58677','79375',
                          '75647','91883','39716','74186','43123',
                          '58390','35792','55982','68694','70329',
                          '84687','25773','87990','59160','69865',
                          '21709','33500','11384','73166','97965',
                          '36058','38190','20898','93507','10689',
                          '28872','61606','42982','18876','45626',
                          '28043','90880','50763','66226','28047',
                          '56105','82638','90279','65545','16728',
                          '94158','73209','75335','22357','69199',
                          '20160','86900','62261','33525','88552',
                          '95139','27478','61822','21038','80231',
                          '35441','19726','59164','43931','35666',
                          '28731','18956','80266','84951','38583',
                          '10942','67283','56684','37888','91834',
                          '35363','48028','52425','43035','68169',
                          '60942','26607','22027','94247','66670',
                          '20641','47321','63704','84346','59644',
                          '42622','52017','78195','92583','24648',
                          '76174','50597','29414','75850','45317',
                          '66208','88047','57618','59600','75640',
                          '66179','42055','20150','83732','48298',
                          '20863','71303','82458','88730','54740',
                          '89626','96731','31765','45146','70953',
                          '77588','13424','27153','28843','46827',
                          '43462','37728','54956','39172','14247',
                          '65662','44807','18905','15311','33215',
                          '31119','23796','80876','96464','91560',
                          '57591','99025','91815','93316','18886',
                          '49095','16340','55246','97402','16695',
                          '88096','69106','56203','52953','11590',
                          '37845','96689','63829','53436','68987',
                          '61190','37458','89820','51560','35171',
                          '76361','59217','28080','52053','71360',
                          '26532','55284','29327','44342')
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

