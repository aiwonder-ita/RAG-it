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
${QUERY}    Perchè dovrmmo seguire corsi sugli LLM leggendo nella knowledge base?
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    In ottica di quello che ci siamo detti ho visto che ci sono delle ottime risorse di formazione su Hugging Face Learn.
...    Partirei con il NLP COURSE che dà una base importante di come funzionano i vari LLM, ed è un corso hands-on.
...    Nel giro di poco, con le competenze già presenti in ML, si arriverà a un buon livello di autonomia.
...    È utile usare la documentazione in inglese, ogni pagina ha la versione PyTorch o TensorFlow.
...    Hugging Face dice che sotto sotto tutto viene trasformato in un tensore.
...    Si consiglia di concentrarsi su famiglie di modelli (encoder, decoder), fine-tuning di un pretrained, LoRA, tokenizer, head.
...    Questo servirà anche al lavoro di testing per capire meglio gli output ottenuti.
...    Seguendo i corsi si capisce anche come funziona un RAG e il trade-off tra dimensioni dei chunk e precisione.

@{INSTALLATION_SECTIONS_LLM}
...    Obiettivi=autonomia|competenze ML|testing
...    Argomenti tecnici=encoder|decoder|fine-tuning|tokenizer
...    Documentazione=PyTorch|TensorFlow
...    RAG e chunk=funzionamento di un RAG


*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
    

    Should Contain    ${text_lower}    llm
    ...    msg=Manca il riferimento agli LLM

    Should Contain    ${text_lower}    rag
    ...    msg=Manca il riferimento a RAG

    Should Contain    ${text_lower}    consulenza
    ...    msg=Manca il riferimento alla consulenza

Get LLM Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_LLM}

