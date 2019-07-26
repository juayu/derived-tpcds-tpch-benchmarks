-- start query 8 in stream 14 using template query8.tpl
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
                          '37454','98014','29264','96170','68929','37333',
                          '54521','89437','26222','94964','26883',
                          '27155','55180','55654','58313','70970',
                          '38418','84706','82997','45050','88587',
                          '65309','77990','53933','58432','54375',
                          '31183','24597','96059','65123','84763',
                          '17257','50905','85446','57566','30505',
                          '18799','43694','16212','82171','99827',
                          '39640','76430','50792','31428','91004',
                          '35942','63759','57231','35538','24704',
                          '21383','99009','28049','62781','46792',
                          '27598','47580','92619','58109','38217',
                          '74828','46850','84247','39457','62605',
                          '79798','69201','31882','23923','14703',
                          '35357','56494','81040','48484','61050',
                          '78659','88688','14823','41515','51350',
                          '69491','49986','82258','98470','85344',
                          '55444','45720','97358','31345','96362',
                          '61058','26859','35017','79591','69470',
                          '68302','83736','49238','46221','92869',
                          '17117','90524','47111','41787','88829',
                          '14903','57702','14838','30644','87421',
                          '26117','31556','94058','78252','51273',
                          '99615','11421','99361','46617','12430',
                          '43607','50307','19446','17034','97405',
                          '68895','76448','10814','58783','79535',
                          '44790','61638','72822','98211','98578',
                          '95434','32322','80149','35530','52648',
                          '77614','11758','56203','62237','62674',
                          '79573','80829','62917','53681','13982',
                          '49122','20623','50563','77309','61188',
                          '16417','73791','19038','83780','70895',
                          '58772','82419','40445','51974','47638',
                          '41658','19703','26122','51862','16801',
                          '21381','61154','68665','27713','39889',
                          '62751','95277','58707','89889','46098',
                          '54388','68298','20994','12880','34044',
                          '82214','22059','74427','74988','19592',
                          '64097','93889','71761','46113','14992',
                          '53771','46555','25321','18851','80201',
                          '95651','15461','79700','24907','10956',
                          '70862','40042','51894','86263','70007',
                          '94868','90009','88987','10696','18870',
                          '47329','54398','46931','59184','28703',
                          '87590','64473','10686','35752','73226',
                          '98245','56268','56801','63775','10689',
                          '23929','61198','97010','74815','91902',
                          '10540','53650','95792','72201','48521',
                          '40940','58039','80619','61463','67101',
                          '34273','77587','12562','38906','45982',
                          '11885','99503','56141','28064','42836',
                          '55163','99123','72459','27043','13457',
                          '85470','32806','62253','60691','83832',
                          '36008','59403','21553','36927','28110',
                          '14002','49376','89348','16639','84903',
                          '55836','12907','32885','56309','58401',
                          '51886','43032','96732','56219','42518',
                          '43576','95696','91251','46028','46527',
                          '93168','37458','10474','59221','88210',
                          '63994','61103','26684','88429','90320',
                          '80246','83283','24262','11288','16749',
                          '93547','36676','24470','75258','91707',
                          '51943','79943','45509','59173','84165',
                          '41939','53335','98921','38167','81226',
                          '86397','96139','34700','15671','22372',
                          '90058','47518','61422','77040','45184',
                          '38856','25801','51055','78811','50576',
                          '47574','72399','54153','82986','65744',
                          '81109','82941','59392','89121','12022',
                          '49575','94241','16421','49481','37936',
                          '70880','11507','10620','36496','43962',
                          '80778','46611','44898','67605','42845',
                          '31816','88489','10259','73520','62290',
                          '68917','65275','13408','38237','72006',
                          '25152','93113','54605','67689','67943',
                          '28697','24714','15018','64034','55979',
                          '15684','46726','86519','12560','99029',
                          '78513','29203','98660','88528','80916',
                          '12996','26233','57603','64282','31436',
                          '98321','95347','97233','41504')
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

