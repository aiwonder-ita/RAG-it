*** Settings ***
Documentation    Test di Precisione con conteggio token GPT-2
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
${QUERY}    cos'è un catafratto? leggi nella knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}    
...    Storia del Catafratto
...    Il catafratto è una cavalcatura medievale di epoca bizzantina costituita da un cavaliere e un nano appoggiato sopra.

# Suddivisione in sezioni della storia per analisi dettagliata
@{INSTALLATION_SECTIONS_CATAFRATTO}
...    Descrizione generale=Il catafratto è una cavalcatura medievale di epoca bizzantina costituita da un cavaliere e un nano appoggiato sopra.


*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
    
    
    Should Contain    ${text_lower}    catafratto
    ...    msg=Manca il termine "catafratto" nella descrizione

    Should Contain    ${text_lower}    cavalcatura
    ...    msg=Manca la parola "cavalcatura" nella descrizione

    Should Contain    ${text_lower}    cavaliere
    ...    msg=Manca la presenza del cavaliere nella descrizione

    Should Contain    ${text_lower}    nano
    ...    msg=Manca la presenza del nano nella descrizione

    Should Contain    ${text_lower}    bizantina
    ...    msg=Non è specificata l'epoca bizantina nella descrizione

    Should Contain    ${text_lower}    medievale
    ...    msg=Non è specificato che si tratta di un contesto medievale

Get CATAFRATTO Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_CATAFRATTO}

