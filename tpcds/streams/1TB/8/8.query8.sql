-- start query 8 in stream 8 using template query8.tpl
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
                          '22768','21052','74993','84509','20454','46792',
                          '74460','64805','64939','89250','62342',
                          '51388','41124','70926','30517','22635',
                          '34681','31997','32184','60796','43804',
                          '66124','37986','79388','31653','39845',
                          '85365','72109','62943','74508','59043',
                          '30488','85303','93958','60825','14163',
                          '78851','82784','99069','43231','89304',
                          '17817','79127','11398','50611','85701',
                          '79907','28653','78801','57898','83559',
                          '71479','48563','69642','85166','38825',
                          '71956','76762','45659','92013','59925',
                          '30178','37542','20927','40597','20934',
                          '31415','85340','83091','78202','27280',
                          '83520','95189','36552','72551','84500',
                          '11781','70500','25791','91320','99397',
                          '32889','56536','47405','60696','90562',
                          '91139','91834','14430','22697','85167',
                          '19025','27435','42486','66631','19828',
                          '63209','99629','49619','91321','74729',
                          '37369','84777','78723','58712','40787',
                          '48614','47195','93216','58831','16983',
                          '17487','64913','77290','82578','78566',
                          '13336','86562','76043','66289','54583',
                          '78696','16406','42901','94444','17056',
                          '76701','26177','83127','15387','98559',
                          '58067','34694','29837','75405','86013',
                          '27312','30694','86552','76398','64330',
                          '16186','50912','37336','42702','12315',
                          '53198','73877','18854','65314','15521',
                          '98171','87679','48803','80767','33772',
                          '70079','97819','86054','17529','14848',
                          '14581','71958','29027','38155','43119',
                          '21724','17571','98624','95296','65225',
                          '98017','34130','72244','17396','41163',
                          '32166','18321','58588','54087','32027',
                          '86952','48920','94074','42461','55562',
                          '23692','13698','36283','66203','83947',
                          '99576','79940','99164','91944','86415',
                          '11334','26012','61767','52986','32903',
                          '27603','59232','60140','34332','12360',
                          '11181','51991','54475','70846','71838',
                          '75711','68837','24782','77128','17465',
                          '21854','80851','45508','91511','42401',
                          '55463','35035','74454','77107','52813',
                          '58000','77615','87245','56259','12550',
                          '83935','60641','74255','71275','78426',
                          '40513','27542','50622','18823','65430',
                          '29586','81205','45767','45635','85196',
                          '59759','67046','60700','90616','56118',
                          '35681','87600','30795','96222','89398',
                          '76708','31188','56953','17960','84747',
                          '42185','33162','43133','51648','50715',
                          '89550','47542','99045','18075','90622',
                          '88863','21384','55574','35863','56079',
                          '30901','95582','46402','78505','50299',
                          '58312','72547','26466','79826','40115',
                          '46466','81526','70836','89530','86477',
                          '10579','48705','15098','67712','25180',
                          '31055','96877','21067','85516','56412',
                          '84032','38631','95418','84354','91370',
                          '16720','32816','74830','46481','27915',
                          '63924','86387','59209','15183','63861',
                          '99489','62284','84241','41637','51032',
                          '95439','10355','76619','25637','31619',
                          '49431','58782','36299','23860','78217',
                          '12033','66834','58471','44919','23948',
                          '77718','13157','14542','67695','58176',
                          '90879','68074','42929','54976','98725',
                          '93776','26732','89295','27078','88623',
                          '88524','87829','31117','39423','72735',
                          '22487','76255','80432','65622','23465',
                          '41565','71870','52086','31522','52042',
                          '78124','38202','65877','46573','74005',
                          '47711','72540','57637','91267','52265',
                          '28270','23321','48875','98532','81758',
                          '19933','61709','47667','84043','84621',
                          '43380','85664','42812','34589','58503',
                          '38351','84787','73179','55191','21334',
                          '45881','64301','59994','13975')
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

