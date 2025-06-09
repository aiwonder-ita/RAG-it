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
${QUERY}    ogni quanto completa un'orbita la stazione spaziale internazionale e a che velocità ? leggi dalla knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    La Stazione Spaziale Internazionale orbita attorno alla Terra a una velocità di circa 28.000 km/h e completa un'orbita ogni 90 minuti!

@{INSTALLATION_SECTIONS_HTML}
...    Velocità orbitale=28.000 km/h
...    Frequenza orbita=90 minuti

*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
    

    Should Contain    ${text_lower}    28.000
    ...    msg=Manca il riferimento alla velocità orbitale di circa 28.000 km/h

    Should Contain    ${text_lower}    km/h
    ...    msg=Manca l'unità di misura della velocità (km/h)

    Should Contain    ${text_lower}    90
    ...    msg=Manca il riferimento al tempo di completamento dell’orbita (90 minuti)

    Should Contain    ${text_lower}    minuti
    ...    msg=Manca l’unità di misura del tempo (minuti)

Get HTML Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_HTML}

