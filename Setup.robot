*** Settings ***
Documentation    Test per API login - verifica status code ed estrazione token
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Resource   ../shared_variables.resource    # Importa il file di risorse condivise

*** Variables ***
${LOGIN_ENDPOINT}    /login

*** Test Cases ***
Verify Login And Extract Token
    [Documentation]    Verifica lo status code HTTP 200 ed estrae l'access token
    # Configurazione payload essenziale
    ${payload}=    Create Dictionary
    ...    username=${USERNAME}
    ...    password=${PASSWORD}
    
    # Header minimo richiesto per form-urlencoded
    ${headers}=    Create Dictionary
    ...    Content-Type=application/x-www-form-urlencoded
    
    # Esecuzione POST request
    Create Session    login_session    ${BASE_URL}    verify=True
    ${response}=    POST On Session
    ...    login_session
    ...    ${LOGIN_ENDPOINT}
    ...    headers=${headers}
    ...    data=${payload}
    
    # Validazione status code 200
    Status Should Be    200    ${response}
    
    # Estrazione e salvataggio del token
    ${response_json}=    Set Variable    ${response.json()}
    ${token}=    Get From Dictionary    ${response_json}    access_token
    Set Suite Variable    ${ACCESS_TOKEN}    ${token}    # Imposta come variabile di suite
    Log    Access Token: ${ACCESS_TOKEN}
    
    # Salva il token in un file per condividerlo tra le suite
    Save Token To File    ${token}

    #Set Suite Metadata    ExecutionTime    3200

*** Keywords ***
Status Should Be
    [Arguments]    ${expected_status}    ${response}
    Should Be Equal As Strings    ${response.status_code}    ${expected_status}
    Log    Status: ${response.status_code}

Save Token To File
    [Arguments]    ${token}
    ${token_file}=    Set Variable    ${CURDIR}/../token.txt
    Create File    ${token_file}    ${token}
    Log    Token salvato nel file: ${token_file}