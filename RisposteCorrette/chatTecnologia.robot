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
${QUERY}    negli ultimi decenni cosa ha trasformato la tecnologia? leggi nella knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    Negli ultimi decenni, la tecnologia ha trasformato radicalmente il nostro modo di vivere, lavorare e comunicare.
...    L'avvento di Internet, l'automazione industriale e l'intelligenza artificiale hanno portato benefici significativi, ma anche nuove sfide.
...    Uno degli aspetti più evidenti è la digitalizzazione del lavoro.
...    Molti compiti che un tempo richiedevano l'intervento umano sono ora automatizzati, migliorando l'efficienza ma sollevando preoccupazioni riguardo alla perdita di posti di lavoro.
...    Allo stesso tempo, si sono create nuove opportunità in settori come la programmazione, la robotica e la gestione dei dati.
...    Anche la comunicazione ha subito un'evoluzione senza precedenti.
...    Grazie ai social media e alle piattaforme di messaggistica istantanea, le persone possono connettersi in tempo reale indipendentemente dalla distanza geografica.
...    Tuttavia, questa iperconnessione solleva questioni sulla privacy, sulla dipendenza tecnologica e sulla diffusione di informazioni false.
...    Infine, l'innovazione tecnologica ha avuto un impatto significativo sulla medicina.
...    La telemedicina, la stampa 3D per protesi avanzate e l'uso dell'intelligenza artificiale nella diagnosi medica stanno rivoluzionando il settore sanitario, migliorando la qualità della vita di milioni di persone.


@{INSTALLATION_SECTIONS_TEC}
...    Impatto generale=trasformato radicalmente il nostro modo di vivere|lavorare|comunicare
...    Innovazioni chiave=Internet|automazione industriale|intelligenza artificiale
...    Digitalizzazione del lavoro=automatizzati|perdita di posti di lavoro|nuove opportunità|programmazione|robotica|gestione dei dati
...    Comunicazione moderna=social media|messaggistica istantanea|iperconnessione|privacy|informazioni false
...    Innovazione medica=telemedicina|stampa 3D|protesi avanzate|diagnosi medica|qualità della vita


*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
    
    Should Contain    ${text_lower}    vivere
    ...    msg=Manca il riferimento alla trasformazione del modo di vivere

    Should Contain    ${text_lower}    lavorare
    ...    msg=Manca il riferimento alla trasformazione del modo di lavorare

    Should Contain    ${text_lower}    comunicare
    ...    msg=Manca il riferimento alla trasformazione del modo di comunicare

Get TEC Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_TEC}

