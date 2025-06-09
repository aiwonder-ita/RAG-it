*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***
${BASE_URL}    http://localhost:9095
${UI_URL}         http://localhost:4200
${USERNAME}    admin@example.com
${PASSWORD}    admin123
${ACCESS_TOKEN}    ${EMPTY}    # Sarà impostata dal test di login
${DOCUMENT_ID}    ${EMPTY}    # Sarà impostata dal test di upload

*** Keywords ***
Load Token From File
    [Documentation]    Carica il token dal file
    ${token_file_path}=    Set Variable    ${CURDIR}/token.txt
    File Should Exist    ${token_file_path}    Il file token.txt non esiste.
    ${token_file_content}=    Get File    ${token_file_path}
    ${_access_token}=    Strip String    ${token_file_content}
    Set Global Variable     ${ACCESS_TOKEN}    ${_access_token}

Status Should Be
    [Arguments]    ${expected_status}    ${response}
    Should Be Equal As Strings    ${response.status_code}    ${expected_status}
    Log    Status: ${response.status_code}

Load DocumentID From File
    [Arguments]    ${DOCUMENT_NAME}
    [Documentation]    Carica il document ID associato al nome specificato dal file documentid.txt
    ${doc_file_path}=    Set Variable    ${CURDIR}/../documentid.txt
    File Should Exist    ${doc_file_path}    Il file documentid.txt non esiste.
    ${doc_file_content}=    Get File    ${doc_file_path}
    Log    Contenuto del file: ${doc_file_content}    # Aggiungi un log del contenuto del file per il debug
    ${lines}=    Split String    ${doc_file_content}    \n
    ${found}=    Set Variable    ${False}
    ${DOCUMENT_ID_TEMP}=    Set Variable    ""    # Inizializzazione della variabile temporanea
    FOR    ${line}    IN    @{lines}
        ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${line}
        Run Keyword If    ${is_empty}    Continue For Loop
        # Rimuovi spazi prima e dopo e separa la stringa
        ${line}=    Strip String    ${line}    # Rimuovi spazi superflui
        ${parts}=    Split String    ${line}    :
        ${name}=    Set Variable    ${parts}[0]
        ${id}=    Set Variable    ${parts}[1]
        # Debug: Aggiungi log per verificare i valori letti
        Log    Lettura linea: ${name} -> ${id}
        Run Keyword If    '${name}' == '${DOCUMENT_NAME}'    Set Test Variable    ${DOCUMENT_ID_TEMP}    ${id}
        Run Keyword If    '${name}' == '${DOCUMENT_NAME}'    Set Test Variable    ${found}    ${True}
        Run Keyword If    '${name}' == '${DOCUMENT_NAME}'    Exit For Loop
    END
    Run Keyword Unless    ${found}    Fail    Documento con nome '${DOCUMENT_NAME}' non trovato nel file.
    Set Global Variable    ${DOCUMENT_ID}    ${DOCUMENT_ID_TEMP}
    Log    Caricato DOCUMENT_ID: ${DOCUMENT_ID} per nome: ${DOCUMENT_NAME}




Save DocumentID To File
    [Arguments]    ${DOCUMENT_ID}    ${DOCUMENT_NAME}
    ${doc_file}=    Set Variable    ${CURDIR}/../documentid.txt

    ${file_exists}=    Run Keyword And Return Status    File Should Exist    ${doc_file}
    ${lines}=    Create List
    IF    ${file_exists}
        ${content}=    Get File    ${doc_file}
        ${lines}=    Split String    ${content}    \n
    END

    ${filtered_lines}=    Create List
    FOR    ${line}    IN    @{lines}
        ${name}=    Split String    ${line}    :
        Run Keyword Unless    '${name[0]}' == '${DOCUMENT_NAME}'    Append To List    ${filtered_lines}    ${line}
    END

    Append To List    ${filtered_lines}    ${DOCUMENT_NAME}:${DOCUMENT_ID}
    ${final_content}=    Catenate    SEPARATOR=\n    @{filtered_lines}
    Create File    ${doc_file}    ${final_content}
    Log    Document ID salvato nel file: ${doc_file}

