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
${QUERY}    Su cosa Mario vuole aggiornare giulia? leggi nella knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    Ciao Giulia,
...    Spero tu stia passando una buona giornata!
...    Volevo aggiornarti su alcuni progetti recenti su cui sto lavorando.
...    Ho fatto dei progressi significativi e spero di poterti fornire più dettagli presto.
...    Fammi sapere come stai anche tu!
...    A presto,
...    Mario


@{INSTALLATION_SECTIONS_MAIL}
...    Mittente=Mario 
...    Destinatario=Giulia 
...    Contenuto aggiornamento=progetti recenti|progressi significativi|dettagli a breve


*** Keywords ***
Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
        
    Should Contain    ${text_lower}    progetti recenti
    ...    msg=Manca il riferimento ai progetti recenti su cui Mario sta lavorando

    Should Contain    ${text_lower}    progressi significativi
    ...    msg=Manca il riferimento ai progressi significativi fatti da Mario

    Should Contain    ${text_lower}    dettagli
    ...    msg=Manca il riferimento al fatto che fornirà più dettagli a breve

Get MAIL Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_MAIL}

