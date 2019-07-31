-- start query 8 in stream 12 using template query8.tpl
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
                          '83650','94096','62818','82367','93265','73996',
                          '12701','81166','63525','40730','49885',
                          '95476','30698','68214','81583','82059',
                          '33760','13576','41616','46609','49986',
                          '28098','42378','29801','43527','43562',
                          '67354','52151','93626','54014','33643',
                          '33747','76620','88829','23879','80712',
                          '10254','36177','18089','22847','58994',
                          '26935','38088','70967','63167','53958',
                          '95981','98671','80112','88061','92651',
                          '77084','88433','77021','91007','63094',
                          '25126','44714','96623','73869','61777',
                          '29502','95961','17557','87494','12299',
                          '75103','90198','60348','76703','79981',
                          '99495','47034','95432','90214','38545',
                          '12449','54633','20437','17313','40337',
                          '56178','47628','14023','57246','37966',
                          '46760','99893','31888','35496','22558',
                          '78874','78715','28684','98846','43404',
                          '29857','74121','88070','95802','65371',
                          '58164','21392','60247','99632','66006',
                          '87718','94978','24784','41798','30032',
                          '14169','89826','94110','71380','11631',
                          '21974','49793','47758','11216','29008',
                          '65258','22557','58460','71986','28980',
                          '77962','85960','16758','41177','36681',
                          '58552','94084','95046','93004','34487',
                          '22823','13173','77912','19505','19721',
                          '13235','56763','45243','25370','11754',
                          '15935','62962','19094','13068','40360',
                          '24458','63940','63533','63522','65204',
                          '26757','47599','79729','33941','82883',
                          '71639','92551','92578','93749','65322',
                          '38641','24290','27584','72995','23313',
                          '60516','88478','66335','82888','37591',
                          '84348','45817','48493','91465','80089',
                          '60769','93194','46446','66924','65568',
                          '50579','75398','40289','87617','55242',
                          '34008','77831','54461','52208','24022',
                          '23150','66398','98288','48416','38051',
                          '78314','90352','34579','28111','55440',
                          '71732','70188','96845','97299','20025',
                          '78680','49515','72254','56151','95181',
                          '55714','47415','62989','83462','85587',
                          '56748','69893','86298','64392','90318',
                          '82936','77266','30944','26719','54982',
                          '39088','52050','34246','85524','99994',
                          '61211','87362','43491','32598','91851',
                          '71743','34245','16352','71868','27883',
                          '12527','16199','92773','33003','81846',
                          '90679','36305','79550','53543','91720',
                          '63867','48831','98076','29967','78938',
                          '37113','71917','66653','42862','54984',
                          '49927','36209','41383','24859','80403',
                          '24675','36084','84026','31429','44725',
                          '76042','93726','64723','85181','75957',
                          '11833','64370','50474','75512','95241',
                          '97545','10630','94736','37552','97049',
                          '30154','21814','30371','19676','62345',
                          '55761','63766','46687','64995','69686',
                          '31583','73616','69568','24740','75399',
                          '59172','77909','54760','67571','30119',
                          '76249','62865','76814','65718','13335',
                          '87979','50526','71892','23176','75541',
                          '72551','37247','57681','65146','69215',
                          '11720','29021','79354','47529','30365',
                          '66841','28206','47653','22122','26404',
                          '22242','16841','56111','72062','54847',
                          '47289','83402','97554','82348','77351',
                          '25323','25419','10244','72561','66276',
                          '73999','60565','13261','46096','94522',
                          '99423','24488','74637','59796','67290',
                          '89923','51370','53174','59952','93724',
                          '81489','44320','86961','18367','19020',
                          '72415','10457','63048','85531','82746',
                          '23647','91715','91073','36520','95628',
                          '55508','10542','22405','60617','88130',
                          '55856','84008','70430','34277','41683',
                          '33601','70403','10625','31230','46874',
                          '53793','92727','80516','17821')
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
  and d_qoy = 2 and d_year = 1998
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;
