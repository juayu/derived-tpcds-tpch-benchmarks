-- start query 8 in stream 7 using template query8.tpl
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
                          '98589','17334','15505','98451','76512','89043',
                          '80572','48013','65018','93772','93336',
                          '88118','59432','95873','62968','16257',
                          '71363','72673','42137','38777','12434',
                          '13755','15476','57739','78103','88122',
                          '71596','46136','21694','15208','44241',
                          '76783','90865','66938','46773','66491',
                          '86957','20272','13618','74920','41880',
                          '46386','99965','92966','38324','33792',
                          '39771','98136','83559','80615','84501',
                          '99120','19392','82176','58608','48448',
                          '54675','99284','21832','91535','21730',
                          '81312','20635','75506','56839','61834',
                          '64663','39722','86385','40878','31203',
                          '40503','77950','12106','16188','88313',
                          '20261','71994','45907','34923','59305',
                          '16622','70929','50647','57953','74728',
                          '29462','95619','98229','66342','82403',
                          '27369','99908','95774','32857','21901',
                          '89000','78993','58953','49174','75914',
                          '42404','68865','18646','50728','23537',
                          '61554','23176','50861','55023','55736',
                          '65300','16366','44012','81327','98249',
                          '53743','93824','37312','93528','43395',
                          '47718','97968','75906','96625','22465',
                          '81178','84929','40912','47052','42533',
                          '31343','45945','48372','38747','75537',
                          '49155','79926','24480','95265','48151',
                          '97572','92323','33180','59112','93020',
                          '94540','96366','39381','30558','75814',
                          '91178','11130','30295','88996','14473',
                          '86411','29457','67332','85016','69680',
                          '46182','32106','23071','14556','78701',
                          '34257','28528','17727','74292','66711',
                          '92305','22173','69875','92907','68898',
                          '28532','38686','92518','66961','29111',
                          '66375','54894','97644','24351','16741',
                          '33236','26569','16575','96494','86154',
                          '58915','55554','65147','77307','77149',
                          '95473','19400','19694','56761','14036',
                          '49909','26764','62463','10307','63797',
                          '49199','79011','15160','68230','62229',
                          '67740','27464','31796','35453','48362',
                          '90798','94067','21943','55233','46737',
                          '54231','54541','25918','22641','43616',
                          '67511','97585','92447','50191','52354',
                          '21237','67014','70824','45667','46057',
                          '96827','31806','80556','23113','16304',
                          '23180','11050','45638','51180','37486',
                          '87877','56051','87118','60908','79834',
                          '58010','36686','98921','59117','63393',
                          '21062','79989','69876','29233','21823',
                          '54800','16574','73408','80718','88441',
                          '75879','73310','35156','25314','10363',
                          '39275','95736','98786','52671','49762',
                          '71375','24265','84789','63145','74162',
                          '32466','33233','40501','81350','34378',
                          '21785','61729','63469','61134','90982',
                          '29503','18293','75637','81774','97257',
                          '74950','97921','48490','38999','25298',
                          '33805','86838','37703','88868','50084',
                          '93498','71139','23681','75395','44335',
                          '51587','88422','58960','52702','62036',
                          '12818','74383','31640','76802','28818',
                          '86984','29372','34025','91474','71978',
                          '84828','59528','34192','64293','40829',
                          '27886','25062','84279','35686','31740',
                          '24336','68522','33615','89810','94391',
                          '13680','50641','70529','88290','45896',
                          '94135','14264','79096','28304','40135',
                          '69838','82140','33737','77599','85171',
                          '42938','78157','87310','63413','63051',
                          '45684','83209','70492','76012','33107',
                          '66766','42731','19890','48553','48367',
                          '76357','45470','14312','91835','78783',
                          '66273','74023','36988','69056','70483',
                          '16703','37591','50625','61859','39920',
                          '52132','62542','15106','70721','48537',
                          '64107','47319','43476','56647','67658',
                          '52115','31961','59287','59107')
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

