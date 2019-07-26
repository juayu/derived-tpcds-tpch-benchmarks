-- start query 8 in stream 2 using template query8.tpl
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
                          '51622','98000','91690','36202','97315','89665',
                          '86050','73316','61343','63693','72955',
                          '72112','51269','42203','78790','16434',
                          '11264','26133','74987','84562','61168',
                          '21777','76913','97001','63504','68675',
                          '87126','35366','34276','94483','67430',
                          '77554','25111','81058','97269','90944',
                          '70435','47038','52178','67131','66020',
                          '89359','45872','51026','86459','39026',
                          '88926','10642','84913','39955','64951',
                          '24040','15234','82991','14352','87662',
                          '61084','72090','26324','94595','67943',
                          '48183','71719','79963','74917','33045',
                          '51755','74143','29404','45495','29326',
                          '50271','53908','41769','57849','17349',
                          '80992','27321','26180','38085','62557',
                          '54386','78986','86125','38342','96292',
                          '57792','65079','48125','89372','12246',
                          '84960','57435','29128','65061','32218',
                          '67960','65725','95121','78813','29581',
                          '55123','56252','30323','91101','21727',
                          '16031','43901','83198','21771','34506',
                          '46313','99531','38889','57604','73963',
                          '49847','13180','13875','73026','44601',
                          '38397','56627','18926','45638','22006',
                          '64144','24497','31281','95338','96912',
                          '62725','78198','69656','38798','15759',
                          '14259','14802','70133','47094','91996',
                          '33095','78293','85321','57236','15895',
                          '67334','99964','39379','42339','29593',
                          '72371','90910','30530','45230','20641',
                          '20866','55949','52955','81814','12832',
                          '82453','56613','32362','73036','80380',
                          '44119','81896','91784','29629','42674',
                          '67464','63513','55705','13392','48177',
                          '97224','79463','97340','29507','61101',
                          '41849','10663','72345','21899','17638',
                          '49956','63675','87440','26832','78045',
                          '26355','25006','43397','37029','41333',
                          '75652','71062','25788','62406','46306',
                          '63972','28781','50570','69104','33789',
                          '74860','71653','39086','85678','56477',
                          '21769','67493','82687','23829','74885',
                          '27377','96632','99403','62403','86750',
                          '12940','15781','77416','79397','52146',
                          '29209','70574','80983','67528','52163',
                          '32794','84048','28118','39998','82595',
                          '99098','71108','55538','91421','41805',
                          '92210','13536','10934','16965','30832',
                          '68266','47998','71487','10279','96945',
                          '42248','28666','53621','34461','63868',
                          '27388','32449','43484','57424','49153',
                          '48488','36798','57471','18842','42396',
                          '13722','74745','22891','35839','72256',
                          '21937','38487','71996','34624','32711',
                          '94151','65069','37641','58649','48474',
                          '13265','74089','12136','49864','83832',
                          '11271','79038','67965','94369','41295',
                          '19338','41494','67997','61686','25598',
                          '45306','10003','98643','53552','85017',
                          '73460','59554','81186','67284','13117',
                          '37526','43443','37191','48583','10835',
                          '33340','44859','70068','56433','84125',
                          '45903','39668','14994','17955','71259',
                          '22031','20814','40638','60616','88631',
                          '84615','22576','59041','39793','35660',
                          '48770','19000','88826','85001','66653',
                          '25738','64390','64179','69359','15463',
                          '84531','89804','86051','51461','50622',
                          '86226','20785','28311','33297','27601',
                          '14314','35744','60214','43289','12492',
                          '97140','16362','59487','40828','11121',
                          '59509','57953','53807','54855','24007',
                          '44613','73001','92517','90523','16420',
                          '38466','53178','54248','25108','56305',
                          '63565','54813','19796','25520','11349',
                          '95840','84221','63611','95758','21442',
                          '87003','47382','55542','76160','98473',
                          '59674','28207','90351','95995','49940',
                          '38710','81314','47636','62016')
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
  and d_qoy = 1 and d_year = 1999
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;

