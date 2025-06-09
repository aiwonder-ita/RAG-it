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
${QUERY}    come si installa etabula? leggi dalla knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}    
...    Procedura d'installazione
...    Connettersi al Server del cliente con Connessione Desktop Remoto(MSTSC)
...    Creare le cartelle C:\\scao (qui avremo il software necessario all'utente) e C:\\scao\\setup (qui copieremo tutti i file d'installazione ed info varie del cliente)
...    Installazione NodeJs, Visual Studio Code, 7zip e Chrome. Procedere alle installazioni dei rispettivi file .exe
...    Per Visual Studio Code, durante l'installazione abilitare le checkbox riguardanti "apri con visual studio code".
...    Installare Internet Information Services (IIS)
...    Installazione PM2
...    Installare RabbitMQ
...    Installare eTabula
...    Di seguito si elencano i passi principali per l'installazione di eTabula:
...    1. Copiare le cartelle client e server dell'ultima versione di etabula da \\main5\\Prodotti_scao\\e-tabula2 sotto: C:\\inetpub\\wwwroot\\eTabula (NOTA: copiare il file .zip sul desktop e poi estrarlo in C:\\inetpub\\wwwroot\\eTabula così evito problemi con i permessi).
...    2. Sotto la cartella server, modificare il file appsettings.json come indicato nella sezione "File di configurazione -> Server (appsettings.json)"
...    3. Sotto la cartella client C:\\inetpub\\wwwroot\\eTabula\\client\\assets modificare il file config.json modificando appositamente gli url a http://IPxx:porta_libera/server/ quindi l'IP, una porta libera del sito web su cui installeremo etabula (dovrebbe essere libera la 9090) quindi aggiungere "/server" agli url in quanto il server si trova sotto l'applicazione server del sito IIS dove risiede il client. Se è libera la porta 80 posso utilizzare anche quella e quindi poi non sarà più necessario specificarla in quanto è quella di default.
...    4. Da IIS andare su Siti-> Aggiungi sito web -> settando nome:etabula, puntare alla cartella del client e porta 9090 (se libera), successivamente dal sito etabula creare una nuova applicazione facendo "Aggiungi applicazione" mettendo come alias: "server" e puntando al percorso fisico della cartella "C:\\inetpub\\wwwroot\\eTabula\\server"; dalle impostazioni avanzate del Pool di applicazioni -> etabula -> tasto dx->impostazioni avanzate e impostare correttamente i parametri.
...    5. In caso di Virtual Directory per accedere ad una cartella esterna di file contenente ad es. .pdf, dal sito IIS di etabula andare sotto "Directory Browsing" o "Esplorazione Directory" e fare enable dal pannello a dx.
...    6. Modificare i permessi all'intera cartella C:\\inetpub\\wwwroot\\eTabula facendo -> tasto dx-> proprietà -> protezione ed aggiungere l'utente IIS_IUSRS impostando il controllo completo.
...    7. Dal browser Chrome accedere al sistema tramite l'url: http://localhost:9090/ ed inserire per il primo accesso il codice licenza di attivazione per registrare eTabula.
...    8. In caso di errore su file non accessibile verificare i permessi.

# Suddivisione in sezioni della procedura per analisi dettagliata
@{INSTALLATION_SECTIONS_ETABULA}
...    Connessione e preparazione=Connettersi al Server del cliente con Connessione Desktop Remoto(MSTSC)|Creare le cartelle C:\\scao|C:\\scao\\setup
...    Software preliminari=Installazione NodeJs|Visual Studio Code|7zip|Chrome
...    Componenti sistema=Installare Internet Information Services (IIS)|Installazione PM2|Installare RabbitMQ
...    Installazione eTabula=Copiare le cartelle client e server|modificare il file appsettings.json|modificare il file config.json|Aggiungi sito web|Aggiungi applicazione|Virtual Directory|Modificare i permessi|accedere al sistema tramite l'url|inserire il codice licenza

*** Keywords ***


Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
    
    Should Contain    ${text_lower}    nodejs
    ...    msg=Manca NodeJs nella procedura di installazione
    
    Should Contain    ${text_lower}    iis
    ...    msg=Manca IIS nella procedura di installazione
    
    Should Contain    ${text_lower}    pm2
    ...    msg=Manca PM2 nella procedura di installazione
    
    Should Contain    ${text_lower}    rabbitmq
    ...    msg=Manca RabbitMQ nella procedura di installazione
    
    Should Contain    ${text_lower}    etabula
    ...    msg=Manca eTabula nella procedura di installazione


Get ETABULA Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_ETABULA}

