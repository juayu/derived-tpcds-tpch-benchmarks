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
                          '34891','18608','28340','83881','75317','31719',
                          '57233','26990','79868','37622','38141',
                          '52297','75517','53692','98028','46631',
                          '30733','40621','16146','61181','42790',
                          '55495','35835','56718','44494','45267',
                          '86648','75277','52579','54289','62458',
                          '24801','37530','14254','76463','15430',
                          '12200','84240','73704','45742','79751',
                          '65035','55633','17876','84155','42383',
                          '54894','74537','83414','74625','47185',
                          '99982','82129','10244','59653','18229',
                          '56447','32395','81613','89790','60070',
                          '51730','26979','74238','11573','74694',
                          '40014','55163','14282','33974','79409',
                          '42040','20647','61537','85580','12919',
                          '69431','18675','66331','58564','17569',
                          '98432','59624','55922','79292','95124',
                          '96260','55164','44988','13799','67538',
                          '87069','81624','62756','98027','54638',
                          '90942','70723','29988','38975','99775',
                          '72755','38115','55332','40596','11900',
                          '29627','52307','13794','98559','72834',
                          '42994','24979','40992','58154','58452',
                          '26170','86632','12113','58849','17640',
                          '84159','58203','40314','19221','74236',
                          '21378','10867','30059','45540','90034',
                          '79594','35943','15092','79207','72885',
                          '79050','79468','93180','45179','85292',
                          '86742','19652','98009','26695','51453',
                          '16973','51384','50428','49560','59512',
                          '77952','49821','44308','89680','68996',
                          '51606','83817','10822','15091','57090',
                          '99192','66279','92543','51778','74677',
                          '89345','44935','81197','71187','42210',
                          '99379','96982','40449','86142','96494',
                          '83921','72678','11111','99429','57771',
                          '96598','23218','61530','39491','37620',
                          '63301','32429','61152','36360','41613',
                          '80286','49643','58406','10732','86877',
                          '23998','95900','68651','96113','76943',
                          '71492','57085','62408','71937','25056',
                          '67822','78102','66878','32589','73487',
                          '68327','39669','46433','75806','24851',
                          '66067','12942','86687','48208','75511',
                          '27141','52442','63600','92137','98264',
                          '89705','17825','80627','46835','51748',
                          '12776','29657','17510','50627','19523',
                          '64887','56340','26078','17695','80407',
                          '48165','60263','37125','78775','30283',
                          '34924','82368','77638','22635','93528',
                          '43702','68956','97332','77077','64456',
                          '21255','95747','11165','15814','22139',
                          '91194','31712','20914','16159','90143',
                          '36565','81291','56861','65259','60184',
                          '46150','79635','67975','68584','52066',
                          '69106','72365','70714','64444','53074',
                          '33280','99160','35742','14544','43498',
                          '82532','23946','16591','53390','27407',
                          '30173','53063','34420','13098','40304',
                          '56283','74022','43727','47492','31495',
                          '15439','70974','46212','95324','39682',
                          '75645','84477','38780','73904','94583',
                          '93458','28452','22502','45700','27805',
                          '70170','48040','91617','39783','53053',
                          '34450','50136','37666','53209','80021',
                          '16560','13709','36246','84830','81958',
                          '21513','59736','96100','97286','21074',
                          '16544','69497','91969','68073','90889',
                          '78984','91509','15551','97801','68374',
                          '82884','11950','20552','87661','48372',
                          '41861','59040','38684','40456','15655',
                          '17780','38031','51188','44371','72299',
                          '99922','27589','31307','45890','87550',
                          '27430','91588','11106','59263','95821',
                          '44781','82338','83843','30245','29480',
                          '65773','61296','70866','77821','99750',
                          '61947','61816','34107','25414','55121',
                          '15802','32689','80640','75292','99588',
                          '75368','11220','62992','66805','42228',
                          '90465','67391','29166','98786')
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
  and d_qoy = 1 and d_year = 1998
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;

