--Dasafio 1_1

/*Importante ressaltar que utilizando um SELECT na cláusula FROM, especifíco um universo mais restrito
para a consulta ao invés de toda a base de dados*/

SELECT CurrName.name, CurrEmail.email,  CurrPhone.phone, Rev.revenue
-- Busca o id e nome 
FROM (  SELECT id, traits.name as name, max(timestamp) timestamp
        FROM `dito-data-scientist-challenge.tracking.dito` 
        WHERE type = 'identify'
        AND traits.name IS NOT NULL
        GROUP BY id, traits.name ) AS CurrName
-- Busca o id e o último e-mail preenchido correspondente
LEFT JOIN (   SELECT EA.id, traits.email as email
              FROM `dito-data-scientist-challenge.tracking.dito` EA
              INNER JOIN (  SELECT id, max(timestamp) LastUpdate
                      FROM `dito-data-scientist-challenge.tracking.dito` 
                      WHERE type = 'identify'
                      AND traits.email IS NOT NULL
                      GROUP BY id
                    ) EB
                ON EA.id = EB.id
                AND EA.timestamp = EB.LastUpdate
              WHERE type = 'identify'
           ) CurrEmail
ON CurrName.id = CurrEmail.id      
-- Busca o id e o último telefone preenchido correspondente    
LEFT JOIN (   SELECT PA.id, traits.phone as phone
              FROM `dito-data-scientist-challenge.tracking.dito` PA
              INNER JOIN (  SELECT id, max(timestamp) LastUpdate
                  FROM `dito-data-scientist-challenge.tracking.dito` 
                  WHERE type = 'identify'
                  AND traits.phone IS NOT NULL
                  GROUP BY id
                  ) PB
                ON PA.id = PB.id
                AND PA.timestamp = PB.LastUpdate
              WHERE type = 'identify'
           ) CurrPhone   
ON CurrName.id = CurrPhone.id
-- Busca o top 5 de clientes que mais geraram receita e relaciona às informações
INNER JOIN (  SELECT id, sum(properties.revenue) revenue
              FROM `dito-data-scientist-challenge.tracking.dito` 
              WHERE type = 'track'
              GROUP BY id
              ORDER BY revenue DESC
              LIMIT 5) Rev
  ON CurrName.Id = Rev.Id    

--Desafio 1_2
/*No SELECT  do from, faço a diferença entre as datas de compra para cada usuário
E por fim calculo a média AVG de todas essas diferenças*/

/*No SELECT  do from, faço a diferença entre as datas de compra para cada usuário
E por fim calculo a mediana de todas essas diferenças*/

SELECT 
          percentile_cont(d.dif,0.5) OVER (partition by d.id) AS median
  FROM (
          -- diferença em dias entre a data da compra e a data da compra anterior, para um mesmo id(usuário)
          SELECT  id,
                  date_diff(CAST(LAG(timestamp) OVER (PARTITION BY id ORDER BY timestamp DESC) AS DATE),CAST(timestamp AS DATE),day) Dif
          FROM `dito-data-scientist-challenge.tracking.dito` 
          WHERE type = 'track'
          ORDER BY id, timestamp
          
  ) D
  
  WHERE D.Dif IS NOT NULL
  group by d.dif,d.id
  limit 1