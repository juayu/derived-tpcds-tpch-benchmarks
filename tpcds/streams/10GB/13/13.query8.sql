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
                          '93496','34084','71925','37808','32608','44812',
                          '21382','61022','44069','84534','52874',
                          '48263','84178','70848','14402','15651',
                          '20710','82058','72462','68628','37592',
                          '57822','93005','28801','21715','11296',
                          '24812','46439','58570','77082','49284',
                          '77753','22246','66601','22637','55877',
                          '63401','74999','79367','88219','10126',
                          '46694','94723','76541','10578','72262',
                          '84303','70656','87719','76459','19079',
                          '44047','96946','78898','57012','20309',
                          '68787','66927','25348','38391','46924',
                          '32786','20271','10355','66224','72894',
                          '36450','12820','92432','96678','63437',
                          '91170','61195','30912','61355','14573',
                          '26865','68885','12788','34734','37617',
                          '57685','11843','57132','14431','66875',
                          '51744','67582','98846','64226','45749',
                          '40915','61596','94645','11924','50051',
                          '38432','18411','89534','48614','36680',
                          '36580','53825','61873','20518','77812',
                          '48372','64695','28375','13115','15024',
                          '46153','22778','89211','27324','84059',
                          '20284','77582','51600','32477','20439',
                          '63240','39806','66076','26366','80988',
                          '18773','31620','55849','81308','42384',
                          '16566','49175','17450','72864','36960',
                          '49506','81658','70988','37771','36774',
                          '45975','51362','74519','59666','89809',
                          '20893','81287','88246','57111','72777',
                          '24528','54514','56464','86299','96898',
                          '92738','46073','71721','64133','51757',
                          '68447','15178','12295','45656','13263',
                          '22031','32850','46178','62244','51580',
                          '24368','49844','39071','35101','89502',
                          '27061','16542','63662','87353','26262',
                          '44476','78665','51313','65984','22931',
                          '82075','49524','70068','17210','77294',
                          '69294','72114','58341','92523','80662',
                          '55662','81260','27523','63603','55605',
                          '80705','19390','93924','66660','47261',
                          '56113','39377','63465','24585','51400',
                          '78948','58069','99194','22674','30588',
                          '51155','34127','81098','27580','42606',
                          '16828','74590','96688','14103','95400',
                          '80454','22511','93395','98253','95006',
                          '25312','40233','43017','31708','90928',
                          '15787','60326','70882','48688','88963',
                          '13533','33530','51175','79167','53460',
                          '75323','53917','45091','41725','43574',
                          '73305','18467','56270','50491','50140',
                          '75936','71981','47338','53593','62022',
                          '74244','53465','15194','45337','60106',
                          '46993','43857','28525','56461','49306',
                          '65090','47613','42468','77786','70599',
                          '85681','38532','78041','74385','79363',
                          '95820','18999','18400','96009','68406',
                          '61897','78319','54764','24187','53216',
                          '87666','45324','50126','84866','88070',
                          '29963','78049','44749','78455','10428',
                          '67204','75632','85881','81749','76874',
                          '42438','86640','51583','28547','24060',
                          '44757','53722','28460','75979','35334',
                          '98583','53207','81087','33405','88255',
                          '65588','90696','51975','74511','72355',
                          '31504','51152','20368','35947','46546',
                          '56629','68373','77492','78326','41786',
                          '27895','66198','61407','55089','35657',
                          '61088','73409','74263','89625','33514',
                          '14375','20265','25408','77300','15815',
                          '47367','66657','46078','10093','25255',
                          '77944','34421','96994','13178','74208',
                          '25783','93639','11509','20177','73105',
                          '93661','84540','19982','58557','74510',
                          '17142','50442','36225','84806','74282',
                          '64464','83969','31342','81443','61817',
                          '18355','57571','95097','41948','36154',
                          '57895','28139','56455','54767','29149',
                          '82803','92917','59431','56916','58997',
                          '88969','28865','83600','35185')
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

