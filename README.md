# RAG-it

## Introduzione  
**RAG-it** è una suite di test automatizzati – scritta quasi interamente in Robot Framework – che misura precisione, copertura semantica, tempi di risposta e consumo di token di un back-end _Retrieval-Augmented Generation_ (RAG) esposto via API HTTP. La raccolta di casi d’uso è in italiano e copre domande che vanno dalla matematica applicata alle reti neurali, dai prezzi di listino alla narrativa storica, fornite dentro file `.robot` modulari e riutilizzabili.<!-- :contentReference[oaicite:0]{index=0} -->

## Caratteristiche principali  

* **Test end-to-end** con `RequestsLibrary` per interrogare l’endpoint `/chat` e validare lo _status code_, la similarità della risposta e la presenza di keyword obbligatorie.<!-- :contentReference[oaicite:1]{index=1} -->
* **Raccolta di prompt e attese** all’interno della cartella `RisposteCorrette/`, ciascuno con soglia di similarità e regole di verifica dedicate.<!-- :contentReference[oaicite:2]{index=2} -->
* **Checkpointing** per riprendere esecuzioni lunghe senza perdere lo stato (file `checkpoint.json`).<!-- :contentReference[oaicite:3]{index=3} -->
* **Conteggio token** grazie alla libreria personalizzata `GPT2TokenCounter.py`, che usa il tokenizer GPT-2 di 🤗 Transformers.<!-- :contentReference[oaicite:4]{index=4} -->
* **Report riepilogativi** con statistiche aggregate di pass/fail, durata media, token medi e similarità media.<!-- :contentReference[oaicite:5]{index=5} -->

## Struttura del progetto  

| Percorso | Descrizione |
|----------|-------------|
| `Documenti/` | (facoltativo) Documenti di conoscenza usati dal motore RAG – da caricare separatamente. |
| `RisposteCorrette/` | Suite di _acceptance test_ tematiche (`chatMatrices.robot`, `chatBook.robot`, ecc.) con prompt, risposta attesa e keyword di validazione.<!-- :contentReference[oaicite:6]{index=6} --> |
| `RisultatoFinale/` | Contiene l'algoritmo di classificazione utilizzato per dare un punteggio ai modelli e il report che indica il punteggio per i modelli già testati.|
| `Tabella.pdf` | Tabella riepilogativa del punteggio assegnato a modelli già testati.|
| `shared_variables.resource` | Variabili condivise: `BASE_URL`, credenziali, token e document-id.<!-- :contentReference[oaicite:7]{index=7} --> |
| `Setup.robot` | Effettua il login, valida HTTP 200 e salva l’`access_token` in `token.txt`.<!-- :contentReference[oaicite:8]{index=8} --> |
| `CHATEST.robot` | Runner principale: cicla sui test, gestisce checkpoint e genera il report finale.<!-- :contentReference[oaicite:9]{index=9} --> |
| `GPT2TokenCounter.py` | Modulo Python usabile come libreria Robot per il conteggio dei token GPT-2.<!-- :contentReference[oaicite:10]{index=10} --> |

## Requisiti  

* **Python ≥ 3.8**  
* **Robot Framework** e librerie: `robotframework-requests`, `robotframework-json`, `robotframework-datetime`, `robotframework-process`.<!-- :contentReference[oaicite:11]{index=11} -->  
* **Transformers** (solo per il conteggio token).<!-- :contentReference[oaicite:12]{index=12} -->

> Installa tutto con  
> ```bash
> pip install robotframework robotframework-requests robotframework-json \
>             robotframework-datetime robotframework-process transformers
> ```

## Configurazione  

1. Copia il repository e posizionati nella root.  
2. Apri `shared_variables.resource` e imposta:  
   * `BASE_URL` → URL del tuo back-end RAG  
   * `USERNAME` / `PASSWORD` → credenziali valide  
3. Esegui il login:  
```bash
robot Setup.robot
```

Verrà creato `token.txt` con l’`access_token`.

# Avvio dei test

## test completi con 10 iterazioni su tutti i file di RisposteCorrette
```bash
robot CHATEST.robot
```

L’output standard di Robot (`output.xml`, `report.html`, `log.html`) si troverà nella directory `output_multipli/`. In caso di interruzione potrai rieseguire il comando: il runner ripartirà dal file successivo grazie al checkpoint.

## Aggiungere nuovi casi di test

1. Crea un nuovo `chatX.robot` in `RisposteCorrette/` seguendo la struttura degli altri file (sezione `*** Variables ***` con `QUERY`, `SIMILARITY_THRESHOLD`, risposta “gold” e variabili di output).
2. Importa eventualmente keyword aggiuntive nel blocco `*** Keywords ***`.
3. Aggiorna la lista `@{TEST_FILES}` in `CHATEST.robot` se vuoi eseguire il file in batch.


## Licenza

MIT

---

© 2025 AIWONDER.IT
