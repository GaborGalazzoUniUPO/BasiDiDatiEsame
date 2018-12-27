/* Query 11:
Ricavare il primo artista morto dopo Freddie Mercury (il risultato deve contenere il nome dell’artista,
la sua data di nascita e la sua data di morte).
In questa query non è possibile moltiplicare i valori di anno mese ed anno per altri numeri.
*/


SELECT a.name,
       MAKE_DATE(a.end_date_year, a.end_date_month, a.end_date_day)
FROM   artist a,
       artist b
WHERE  MAKE_DATE(a.end_date_year, a.end_date_month, a.end_date_day) >= MAKE_DATE(b.end_date_year, b.end_date_month, b.end_date_day)
       AND b.id = 232732
       AND a.id != b.id
       AND NOT EXISTS (SELECT *
                       FROM   artist c
                       WHERE  MAKE_DATE(c.end_date_year, c.end_date_month, c.end_date_day)
                              BETWEEN
                                MAKE_DATE(b.end_date_year, b.end_date_month, b.end_date_day)
                                AND
                                MAKE_DATE(a.end_date_year, a.end_date_month, a.end_date_day)
                              AND c.id != a.id
                              AND c.id != b.id)
ORDER  BY MAKE_DATE(a.end_date_year, a.end_date_month, a.end_date_day);



/* Query 12:
Elencare le coppie di etichette discografiche che non
hanno mai fatto uscire una release in comune ma hanno
fatto uscire una release in collaborazione con una medesima
terza etichetta (il risultato deve comprendere i nomi delle
coppie di etichette discografiche).
*/
SELECT lbl1.name,
       lbl2.name
FROM (
       SELECT rl1.label AS l1,
              rl2.label AS l2
       FROM release_label rl1
              INNER JOIN
            release_label rl2
            ON rl1.label < rl2.label
       EXCEPT
       (
         SELECT rl1.label,
                rl2.label
         FROM release_label rl1
                INNER JOIN
              release_label rl2
              ON
                  rl1.release = rl2.release
                  AND
                  rl1.label < rl2.label
       )
     )
       AS src
       INNER JOIN
     label lbl1
     ON src.l1 = lbl1.id
       INNER JOIN
     label lbl2
     ON src.l2 = lbl2.id
WHERE EXISTS
        (
          SELECT *
          FROM release_label rl1,
               release_label rl2,
               release_label rl3
          WHERE rl1.label < rl2.label
            AND rl2.label < rl3.label
            AND rl1.release = l1
            AND rl2.release = l2
        )
;

/* Query 13:
Trovare il nome e la lunghezza della traccia più lunga appartenente
a una release rilasciata in almeno due paesi (il risultato deve
contenere il nome della traccia e la sua lunghezza in secondi)
(scrivere due versioni della query).
*/

SELECT DISTINCT rec.name,
                rec.length
FROM recording rec
       INNER JOIN track t
                  ON rec.id = t.recording
       INNER JOIN medium m
                  ON t.medium = m.id
       INNER JOIN release r
                  ON m.RELEASE = r.id
       INNER JOIN release_country rc
                  ON r.id = rc.RELEASE
WHERE rec.length = (
  SELECT MAX(rec.length)
  FROM recording rec
         INNER JOIN track t
                    ON rec.id = t.recording
         INNER JOIN medium m
                    ON t.medium = m.id
         INNER JOIN release r
                    ON m.RELEASE = r.id
  WHERE (
          SELECT COUNT(rc.country)
          FROM release_country rc
          WHERE rc.RELEASE = r.id
        ) > 1
);

SELECT DISTINCT rec.name,
                rec.length
FROM recording rec
       INNER JOIN track t
                  ON rec.id = t.recording
       INNER JOIN medium m
                  ON t.medium = m.id
       INNER JOIN release r
                  ON m.RELEASE = r.id
       INNER JOIN release_country rc
                  ON r.id = rc.RELEASE
       INNER JOIN (
  SELECT MAX(lenghts) AS maximum
  FROM (
         SELECT rec.length AS lenghts
         FROM recording rec
                INNER JOIN track t
                           ON rec.id = t.recording
                INNER JOIN medium m
                           ON t.medium = m.id
                INNER JOIN release r
                           ON m.RELEASE = r.id
                INNER JOIN release_country rc
                           ON r.id = rc.RELEASE
         GROUP BY rec.id,
                  r.id
         HAVING COUNT(rc.country) > 1
       ) AS src
) AS src
                  ON src.maximum = rec.length;

/* Query 14:
Trovare le release e le tracce il cui nome contiene
il nome di un'area (il risultato deve contenere solo il
nome della release o della traccia, rinominato come "Nome").
*/
SELECT t.name
FROM track t,
     area a
WHERE t.name LIKE '%' || a.name || '%'
UNION
SELECT r.name
FROM release r,
     area a
WHERE r.name LIKE '%' || a.name || '%'