*** Settings ***
Documentation    Test di Precisione con conteggio token GPT-2
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    DateTime
Library    json
Library    Process
Library    ../Etabula/Chat/GPT2TokenCounter.py    WITH NAME    TokenCounter
Resource   ../Etabula/shared_variables.resource    # Importa il file di risorse condivise

*** Variables ***
${INSTALLATION_ENDPOINT}    /chat
${QUERY}    Dammi Informazioni del medico di medicina generale o del pediatra sul trattamento dei dati personali. Leggi dalla knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...  1. Il medico di medicina generale o il pediatra di libera scelta informano l'interessato
...  relativamente al trattamento dei dati personali, in forma chiara e tale da rendere
...  agevolmente comprensibili gli elementi indicati negli articoli 13 e 14 del Regolamento. (217)
...  2. Le informazioni possono essere fornite per il complessivo trattamento dei dati personali
...  necessario per attività di diagnosi, assistenza e terapia sanitaria, svolte dal medico o dal
...  pediatra a tutela della salute o dell'incolumità fisica dell'interessato, su richiesta dello
...  stesso o di cui questi è informato in quanto effettuate nel suo interesse. (218)
...  3. Le informazioni possono riguardare, altresì, dati personali eventualmente raccolti
...  presso terzi e sono fornite preferibilmente per iscritto. (219)
...  4. Le informazioni, se non è diversamente specificato dal medico o dal pediatra,
...  riguardano anche il trattamento di dati correlato a quello effettuato dal medico di medicina
...  generale o dal pediatra di libera scelta, effettuato da un professionista o da altro soggetto,
...  parimenti individuabile in base alla prestazione richiesta, che: (220)
...  a) sostituisce temporaneamente il medico o il pediatra;
...  b) fornisce una prestazione specialistica su richiesta del medico e del pediatra;
...  c) può trattare lecitamente i dati nell'ambito di un'attività professionale prestata in
...  forma associata;
...  d) fornisce farmaci prescritti;
...  e) comunica dati personali al medico o pediatra in conformità alla disciplina
...  applicabile.
...  5. Le informazioni rese ai sensi del presente articolo evidenziano analiticamente eventuali
...  trattamenti di dati personali che presentano rischi specifici per i diritti e le libertà
...  fondamentali, nonché per la dignità dell'interessato, in particolare in caso di trattamenti
...  effettuati: (221)
...  81
...  a) per fini di ricerca scientifica anche nell'ambito di sperimentazioni cliniche, in
...  conformità alle leggi e ai regolamenti, ponendo in particolare evidenza che il consenso,
...  ove richiesto, è manifestato liberamente; (222)
...  b) nell'ambito della teleassistenza o telemedicina;
...  c) per fornire altri beni o servizi all'interessato attraverso una rete di comunicazione
...  elettronica;
...  c-bis) ai fini dell'implementazione del fascicolo sanitario elettronico di cui all'articolo
...  12 del decreto-legge 18 ottobre 2012, n. 179, convertito, con modificazioni, dalla legge 17
...  dicembre 2012, n. 221; (223)
...  c-ter) ai fini dei sistemi di sorveglianza e dei registri di cui all'articolo 12 del decreto-
...  legge 18 ottobre 2012, n. 179, convertito, con modificazioni, dalla legge 17 dicembre 2012,
...  n. 221 (223).
...  (216) Rubrica così modificata dall’ art. 6, comma 1, lett. d), n. 1), D.Lgs. 10 agosto 2018, n. 101.
...  (217) Comma così modificato dall’ art. 6, comma 1, lett. d), n. 2), D.Lgs. 10 agosto 2018, n. 101.
...  (218) Comma così modificato dall’ art. 6, comma 1, lett. d), n. 3), D.Lgs. 10 agosto 2018, n. 101.
...  (219) Comma così sostituito dall’ art. 6, comma 1, lett. d), n. 4), D.Lgs. 10 agosto 2018, n. 101.
...  (220) Alinea così modificato dall’ art. 6, comma 1, lett. d), n. 5), D.Lgs. 10 agosto 2018, n. 101.
...  (221) Alinea così modificato dall’ art. 6, comma 1, lett. d), nn. 6.1) e 6.2), D.Lgs. 10 agosto 2018, n. 101.
...  (222) Lettera così sostituita dall’ art. 6, comma 1, lett. d), n. 6.3), D.Lgs. 10 agosto 2018, n. 101.
...  (223) Lettera aggiunta dall’ art. 6, comma 1, lett. d), n. 6.4), D.Lgs. 10 agosto 2018, n. 101

@{INSTALLATION_SECTIONS_PRIVACY}
...    Definizione=Il medico o pediatra deve informare l'interessato in merito al trattamento dei dati personali
...    Attività=Trattamento dati personali|Informazione|Trasparenza
...    Dati trattati=Diagnosi|Assistenza sanitaria|Terapia sanitaria|Ricerca scientifica|Telemedicina
...    Modalità di informazione=Iscritto|Chiarezza|Trasparenza|Consenso
...    Soggetti coinvolti=Medico|Pediatra


*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}

    ${text_lower}=    Convert To Lowercase    ${text}
    
    Should Match Regexp    ${text_lower}    informare|informazione|informazioni
    ...    msg=Manca la corretta Informazione
    Should Match Regexp    ${text_lower}    dati personali|dati
    ...    msg=Manca la corretta informazione sul soggetto
    
    Should Contain     ${text_lower}        trattamento
    ...    msg=Manca la corretta informazione sul trattamento 
    


Get PRIVACY Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_PRIVACY}

