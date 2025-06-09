*** Settings ***
Documentation    Test di Precisione per Procedura con conteggio token GPT-2
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    DateTime
Library    json
Library    Process
Library    ../GPT2TokenCounter.py    WITH NAME    TokenCounter
Resource   ../shared_variables.resource    # Importa il file di risorse condivise


*** Variables ***
${INSTALLATION_ENDPOINT}    /chat
${QUERY}    cos'è il baseball? leggi nella knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    Il baseball è uno sport di squadra che si gioca con una mazza, una palla e un guantone.
...    Due squadre si affrontano cercando di segnare più punti possibili colpendo la palla e correndo sulle basi.


@{INSTALLATION_SECTIONS_BASEBALL}
...    Definizione=Il baseball è uno sport di squadra
...    Strumenti=mazza|palla|guantone
...    Regole generali=Due squadre|segnare punti|colpendo la palla|correndo sulle basi


*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
    

    Should Match Regexp    ${text_lower}    .*sport( di squadra| giocato da due squadre).*
    ...    msg=Manca una definizione corretta di sport: né "sport di squadra" né "sport giocato da due squadre" sono presenti

    Should Contain    ${text_lower}    mazza
    ...    msg=Manca lo strumento: mazza

    Should Contain    ${text_lower}    palla
    ...    msg=Manca lo strumento: palla

    Should Contain    ${text_lower}    guantone
    ...    msg=Manca lo strumento: guantone

    Should Contain    ${text_lower}    segnare
    ...    msg=Manca il concetto di segnare punti

    Should Contain    ${text_lower}    basi
    ...    msg=Manca il riferimento alle basi

Get BASEBALL Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_BASEBALL}

