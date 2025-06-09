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
${QUERY}    quanti cuori ha un polpo? leggi nella knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    Il polpo ha tre cuori.


@{INSTALLATION_SECTIONS_CUR}
...    Cuori= tre 


*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
        
    Should Match Regexp     ${text_lower}    tre cuori|3 cuori
    ...    msg=Manca il riferimento ai tre cuori

Get CUR Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_CUR}

