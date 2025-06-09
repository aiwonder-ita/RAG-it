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
${QUERY}    che cosa dice l'autore nella prefazione di Two Years' Captivity in German East Africa?
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    Questo piccolo libro racconta le mie esperienze come prigioniero di guerra nell'Africa Orientale Tedesca.
...    Nella stesura e trasformazione in forma di libro, ho ricevuto un aiuto prezioso da parte di una persona esperta in metodi letterari, ma il contenuto rimane una semplice e non elaborata narrazione dei fatti.
...    Ho cercato di non soffermarmi troppo sulle privazioni, i disagi e le umiliazioni subite, e per motivi di spazio posso solo accennare alla miserabile condizione della popolazione locale.
...    Tuttavia, non esito ad affermare la mia convinzione che se l'Africa Orientale dovesse ricadere sotto il dominio tedesco, ciò sarebbe un disastro per le popolazioni indigene.
...    Il dominio tedesco in Africa è “il dominio del kiboko”. Kiboko è una parola probabilmente sconosciuta alla maggior parte degli inglesi... ma è fin troppo nota a ogni nativo... significa “la frusta”.

@{INSTALLATION_SECTIONS_BOOK}
...    Esperienza personale=prigioniero di guerra nell'Africa Orientale Tedesca
...    Struttura del libro=aiuto nella scrittura|semplice narrazione dei fatti
...    Sofferenze=privazioni|disagi|umiliazioni
...    Opinione sulla Germania=dominio tedesco|disastro|kiboko|frusta


*** Keywords ***
Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
    

    Should Contain    ${text_lower}    prigioniero di guerra
    ...    msg=Manca il riferimento all'autore come prigioniero di guerra

    Should Contain    ${text_lower}    narrazione
    ...    msg=Manca la descrizione del libro come narrazione semplice dei fatti

    Should Contain    ${text_lower}    kiboko
    ...    msg=Manca la parola chiave "kiboko", centrale nel messaggio dell’autore

Get BOOK Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_BOOK}

