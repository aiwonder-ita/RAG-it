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
${QUERY}    parlami della storia della danza. leggi nella knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

# Storia della danza
${FULL_PROCEDURE}
...    La danza ha origini antichissime e ha sempre avuto un ruolo importante nelle culture di tutto il mondo,
...    spesso associata a rituali, celebrazioni e spettacoli teatrali.

@{INSTALLATION_SECTIONS_DANZA}
...    Origini=La danza ha origini antichissime
...    Importanza culturale=ruolo importante nelle culture di tutto il mondo
...    Contesti di utilizzo=associata a rituali|celebrazioni|spettacoli teatrali


*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
    
    Should Contain    ${text_lower}    origini antichissime
    ...    msg=Manca il riferimento alle origini antichissime della danza

    Should Contain    ${text_lower}    ruolo importante
    ...    msg=Manca la menzione del ruolo importante della danza

Get DANZA Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_DANZA}

