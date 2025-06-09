*** Settings ***
Documentation    Esecuzione ripetuta del test su più file con checkpoint 
Library    Collections
Library    OperatingSystem
Library    String
Library    DateTime
Library    json
Resource    ${CURDIR}/chatMatrices.robot
Resource    ${CURDIR}/chatPPTX.robot
Resource    ${CURDIR}/chatCuriosità.robot
Resource    ${CURDIR}/chatBaseball.robot
Resource    ${CURDIR}/chatBook.robot
Resource    ${CURDIR}/chatCatafratto.robot
Resource    ${CURDIR}/chatDanza.robot
Resource    ${CURDIR}/chatHTML.robot
Resource    ${CURDIR}/chatLLM.robot
Resource    ${CURDIR}/chatMail.robot
Resource    ${CURDIR}/chatTecnologia.robot
Resource    ${CURDIR}/chatTestiCasuali.robot
Resource    ${CURDIR}/chatEtabula.robot
Resource    ${CURDIR}/chatPrivacy.robot
Resource    ${CURDIR}/chatPrezzi.robot
Resource    ${CURDIR}/chatAnagrafica.robot
Resource    ../Etabula/shared_variables.resource

Suite Setup    Load Token From File
*** Variables ***
@{TEST_FILES}=    
...    chatMatrices.robot    
...    chatPPTX.robot 
...    chatCuriosità.robot
...    chatBaseball.robot
...    chatBook.robot
...    chatCatafratto.robot
...    chatDanza.robot
...    chatHTML.robot
...    chatLLM.robot
...    chatMail.robot
...    chatTecnologia.robot
...    chatTestiCasuali.robot
...    chatEtabula.robot   
...    chatPrivacy.robot
...    chatPrezzi.robot
...    chatAnagrafica.robot

${MAIN_OUTPUT_DIR}    ${CURDIR}/output_multipli
${ITERATIONS}    10
${TIMESTAMP}    ${EMPTY}
${RESPONSE_DIR}   ./Chat/output

# Checkpoint configuration
${CHECKPOINT_FILE}    ${MAIN_OUTPUT_DIR}/checkpoint.json
${RESUME_FROM_CHECKPOINT}    ${TRUE}

*** Test Cases ***

Run Multiple Precision Tests
    [Documentation]    Esegue il test di precisione su più file, ogni file per un numero predefinito di iterazioni con supporto checkpoint
    
    # Crea la directory di output se non esiste
    Create Directory    ${MAIN_OUTPUT_DIR}
    
    # Carica lo stato del checkpoint se esiste e RESUME_FROM_CHECKPOINT è True
    ${checkpoint_exists}=    Run Keyword And Return Status    File Should Exist    ${CHECKPOINT_FILE}
    Run Keyword If    ${RESUME_FROM_CHECKPOINT} and ${checkpoint_exists}    Load Checkpoint
    
    # Inizializza variabili per il riepilogo finale
    ${total_files}=    Get Length    ${TEST_FILES}
    # Inizializza variabili solo se non si riprende da checkpoint
    ${total_files}=    Get Length    ${TEST_FILES}
    Run Keyword Unless    ${RESUME_FROM_CHECKPOINT} and ${checkpoint_exists}    Initialize Results Variables

    
    # Inizializza test_results come lista vuota
    ${test_results}=    Create List

    # Determina l'indice di partenza in base al checkpoint
    ${start_index}=    Set Variable If    ${RESUME_FROM_CHECKPOINT} and ${checkpoint_exists}    ${CHECKPOINT_INDEX}    ${0}
    
    # Per ogni file nella lista, partendo dall'indice corretto
    FOR    ${index}    IN RANGE    ${start_index}    ${total_files}
        ${test_file}=    Get From List    ${TEST_FILES}    ${index}
        
        Log To Console    \n\n===== TEST FILE: ${test_file} =====\n
        
        Set Suite Variable    ${success_count}    0
        Set Suite Variable    ${failure_count}    0
        Set Suite Variable    ${total_duration}    0
        Set Suite Variable    ${total_tokens}    0
        Set Suite Variable    ${total_similarity}    0

        # Crea una lista vuota per i risultati
        ${test_results}=    Create List
        Set Suite Variable    ${test_results}
        
        ${file_path}=    Set Variable    ${CURDIR}/${test_file}
        
        # Crea directory per i risultati di questo file
        ${file_output_dir}=    Set Variable    ${MAIN_OUTPUT_DIR}/${test_file}_results
        Create Directory    ${file_output_dir}
        
        # Esegui test per questo file
        ${file_results}=    Esegui Test Per File    ${test_file}    ${file_output_dir}    ${file_path}
        
        # Aggiungi risultati di questo file al riepilogo finale
        Append To List    ${all_file_results}    ${file_results}
        ${all_success_count}=    Evaluate    ${all_success_count} + ${file_results}[passed]
        ${all_failure_count}=    Evaluate    ${all_failure_count} + ${file_results}[failed]
        ${all_total_duration}=    Evaluate    ${all_total_duration} + (${file_results}[average_duration] * ${file_results}[passed])
        ${all_total_tokens}=    Evaluate    ${all_total_tokens} + (${file_results}[average_tokens] * ${file_results}[passed])
        ${all_total_similarity}=    Evaluate    ${all_total_similarity} + (${file_results}[average_similarity] * ${file_results}[passed])
        
        # Salva checkpoint dopo ogni file completato
        Save Checkpoint    ${index}    ${all_file_results}    ${all_success_count}    ${all_failure_count}    ${all_total_duration}    ${all_total_tokens}    ${all_total_similarity}

    END

    # Crea report riepilogativo finale
    Create Summary Report    ${all_file_results}    ${all_success_count}    ${all_failure_count}    ${all_total_duration}    ${all_total_tokens}    ${all_total_similarity}
    
    # Rimuovi il checkpoint a completamento
    Run Keyword And Ignore Error    Remove File    ${CHECKPOINT_FILE}


*** Keywords ***
Initialize Results Variables
    @{all_file_results}=    Create List
    Set Suite Variable    @{all_file_results}
    ${all_success_count}=    Set Variable    ${0}
    Set Suite Variable    ${all_success_count}
    ${all_failure_count}=    Set Variable    ${0}
    Set Suite Variable    ${all_failure_count}
    ${all_total_duration}=    Set Variable    ${0.0}
    Set Suite Variable    ${all_total_duration}
    ${all_total_tokens}=    Set Variable    ${0}
    Set Suite Variable    ${all_total_tokens}
    ${all_total_similarity}=    Set Variable    ${0.0}
    Set Suite Variable    ${all_total_similarity}


Save Checkpoint
    [Arguments]    ${current_index}    ${file_results}    ${success_count}    ${failure_count}    ${total_duration}    ${total_tokens}    ${total_similarity}
    
    ${serializable_results}=    Evaluate    [dict(x) if isinstance(x, dict) else x for x in $file_results]

    &{checkpoint_data}=    Create Dictionary
    ...    index=${current_index + 1}
    ...    file_results=${serializable_results}
    ...    success_count=${success_count}
    ...    failure_count=${failure_count}
    ...    total_duration=${total_duration}
    ...    total_tokens=${total_tokens}
    ...    total_similarity=${total_similarity}

    Save Checkpoint Internal    ${checkpoint_data}

Save Checkpoint Internal
    [Arguments]    ${checkpoint_data}
    
    ${json_checkpoint}=    Evaluate    json.dumps($checkpoint_data, indent=4)
    Create File    ${CHECKPOINT_FILE}    ${json_checkpoint}
    
    Log    ✅ Checkpoint salvato correttamente al file ${CHECKPOINT_FILE}

Load Checkpoint
    [Documentation]    Carica lo stato dal checkpoint precedente
    TRY
        ${checkpoint_json}=    Get File    ${CHECKPOINT_FILE}
        ${checkpoint_data}=    Evaluate    json.loads('''${checkpoint_json}''')

        # ✅ Carica i risultati in una variabile temporanea
        ${saved_results}=    Set Variable    ${checkpoint_data}[file_results]
        @{all_file_results}=    Create List
        FOR    ${result}    IN    @{saved_results}
                    Append To List    ${all_file_results}    ${result}
        END
        Set Suite Variable    @{all_file_results}

        # Ripristina le altre variabili
        Set Suite Variable    ${CHECKPOINT_INDEX}        ${checkpoint_data}[index]
        Set Suite Variable    ${all_success_count}       ${checkpoint_data}[success_count]
        Set Suite Variable    ${all_failure_count}       ${checkpoint_data}[failure_count]
        Set Suite Variable    ${all_total_duration}      ${checkpoint_data}[total_duration]
        Set Suite Variable    ${all_total_tokens}        ${checkpoint_data}[total_tokens]
        Set Suite Variable    ${all_total_similarity}    ${checkpoint_data}[total_similarity]

        Log    📦 CHECKPOINT CARICATO CORRETTAMENTE    level=INFO
    EXCEPT
        Log    ⚠️ ERRORE NEL CARICAMENTO DEL CHECKPOINT: ${EXCEPTION}    level=ERROR
        Set Suite Variable    ${CHECKPOINT_INDEX}    ${0}
    END

Esegui Test Per File
    [Documentation]    Esegue più iterazioni di test su un singolo file
    [Arguments]    ${test_file}    ${output_dir}    ${file_path}
    
    # Inizializza contatori e lista risultati
    ${success_count}=    Set Variable    ${0}
    ${failure_count}=    Set Variable    ${0}
    ${total_duration}=    Set Variable    ${0.0}
    ${total_tokens}=    Set Variable    ${0}
    ${total_similarity}=    Set Variable    ${0.0}

    # Esegui il numero specificato di iterazioni
    FOR    ${i}    IN RANGE    ${ITERATIONS}
        ${iter_num}=    Evaluate    ${i} + 1
        Log To Console    \n---- ${test_file} - Iterazione ${iter_num}/${ITERATIONS} ----
        

        # Esegui il test singolo e ignora eventuali errori
        ${status}    ${result}=    Run Keyword And Ignore Error    Single Precision Execution    ${file_path}
        Log To Console  ${result}  
        # Incrementa i contatori in base al risultato
        Run Keyword If    '${status}' == 'PASS'    Increment Success Count
        Run Keyword If    '${status}' != 'PASS'    Increment Failure Count
        
        # Se il test è passato, aggiungi il risultato alla lista e aggiorna i totali
        Run Keyword If    '${status}' == 'PASS'    Process Success Result    ${result}
        
        # Stampa stato attuale
        Log To Console    Test passati: ${success_count}, Test falliti: ${failure_count}
        
        # Rimuovi il file extracted.txt se esiste
        Run Keyword And Ignore Error    Remove File    ${RESPONSE_DIR}/extracted.txt

    END
    
    # Calcola medie
    ${avg_duration}=    Evaluate    ${total_duration} / max(1, ${success_count})
    ${avg_tokens}=    Evaluate    ${total_tokens} / max(1, ${success_count})
    ${avg_similarity}=    Evaluate    ${total_similarity} / max(1, ${success_count})
    
    # Crea dizionario con risultati per questo file
    &{file_results}=    Create Dictionary
    ...    file=${test_file}
    ...    total_runs=${ITERATIONS}
    ...    passed=${success_count}
    ...    failed=${failure_count}
    ...    average_duration=${avg_duration}
    ...    average_tokens=${avg_tokens}
    ...    average_similarity=${avg_similarity}
    ...    results=${test_results}
    
    # Salva risultati
    ${json_results}=    Evaluate    json.dumps(${file_results}, indent=4)    json
    Create File    ${output_dir}/risultati.json    ${json_results}
    
    # Crea file di testo riepilogativo
    ${summary_text}=    Catenate    SEPARATOR=\n
    ...    ===== RISULTATI PER ${test_file} =====
    ...    Esecuzioni totali: ${ITERATIONS}
    ...    Test passati: ${success_count}
    ...    Test falliti: ${failure_count}
    ...    Tempo medio: ${avg_duration} secondi
    ...    Token medi: ${avg_tokens}
    ...    Similarità media: ${avg_similarity}
    
    Create File    ${output_dir}/risultati.txt    ${summary_text}
    Log To Console    \n${summary_text}\n
    
    RETURN    ${file_results}

Single Precision Execution
    [Documentation]    Esegue il test singolo e restituisce dizionario con risultati se passa
    [Arguments]        ${file_path}
    ${test_timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${start_time}=    Get Time    epoch
    ${response_text}=    Send Chat Request And Get Response    ${file_path}
    ${end_time}=    Get Time    epoch
    ${duration}=    Evaluate    round(${end_time} - ${start_time}, 2)
    
    # Salva la risposta in un singolo file che verrà sovrascritto ad ogni iterazione
    Create File    ${RESPONSE_DIR}/extracted.txt    ${response_text}
    
    ${token_count}=    Count GPT2 Tokens    ${RESPONSE_DIR}/extracted.txt
    
    IF    $file_path == '${CURDIR}/chatMatrices.robot'
        chatMatrices.Check Key Components    ${response_text}
    
    ELSE IF     $file_path == '${CURDIR}/chatPPTX.robot'
        chatPPTX.Check Key Components    ${response_text}
    
    ELSE IF     $file_path == '${CURDIR}/chatBaseball.robot'
        chatBaseball.Check Key Components    ${response_text}

    ELSE IF     $file_path == '${CURDIR}/chatBook.robot'
        chatBook.Check Key Components    ${response_text}
    
    ELSE IF     $file_path == '${CURDIR}/chatCatafratto.robot'
        chatCatafratto.Check Key Components    ${response_text}
    
    ELSE IF     $file_path == '${CURDIR}/chatDanza.robot'
        chatDanza.Check Key Components    ${response_text}
    
    ELSE IF     $file_path == '${CURDIR}/chatHTML.robot'
        chatHTML.Check Key Components    ${response_text}
   
    ELSE IF     $file_path == '${CURDIR}/chatLLM.robot'
        chatLLM.Check Key Components    ${response_text}
    
    ELSE IF     $file_path == '${CURDIR}/chatMail.robot'
        chatMail.Check Key Components    ${response_text}
    
    ELSE IF     $file_path == '${CURDIR}/chatTecnologia.robot'
        chatTecnologia.Check Key Components    ${response_text}
    
    ELSE IF     $file_path == '${CURDIR}/chatTestiCasuali.robot'
        chatTestiCasuali.Check Key Components    ${response_text}
    
    ELSE IF     $file_path == '${CURDIR}/chatEtabula.robot'
        chatEtabula.Check Key Components    ${response_text}

    ELSE IF     $file_path == '${CURDIR}/chatPrivacy.robot'
        chatPrivacy.Check Key Components    ${response_text}

    ELSE IF     $file_path == '${CURDIR}/chatPrezzi.robot'
        chatPrezzi.Check Key Components    ${response_text}

    ELSE IF     $file_path == '${CURDIR}/chatAnagrafica.robot'
        chatAnagrafica.Check Key Components    ${response_text}
    
    ELSE
        chatCuriosità.Check Key Components    ${response_text}
    
    END    

    ${section_scores}=    Analyze Document By Sections    ${response_text}    ${test_timestamp}     ${file_path}
    ${cumulative_score}=    Calculate Cumulative Score    ${section_scores}

    Run Keyword If    ${cumulative_score} < ${SIMILARITY_THRESHOLD}
    ...    Fail    La risposta non è sufficientemente precisa (score: ${cumulative_score})

    ${metrics}=    Create Dictionary
    ...    response_time=${duration}
    ...    token_count=${token_count}
    ...    similarity=${cumulative_score}
    ...    timestamp=${test_timestamp}
    
    RETURN    ${metrics}

Process Success Result
    [Arguments]    ${metrics}
    # Aggiungi alla lista dei risultati
    Append To List    ${test_results}    ${metrics}
    
    # Aggiorna i totali
    ${current_duration}=    Get Variable Value    ${total_duration}    0
    ${current_tokens}=      Get Variable Value    ${total_tokens}    0
    ${current_similarity}=  Get Variable Value    ${total_similarity}    0
    
    ${new_duration}=     Evaluate    ${current_duration} + ${metrics}[response_time]
    ${new_tokens}=       Evaluate    ${current_tokens} + ${metrics}[token_count]
    ${new_similarity}=   Evaluate    ${current_similarity} + ${metrics}[similarity]
    
    Set Suite Variable    ${total_duration}    ${new_duration}
    Set Suite Variable    ${total_tokens}    ${new_tokens}
    Set Suite Variable    ${total_similarity}    ${new_similarity}

Increment Success Count
    ${current}=    Get Variable Value    ${success_count}    0
    ${new_count}=    Evaluate    ${current} + 1
    Set Suite Variable    ${success_count}    ${new_count}

Increment Failure Count
    ${current}=    Get Variable Value    ${failure_count}    0
    ${new_count}=    Evaluate    ${current} + 1
    Set Suite Variable    ${failure_count}    ${new_count}

Send Chat Request And Get Response
    [Documentation]    Invia la richiesta di chat e ottiene la risposta testuale
    [Arguments]     ${file_path}
    # Prepara header con token di autenticazione

    ${QUERY}=    Estrai Variabile Query Da File    ${file_path}

    ${auth_header}=    Catenate    Bearer    ${ACCESS_TOKEN}
    ${headers}=    Create Dictionary
    ...    Authorization=${auth_header}
    ...    Content-Type=application/json
    ...    Origin=http://localhost:4200
    ...    Referer=http://localhost:4200/
    ...    Accept=*/*
    
    # Prepara payload per la richiesta
    ${assistant_message}=    Create Dictionary
    ...    role=assistant
    ...    content=You can start the conversation by typing your question here.
    
    ${user_message}=    Create Dictionary
    ...    role=user
    ...    content=${QUERY}
    
    ${messages}=    Create List    ${assistant_message}    ${user_message}
    
    # Crea la lista di tag_ids
    @{tag_ids}=    Create List    ${1}    ${2}
    
    ${payload}=    Create Dictionary
    ...    messages=${messages}
    ...    temperature=0.1
    ...    use_web_search=${TRUE}
    ...    use_default_system_prompt=${TRUE}
    ...    custom_system_prompt=${EMPTY}
    ...    include_owned=${TRUE}
    ...    tag_ids=${tag_ids}
    
    # Crea sessione e invia richiesta
    Create Session    chat_session    ${BASE_URL}    verify=True
    ${response}=    POST On Session
    ...    chat_session
    ...    ${INSTALLATION_ENDPOINT}
    ...    json=${payload}
    ...    headers=${headers}
    
    # Verifica status code
    Should Be Equal As Strings    ${response.status_code}    200
    
    # Salva la risposta grezza per analisi
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Create File    ${RESPONSE_DIR}/raw_response.txt    ${response.text}
    
    # Estrai il testo dalla risposta
    ${extracted_text}=    Extract Content Manually    ${response.text}
    
    RETURN    ${extracted_text}

Extract Content Manually
    [Documentation]    Estrazione del contenuto testuale dalla risposta
    [Arguments]    ${response_text}
    
    # Inizializza il risultato
    Set Test Variable    ${full_text}    ${EMPTY}
    
    # Dividi la risposta in righe
    @{lines}=    Split To Lines    ${response_text}
    
    # Per ogni riga che contiene "data:", estrai il contenuto JSON
    FOR    ${line}    IN    @{lines}
        # Verifica se la riga contiene "data:"
        ${has_data}=    Run Keyword And Return Status    
        ...    Should Contain    ${line}    data:
        
        # Se contiene "data:", processa la riga
        Run Keyword If    ${has_data}    
        ...    Process Data Line    ${line}  full_text
    END
    
    # Se non abbiamo estratto nulla, usa la risposta originale
    ${result}=    Set Variable If    $full_text == ''    
    ...    ${response_text}    
    ...    ${full_text}
    
    # Preserva i percorsi con :// sostituendoli temporaneamente
    ${result}=    Replace String    ${result}    ://    __COLON_SLASH_SLASH__
    ${result}=    Replace String    ${result}    :/    __COLON_SLASH__
    ${result}=    Replace String    ${result}    C:\\    C__BACKSLASH__
    
    RETURN    ${result}

Process Data Line
    [Documentation]    Elabora una singola riga di dati stream
    [Arguments]    ${line}    ${result_var}
    
    # Rimuovi il prefisso "data:" e gli spazi
    ${json_part}=    Replace String    ${line}    data:    ${EMPTY}
    ${json_part}=    Strip String    ${json_part}
    
    # Ignora oggetti JSON vuoti
    ${is_empty}=    Run Keyword And Return Status    
    ...    Should Be Equal As Strings    ${json_part}    {}
    
    Return From Keyword If    ${is_empty}
    
    # Prova a fare parsing JSON
    TRY
        ${json_obj}=    Evaluate    json.loads('''${json_part}''')    json
        
        # Verifica se il JSON ha un campo "response"
        ${has_response}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${json_obj}    response
        
        # Se ha un campo "response", aggiungi al risultato
        Run Keyword If    ${has_response}
        ...    Append Response    ${json_obj}[response]    ${result_var}
    EXCEPT
        # In caso di errore, logga e continua
        Log    Errore nel parsing JSON: ${json_part}
    END

Append Response
    [Documentation]    Aggiunge una parte di risposta al risultato
    [Arguments]    ${text}    ${result_var}
    
    ${current}=    Get Variable Value    ${${result_var}}    ${EMPTY}
    ${new_text}=    Set Variable    ${current}${text}
    Set Test Variable    ${${result_var}}    ${new_text}


Analyze Document By Sections
    [Documentation]    Analizza la risposta confrontandola con le sezioni della documentazione
    [Arguments]    ${response_text}    ${timestamp}     ${file_path}
    
    ${response_lower}=    Convert To Lowercase    ${response_text}
    ${results}=    Create Dictionary
    
    Log    ==== ANALISI DETTAGLIATA PER SEZIONI ====    console=yes
    
    IF    $file_path == '${CURDIR}/chatMatrices.robot'
        @{sections}=    Get Matrices Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatPPTX.robot'
        @{sections}=    Get PPTX Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatBaseball.robot'
        @{sections}=    Get BASEBALL Installation Sections

    ELSE IF     $file_path == '${CURDIR}/chatBook.robot'
        @{sections}=    Get BOOK Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatCatafratto.robot'
        @{sections}=    Get CATAFRATTO Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatDanza.robot'
        @{sections}=    Get DANZA Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatHTML.robot'
        @{sections}=    Get HTML Installation Sections
   
    ELSE IF     $file_path == '${CURDIR}/chatLLM.robot'
       @{sections}=    Get LLM Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatMail.robot'
       @{sections}=    Get MAIL Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatTecnologia.robot'
        @{sections}=    Get TEC Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatTestiCasuali.robot'
        @{sections}=    Get TC Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatEtabula.robot'
        @{sections}=    Get ETABULA Installation Sections
    
    ELSE IF     $file_path == '${CURDIR}/chatPrivacy.robot'
        @{sections}=    Get PRIVACY Installation Sections

    ELSE IF     $file_path == '${CURDIR}/chatPrezzi.robot'
        @{sections}=    Get PREZZI Installation Sections

    ELSE IF     $file_path == '${CURDIR}/chatAnagrafica.robot'
        @{sections}=    Get ANAGRAFICA Installation Sections

    ELSE
        @{sections}=    Get CUR Installation Sections
    
    END    
    FOR    ${section_entry}    IN    @{sections}
        Log To Console    \n[DEBUG] Analizzando sezione: '${section_entry}'

        ${section_parts}=    Split String    ${section_entry}    =    1
        ${part_count}=    Get Length    ${section_parts}
        Run Keyword If    ${part_count} != 2    Fail    Sezione malformata: '${section_entry}'

        ${section_name_raw}=    Set Variable    ${section_parts}[0]
        ${section_content}=    Set Variable    ${section_parts}[1]

        @{section_elements}=    Split String    ${section_content}    |

        ${is_or_section}=    Run Keyword And Return Status    Should Contain    ${section_name_raw}    ||
        ${section_name}=    Replace String    ${section_name_raw}    ||    ''
        
        IF    ${is_or_section}
            ${section_score}=    Analyze Section Elements OR    ${response_lower}    ${section_name_raw}    ${section_elements}
        ELSE
            ${section_score}=    Analyze Section Elements    ${response_lower}    ${section_name_raw}    ${section_elements}
        END


        Set To Dictionary    ${results}    ${section_name}=${section_score}
    END

    RETURN    ${results}

Analyze Section Elements OR
    [Arguments]    ${response_text}    ${section_name}    ${section_elements}

    ${total_elements}=    Get Length    ${section_elements}
    ${found_elements}=    Set Variable    ${0}
    
    Log    \nSezione (OR): ${section_name}    console=yes

    FOR    ${element}    IN    @{section_elements}
        ${element}=    Strip String    ${element}
        ${element_lower}=    Convert To Lowercase    ${element}

        ${score}=    Calculate Element Similarity    ${response_text}    ${element_lower}

        ${element_found}=    Set Variable If    ${score} >= ${SIMILARITY_THRESHOLD}    ${TRUE}    ${FALSE}
        ${status}=    Set Variable If    ${element_found}    TROVATO    MANCANTE
        Log    - Elemento "${element}": ${score} [${status}]    console=yes

        ${found_increment}=    Set Variable If    ${element_found}    ${1}    ${0}
        ${found_elements}=    Evaluate    ${found_elements} + ${found_increment}
    END

    # Sezione OR: se almeno un elemento è presente, allora score = 1, altrimenti 0
    ${section_score}=    Set Variable If    ${found_elements} > 0    1.0    0.0
    Log    Punteggio sezione (OR) "${section_name}": ${section_score}    console=yes

    RETURN    ${section_score}


Analyze Section Elements 
    [Documentation]    Analizza gli elementi di una sezione e calcola il punteggio
    [Arguments]    ${response_text}    ${section_name}    ${section_elements}
    
    ${total_elements}=    Get Length    ${section_elements}
    ${found_elements}=    Set Variable    ${0}
    ${element_scores}=    Create Dictionary
    
    Log    \nSezione: ${section_name}    console=yes
    
    # Per ogni elemento della sezione
    FOR    ${element}    IN    @{section_elements}
        ${element}=    Strip String    ${element}
        ${element_lower}=    Convert To Lowercase    ${element}
        
        # Calcola similarità con questo elemento
        ${score}=    Calculate Element Similarity    ${response_text}    ${element_lower}
        Set To Dictionary    ${element_scores}    ${element}=${score}
        
        # Se il punteggio è superiore alla soglia, l'elemento è presente
        ${element_found}=    Set Variable If    ${score} >= ${SIMILARITY_THRESHOLD}    ${TRUE}    ${FALSE}
        ${found_increment}=    Set Variable If    ${element_found}    ${1}    ${0}
        ${found_elements}=    Evaluate    ${found_elements} + ${found_increment}
        
        # Visualizza risultato per questo elemento
        ${status}=    Set Variable If    ${element_found}    TROVATO    MANCANTE
        Log    - Elemento "${element}": ${score} [${status}]    console=yes
    END
    
    # Calcola punteggio complessivo della sezione
    ${section_score}=    Evaluate    ${found_elements} / ${total_elements}
    Log    Punteggio sezione "${section_name}": ${section_score}    console=yes
    
    RETURN    ${section_score}

Calculate Element Similarity
    [Documentation]    Calcola la similarità tra un elemento e la risposta
    [Arguments]    ${response_text}    ${element_text}
    
    # Estrai le parole chiave dall'elemento
    @{stop_words}=    Create List    il    la    i    gli    le    e    o    a    di    da    in    per    con    su    del    della    dei    degli    delle
    @{element_words}=    Split String    ${element_text}
    @{keywords}=    Create List
    
    # Filtra le stop words e parole troppo corte
    FOR    ${word}    IN    @{element_words}
        ${is_stop_word}=    Run Keyword And Return Status    List Should Contain Value    ${stop_words}    ${word}
        ${word_length}=    Get Length    ${word}
        ${is_short}=    Evaluate    ${word_length} <= 0
        ${should_include}=    Evaluate    not ${is_stop_word} and not ${is_short}
        Run Keyword If    ${should_include}    Append To List    ${keywords}    ${word}
    END
    
    # Conta quante parole chiave sono presenti nella risposta
    ${found_count}=    Set Variable    ${0}
    ${total_keywords}=    Get Length    ${keywords}
    
    FOR    ${keyword}    IN    @{keywords}
        ${contains}=    Run Keyword And Return Status    Should Contain    ${response_text}    ${keyword}
        ${increment}=    Set Variable If    ${contains}    ${1}    ${0}
        ${found_count}=    Evaluate    ${found_count} + ${increment}
    END
    
    # Se non ci sono parole chiave, assegna punteggio 0
    ${similarity_score}=    Set Variable If    ${total_keywords} == 0    
    ...    ${0.0}    
    ...    ${found_count / ${total_keywords}}
    
    # Ripristina i simboli originali nei percorsi
    ${restored_element_text}=    Replace String    ${element_text}    __COLON_SLASH_SLASH__    ://
    ${restored_element_text}=    Replace String    ${restored_element_text}    __COLON_SLASH__    :/
    ${restored_element_text}=    Replace String    ${restored_element_text}    __BACKSLASH__    \\
    
    RETURN    ${similarity_score}

Calculate Cumulative Score
    [Documentation]    Calcola il punteggio cumulativo di similarità
    [Arguments]    ${section_scores}
    
    ${total_score}=    Set Variable    ${0}
    ${num_sections}=    Get Length    ${section_scores}
    
    # Somma i punteggi di tutte le sezioni
    FOR    ${section_name}    ${score}    IN    &{section_scores}
        ${total_score}=    Evaluate    ${total_score} + ${score}
    END
    
    # Calcola la media
    ${cumulative_score}=    Evaluate    ${total_score} / ${num_sections}
    
    RETURN    ${cumulative_score}

Count GPT2 Tokens
    [Documentation]    Conta i token GPT-2 in un file
    [Arguments]    ${RESPONSE_DIR}
    
    # Chiama il metodo Python
    ${token_count}=    TokenCounter.Count Tokens In File    ${RESPONSE_DIR}
    
    RETURN    ${token_count}

Estrai Variabile Query Da File
    [Arguments]    ${file_path}
    ${contenuto}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${contenuto}
    ${query}=    Set Variable    NONE

    FOR    ${line}    IN    @{lines}
        ${starts_with_dollar}=    Evaluate    $line.startswith('$')
        ${line_without_dollar}=    Set Variable If    ${starts_with_dollar}    ${line[2:]}    ${line}

        ${is_query}=    Evaluate    $line_without_dollar.startswith("QUERY")
        ${is_query}=    Run Keyword And Return Status    Should Be True    ${is_query}
        IF     ${is_query}   
            ${query}=    Evaluate    $line.split('}', 1)[1].strip()
        END

        Run Keyword If    "${query}" != "NONE"    Exit For Loop
    END

    Run Keyword If    "${query}" == "NONE"    Fail    Nessuna QUERY trovata nel file: ${file_path}
    RETURN    ${query}


Create Summary Report
    [Documentation]    Crea un report riepilogativo di tutti i test eseguiti
    [Arguments]    ${file_results}    ${total_success}    ${total_failure}    ${total_duration}    ${total_tokens}    ${total_similarity}
    
    # Calcola le medie complessive
    ${total_tests}=    Evaluate    ${total_success} + ${total_failure}
    ${avg_duration}=    Evaluate    ${total_duration} / max(1, ${total_success})
    ${avg_tokens}=    Evaluate    ${total_tokens} / max(1, ${total_success})
    ${avg_similarity}=    Evaluate    ${total_similarity} / max(1, ${total_success})
    
    # Crea directory per il report finale se non esiste
    Create Directory    ${MAIN_OUTPUT_DIR}
    
    # Crea il testo del report
    ${summary_text}=    Catenate    SEPARATOR=\n
    ...    ===== RIEPILOGO FINALE DI TUTTI I TEST =====
    ...    Data esecuzione: ${TIMESTAMP}
    ...    Numero totale di file testati: ${file_results.__len__()}
    ...    Esecuzioni totali: ${total_tests}
    ...    Test passati: ${total_success}
    ...    Test falliti: ${total_failure}
    ...    Tempo medio complessivo: ${avg_duration} secondi
    ...    Token medi complessivi: ${avg_tokens}
    ...    Similarità media complessiva: ${avg_similarity}
    ...    \n
    ...    ----- DETTAGLIO PER FILE -----
    
    # Aggiungi dettagli per ogni file
    FOR    ${result}    IN    @{file_results}
        ${file_detail}=    Catenate    SEPARATOR=\n
        ...    \nFile: ${result}[file]
        ...    Esecuzioni: ${result}[total_runs]
        ...    Passati: ${result}[passed]
        ...    Falliti: ${result}[failed]
        ...    Tempo medio: ${result}[average_duration] secondi
        ...    Token medi: ${result}[average_tokens]
        ...    Similarità media: ${result}[average_similarity]
        
        ${summary_text}=    Catenate    SEPARATOR=\n    ${summary_text}    ${file_detail}
    END
    
    # Crea anche un file JSON con i risultati
    &{summary_dict}=    Create Dictionary
    ...    timestamp=${timestamp}
    ...    total_files=${file_results.__len__()}
    ...    total_tests=${total_tests}
    ...    passed=${total_success}
    ...    failed=${total_failure}
    ...    average_duration=${avg_duration}
    ...    average_tokens=${avg_tokens}
    ...    average_similarity=${avg_similarity}
    ...    file_details=${file_results}
    
    ${json_summary}=    Evaluate    json.dumps(${summary_dict}, indent=4)    json
    Create File    ${MAIN_OUTPUT_DIR}/riepilogo_finale_${timestamp}.json    ${json_summary}
    
    # Log del riepilogo
    Log To Console    \n${summary_text}
    Log To Console    \nReport salvato in: ${MAIN_OUTPUT_DIR}/riepilogo_finale_${timestamp}.txt