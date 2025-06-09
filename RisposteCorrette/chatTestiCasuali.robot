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
${QUERY}    Dove vivono i testi casuali? leggi dalla knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}    
...    In una terra lontana, dietro le montagne Parole, lontani dalle terre di Vocalia e Consonantia, vivono i testi casuali.
...    Vivono isolati nella cittadina di Lettere, sulle coste del Semantico, un immenso oceano linguistico.
...    Un piccolo ruscello chiamato Devoto Oli attraversa quei luoghi, rifornendoli di tutte le regolalie di cui hanno bisogno.
...    È una terra paradismatica, un paese della cuccagna in cui golose porzioni di proposizioni arrostite volano in bocca a chi le desideri.


@{INSTALLATION_SECTIONS_TC}
...    Collocazione geografica=In una terra lontana|dietro le montagne Parole|lontani da Vocalia e Consonantia
...    Luogo specifico=Vivono isolati nella cittadina di Lettere|sulle coste del Semantico
...    Elementi naturali=Un piccolo ruscello chiamato Devoto Oli attraversa quei luoghi

*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
    
    Should Contain    ${text_lower}    testi casuali
    ...    msg=Manca la menzione dei testi casuali nella descrizione

    Should Contain    ${text_lower}    cittadina di lettere
    ...    msg=Manca la cittadina di Lettere, dove vivono i testi casuali

    Should Contain    ${text_lower}    semantico
    ...    msg=Manca il riferimento all'oceano Semantico

    Should Contain    ${text_lower}    montagne parole
    ...    msg=Manca la collocazione dietro le montagne Parole

    Should Contain    ${text_lower}    vocalia
    ...    msg=Manca la terra di Vocalia, necessaria per la collocazione

    Should Contain    ${text_lower}    consonantia
    ...    msg=Manca la terra di Consonantia, necessaria per la collocazione

Get TC Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_TC}

