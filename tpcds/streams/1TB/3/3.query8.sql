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
                          '19337','81978','85306','93983','29954','24196',
                          '41501','61470','59060','51595','48218',
                          '69715','64216','85430','25874','98964',
                          '73874','32011','44228','13249','64214',
                          '19059','75753','45568','76847','91542',
                          '13288','91881','34388','63438','59579',
                          '60560','69880','70182','55262','96617',
                          '95571','28096','82336','68857','10070',
                          '26478','47125','37572','46742','99506',
                          '24310','98322','29652','58345','93886',
                          '20819','28893','99414','22852','20975',
                          '56279','41503','39133','63640','15693',
                          '83273','48232','22759','20207','66584',
                          '67722','45799','23913','68159','89368',
                          '50821','38242','71605','83363','10803',
                          '60736','56611','85048','91491','97350',
                          '77531','29073','32218','32633','41810',
                          '52203','93512','45489','98577','76793',
                          '83107','62366','72354','63643','26410',
                          '42819','27864','51201','89128','88187',
                          '40876','96533','12656','70002','75787',
                          '82618','33944','14019','73187','46012',
                          '88566','68740','49719','82520','26821',
                          '86365','48578','87133','61996','70923',
                          '78870','58773','41688','49111','57872',
                          '73852','10628','88514','91654','14786',
                          '12860','79515','98021','49173','52058',
                          '23037','61345','50043','36644','76433',
                          '88497','34065','63908','63230','26058',
                          '22139','17369','40100','16281','47395',
                          '31129','46859','29587','75579','14474',
                          '31983','12570','31366','15863','67988',
                          '45185','79566','76370','70553','78497',
                          '61126','24646','84209','69454','29908',
                          '13382','95356','89518','76956','15557',
                          '50683','35007','85960','32162','67447',
                          '35180','79254','12971','22750','13107',
                          '99715','83563','99630','32078','90697',
                          '73607','73651','96877','24573','19753',
                          '80624','15706','28116','85374','58195',
                          '53648','72929','44073','45267','60352',
                          '21986','53839','69172','45293','29322',
                          '92928','52158','77866','88489','51026',
                          '35917','70534','86143','62782','70744',
                          '95613','97152','57362','26773','50549',
                          '14979','40866','14644','25204','11496',
                          '63156','68071','94815','43021','57389',
                          '16144','95792','89290','81307','31402',
                          '72712','21272','67693','43054','47374',
                          '37734','57471','30765','55200','31174',
                          '27522','71053','67950','36496','55477',
                          '80530','87239','65132','98287','87127',
                          '61818','65718','68221','76317','19017',
                          '53758','16888','59755','51647','39277',
                          '81564','10481','58837','32819','16901',
                          '94207','73670','89622','80551','15216',
                          '39837','34452','78327','18018','98009',
                          '50421','60213','12396','58959','86676',
                          '63160','14223','36806','74184','66313',
                          '21631','50178','99273','88538','99382',
                          '55342','12722','74192','81205','59285',
                          '95793','97387','93382','32222','13046',
                          '71558','56590','41579','13517','20371',
                          '83501','90919','51405','43558','66061',
                          '43223','52633','32617','89129','72927',
                          '96802','14590','38119','54977','16240',
                          '36169','20317','41706','26828','88682',
                          '58410','85969','80009','36670','61391',
                          '34772','60211','45918','80380','45031',
                          '13198','77048','84668','87590','32457',
                          '68240','51414','51685','12357','45233',
                          '81776','30112','72700','29269','24107',
                          '61555','70370','17911','61998','37761',
                          '52259','22684','65547','44733','71336',
                          '10212','55198','73859','36221','52433',
                          '80196','63078','17724','30306','72573',
                          '61483','78962','55536','15899','48480',
                          '78881','13506','72576','58438','38552',
                          '54762','92078','42157','35315','94981',
                          '68064','70565','90317','37772')
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
  and d_qoy = 1 and d_year = 2002
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;

