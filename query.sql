/**
* Query 1:
* Contare il numero di lingue in cui le release contenute nel database sono scritte
* (il risultato deve contenere soltanto il numero delle lingue, rinominato “Numero_Lingue”).
*/

SELECT count(DISTINCT language)
FROM release;

/**
Query 2:
Elencare gli artisti che hanno cantato canzoni in italiano
(il risultato deve contenere il nome dell’artista e il nome della lingua).
 */

SELECT DISTINCT
  a.name,
  l.name
FROM release r
  INNER JOIN language l ON r.language = l.id
  INNER JOIN artist_credit ac ON r.artist_credit = ac.id
  INNER JOIN artist_credit_name acn ON ac.id = acn.artist_credit
  INNER JOIN artist a ON acn.artist = a.id
WHERE l.iso_code_1 = 'it';

/**
Query 3:
Elencare le release di cui non si conosce la lingua
(il risultato deve contenere soltanto il nome della release).
 */
SELECT r.name
FROM release r
WHERE r.language IS NULL;

/**
Query 4:
Elencare gli artisti il cui nome contiene tutte le vocali
(il risultato deve contenere soltanto il nome dell’artista).
 */

SELECT a.name
FROM artist a
WHERE a.name LIKE '%a%' AND
      a.name LIKE '%e%' AND
      a.name LIKE '%i%' AND
      a.name LIKE '%o%' AND
      a.name LIKE '%u%'
-- AND name NOT LIKE '% %' // SE SI VOGLIONO SOLO NOMI SINGOLI
;

/**
Query 5:
Elencare tutti gli pseudonimi di Eminem con il loro tipo, se disponibile
(il risultato deve contenere lo pseudonimo dell'artista, il nome
dell’artista (cioè Eminem) e il tipo di pseudonimo (se disponibile)).
 */

SELECT
  a.name   AS ARTIST_NAME,
  aa.name  AS ALIAS,
  aat.name AS ALIAS_TYPE
FROM artist a
  INNER JOIN artist_alias aa ON a.id = aa.artist
  LEFT JOIN artist_alias_type aat ON a.type = aat.id
-- where a.name = 'Eminem'
;

/**
Query 6:
Trovare gli artisti con meno di venti tracce
(il risultato deve contenere il nome dell’artista ed il numero
di tracce, ordinato in ordine crescente sul numero di tracce).
*/

SELECT
  a.name,
  count(t.id)
FROM track t
  INNER JOIN artist_credit ac ON t.artist_credit = ac.id
  INNER JOIN artist_credit_name acn ON ac.id = acn.artist_credit
  INNER JOIN artist a ON acn.artist = a.id
GROUP BY a.id
HAVING count(t.id) < 20
ORDER BY count(t.id) ASC;

/**
Query 7:
Elencare le lingue cui non corrisponde nessuna release (il risultato deve contenere il
nome della lingua, il numero di release in quella lingua, cioè 0, e essere ordinato
 per lingua) (scrivere due versioni della query).
 */

SELECT
  l.name,
  (
    SELECT count(r.id)
    FROM release r
    WHERE r.language = l.id
  )
FROM language l
WHERE l.id NOT IN
      (
        SELECT DISTINCT r.language
        FROM release r
        WHERE r.language IS NOT NULL
      );

SELECT
  l.name,
  count(r.id)
FROM language l
  LEFT JOIN release r ON l.id = r.language
WHERE r.id IS NULL
GROUP BY l.id
ORDER BY l.name ASC;

/**
Query 8:
Ricavare la seconda registrazione per lunghezza di un artista uomo
(il risultato deve comprendere l'artista accreditato, il nome
della registrazione e la sua lunghezza) (scrivere due versioni della query).
 */

SELECT
  a.name AS ARTIST_NAME,
  r.name AS RECORDING_NAME,
  r.length
FROM artist a
  INNER JOIN artist_credit_name acn ON a.id = acn.artist
  INNER JOIN artist_credit ac ON acn.artist_credit = ac.id
  INNER JOIN recording r ON ac.id = r.artist_credit
WHERE a.gender = 1
      AND (
            SELECT count(*)
            FROM recording r2
            WHERE r2.artist_credit = ac.id AND r2.length > r.length
          ) = 1;

-- TODO: Manca versione 2

/**
Query 9:
Per ogni stato esistente riportare la lunghezza totale delle registrazioni di artisti di quello stato
(il risultato deve comprendere il nome dello stato e la lunghezza
totale in minuti delle registrazioni (0 se lo stato non ha registrazioni).
 */

SELECT
  ar.name,
  coalesce(sum(r.length), 0) / 60 AS TIME
FROM country_area ca
  INNER JOIN area ar ON ca.area = ar.id
  LEFT JOIN artist a ON ca.area = a.area
  INNER JOIN artist_credit_name acn ON a.id = acn.artist
  INNER JOIN artist_credit ac ON acn.artist_credit = ac.id
  INNER JOIN recording r ON ac.id = r.artist_credit
GROUP BY ar.name;

/**
Query 10:
Considerando il numero medio di tracce tra le release pubblicate
su CD, ricavare gli artisti che hanno pubblicato esclusivamente release con più tracce della media
(il risultato deve contenere il nome dell’artista e
il numero di release ed essere ordinato per numero di
release discendente) (scrivere due versioni della query).
 */




/**
Query 11:
Ricavare il primo artista morto dopo Freddie Mercury (il risultato deve contenere il nome dell’artista,
la sua data di nascita e la sua data di morte).
In questa query non è possibile moltiplicare i valori di anno mese ed anno per altri numeri.
 */
SELECT
  a.name,
  date(concat(a.end_date_year, '-', a.end_date_month, '-', a.end_date_day))
FROM artist a, artist b
WHERE
  a.end_date_year IS NOT NULL
  AND a.end_date_month IS NOT NULL
  AND a.end_date_day IS NOT NULL AND
  b.end_date_year IS NOT NULL
  AND b.end_date_month IS NOT NULL
  AND b.end_date_day IS NOT NULL AND
  date(concat(a.end_date_year, '-', a.end_date_month, '-', a.end_date_day))
  >= date(concat(b.end_date_year, '-', b.end_date_month, '-', b.end_date_day))
  AND b.id = 232732
  AND a.id != b.id
  AND NOT exists
  (
      SELECT *
      FROM artist c
      WHERE
        c.end_date_year IS NOT NULL
        AND c.end_date_month IS NOT NULL
        AND c.end_date_day IS NOT NULL AND
        date(concat(c.end_date_year, '-', c.end_date_month, '-', c.end_date_day))
        BETWEEN date(concat(b.end_date_year, '-', b.end_date_month, '-', b.end_date_day)) AND date(
            concat(a.end_date_year, '-', a.end_date_month, '-', a.end_date_day))
        AND c.id != a.id
        AND c.id != b.id
  )
ORDER BY date(concat(a.end_date_year, '-', a.end_date_month, '-', a.end_date_day))




