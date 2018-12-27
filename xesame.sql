 /* Query 1:
Contare il numero di lingue in cui le release contenute nel database
sono scritte (il risultato deve contenere soltanto il numero delle lingue,
rinominato “Numero_Lingue”).
*/
SELECT COUNT(DISTINCT language) Numero_Lingue
FROM   RELEASE;

/* Query 2:
Elencare gli artisti che hanno cantato canzoni in italiano (il risultato
deve contenere il nome dell’artista e il nome della lingua).
In questa query per semplicita' si sono considerati anche quegli artisti,
che hanno cantato non SOLO in italiano.
E' ragionevole l'uso di DISTINCT in questo caso?
*/SELECT DISTINCT artist.name   Artists,
                language.name Languages
FROM            artist_credit_name
JOIN            RELEASE
USING           (artist_credit)
JOIN            language
ON              language.id = RELEASE.language
JOIN            artist
ON              artist.id = artist_credit_name.artist
WHERE           language.name = 'Italian';

/* Query 3:
Elencare le release di cui non si conosce la lingua (il risultato
deve contenere soltanto il nome della release).
*/SELECT name
FROM   RELEASE
WHERE  language IS NULL;

/* Query 4:
Elencare gli artisti il cui nome contiene tutte le vocali (il risultato
deve contenere soltanto il nome dell’artista).
*/SELECT a.name
FROM   artist a
WHERE  a.name ilike '%a%'
AND    a.name ilike '%e%'
AND    a.name ilike '%i%'
AND    a.name ilike '%o%'
AND    a.name ilike '%u%'
       -- AND name NOT LIKE '% %' // SE SI VOGLIONO SOLO NOMI SINGOLI
       ;

/* Query 5:
Elencare tutti gli pseudonimi di Eminem con il loro tipo, se disponibile
(il risultato deve contenere lo pseudonimo dell'artista, il nome dell’artista
(cioè Eminem) e il tipo di pseudonimo (se disponibile)).
*/SELECT          artist.name            Nome,
                artist_alias.name      Pseudonimi,
                artist_alias_type.name Tipo_Alias
FROM            artist_alias
JOIN            artist
ON              artist_alias.artist = artist.id
LEFT OUTER JOIN artist_alias_type
ON              artist_alias.type = artist_alias_type.id
WHERE           artist.name = 'Eminem';

/* Query 6:
Trovare gli artisti con meno di venti tracce (il risultato deve contenere il
nome dell’artista ed il numero di tracce, ordinato in ordine crescente sul numero di tracce).
*/SELECT   artist.name     Artist,
         COUNT(track.id) Tracks
FROM     track
JOIN     artist_credit_name
USING    (artist_credit)
JOIN     artist
ON       artist.id = artist_credit_name.artist
GROUP BY(artist.id)
HAVING   COUNT(track.id) < 20
ORDER BY tracks ASC;

/* Query 7:
Elencare le lingue cui non corrisponde nessuna release (il risultato deve
contenere il nome della lingua, il numero di release in quella lingua, cioè
0, e essere ordinato per lingua) (scrivere due versioni della query).
*/
SELECT           language.name     Languages,
                 COUNT(RELEASE.id) Releases
FROM             RELEASE
RIGHT OUTER JOIN language
ON               RELEASE.language = language.id
GROUP BY         (language.id)
HAVING           COUNT(RELEASE.id) = 0
ORDER BY         languages ASC;SELECT          language.name     Languages,
                COUNT(RELEASE.id) Releases
FROM            language
LEFT OUTER JOIN RELEASE
ON              RELEASE.language = language.id
WHERE           RELEASE IS NULL
GROUP BY        (language.id)
ORDER BY        languages;

/* Query 8:
Ricavare la seconda registrazione per lunghezza di un artista uomo (il
risultato deve comprendere l'artista accreditato, il nome della registrazione
e la sua lunghezza) (scrivere due versioni della query).
Va bene se restituisce 2 o più recording se hanno tutti la stessa lunghezza?
*/



/*Query 9:
Per ogni stato esistente riportare la lunghezza totale delle registrazioni
di artisti di quello stato (il risultato deve comprendere il nome dello stato
e la lunghezza totale in minuti delle registrazioni (0 se lo stato non ha registrazioni).
*/
SELECT          area.name                                  Areas,
                SUM(COALESCE(recording.length, 0)) / 60000 LENGTH
FROM            area
LEFT OUTER JOIN artist
ON              artist.area = area.id
JOIN            artist_credit_name
ON              artist.id = artist_credit_name.artist_credit
JOIN            recording
USING           (artist_credit)
WHERE           area.type = 1
GROUP BY        area.id;

/* Query 10:
Considerando il numero medio di tracce tra le release pubblicate su CD, ricavare
gli artisti che hanno pubblicato esclusivamente release (su CD?) con più tracce
della media (il risultato deve contenere il nome dell’artista e il numero di
release (totali?) ed essere ordinato per numero di release discendente) (scrivere
due versioni della query).
Si sono considerate tutte le realease senza fare differenza nel controllo dei
track_count.
*/

SELECT a.name               ARTIST,
       COUNT(DISTINCT r.id) RELEASES
FROM   artist a
       JOIN artist_credit_name acn
         ON acn.artist = a.id
       JOIN RELEASE r USING (artist_credit)
       LEFT OUTER JOIN medium m
                    ON m.RELEASE = r.id
WHERE  m.format = 1 -- eliminabile a seconda delle necessita'
GROUP  BY a.id
HAVING MIN(m.track_count) > (SELECT AVG(m.track_count)
                             FROM   medium m
                             WHERE  m.format = 1)
ORDER  BY releases DESC;

