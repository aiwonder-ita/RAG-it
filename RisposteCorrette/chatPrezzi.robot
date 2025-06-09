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
${QUERY}    sai quanto costa un trancio di pizza? leggi nella knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    LISTINO PREZZI
...    CAFFETTERIA                                Base di gara proposta
...    CAFFE' ESPRESSO                                    €
...    CAFFE' BRASILIANO O MAROCCHINO                     € 1,50
...    CAFFE' FREDDO                                      € 1,10
...    CAFFE' GINSENG                                     €
...    CAPPUCCINO                                         €
...    CAPPUCCINO FREDDO (min. 20 cl)                     € 1,30
...    LATTE BIANCO (min. 20 cl)                          € 0,95
...    CAFFE' LATTE (min. 20 cl )                         €
...    CAFFE' LATTE FREDDO (min. 20 cl)                   €
...    CAFFE' D'ORZO                                      €
...    CAPPUCCINO D'ORZO                                  € 1,30
...    CAFFE' DECAFFEINATO                                €
...    CAPPUCCINO CON CAFFE' DECAFFEINATO                 €
...    CIOCCOLATA IN TAZZA                                € 1,75
...    THE E CAMOMILLA (TAZZA)                            €
...    THE FREDDO (min. 20 cl)                            € 1,40
...    THE CON LATTE (min 20 cl)                          € 1,40
...    INFUSI VARI (TAZZA)                                €
...    CREMA AL CAFFE'                                    € 2,70
...    BEVANDE
...    SUCCHI DI FRUTTA IN BARATTOLO 200 ML               €
...    BEVANDE GASSATE IN BOTTIGLIA                       € 1,70
...    SPREMUTA DI ARANCIA                                €
...    CENTRIFUGHE FRESCHE VARI GUSTI (min. 20 cl)        € 2,50
...    ACQUA MINERALE IN BICCHIERE (min. 20 cl)           € 0,35
...    1/2 LITRO DI ACQUA MINERALE                        €
...    1 E 1/2 LITRO DI ACQUA MINERALE                    €
...    BIBITE IN LATTINA                                  € 2,10
...    BIBITE VARIE IN BICCHIERE (min. 20 cl)             € 1,70
...    FRULLATI DI FRUTTA DI STAGIONE                     € 2,85
...    SCIROPPI VARI                                      € 1,75
...    DOLCI/DESSERT
...    CROISSANT, BRIOCHES, LIEVITI                              €
...    MINI: CROISSANT, BRIOCHES, LIEVITI E PASTE ASSORTITE      € 0,60
...    CORNETTI INTEGRALI E BRIOCHES/CROISSANT RIPIENI           € 1,00
...    PASTE ASSORTITE                                           € 1,20
...    FETTA DI CROSTATA O CIAMBELLONE                           € 1,60
...    FETTA DI TORTA                                            € 2,10
...    YOGURT (min. gr. 125)                                     € 2,00
...    FRUTTA FRESCA/MACEDONIA (PORZIONE)                        € 3,40
...    GASTRONOMIA
...    PANINO (TUTTI - MIN. 100 GR.) CON FARCITURA MIN. 30 GR.   € 3,10
...    PANINO (TTTI - MIN. 100 GR.) CON FARCITURA MIN. 50 GR.    € 3,25
...    TRAMEZZINO                                                € 1,80
...    TRAMEZZINI CON DOPPIA FARCITURA                           € 2,30
...    TOAST                                                     € 2,50
...    TOAST CON DOPPIA FARCITURA                                € 2,80
...    PIADINA                                                   € 3,30
...    PIZZA BIANCA FARCITA                                      € 2,70
...    TRANCIO PIZZA                                             € 3,20
...    INSALATONA (contorno doppio + uova/carne/pesce/formaggio) € 4,50
...    PIATTO UNICO (TIPO CAPRESE ECC.)                          € 5,00
...    PIATTO SALUMI E FORMAGGI                                  € 5,00
...    PRIMO PIATTO (CALDO O FREDDO)                             € 4,50
...    SECONDO PIATTO DI CARNE CON CONTORNO                      € 6,50
...    SECONDO PIATTO DI PESCE CON CONTORNO                      € 6,50
...    PIATTO SOLO CONTORNO                                      € 3,00
...    APERITIVI E LIQUORI GRADAZIONE MAX 21°
...    APERITIVI ANALCOLICI                                      € 2,00
...    APERTIVI ALCOLICI                                         € 2,20
...    PROSECCO SPUMANTE                                         € 2,50
...    LIQUORI NAZIONALI                                         € 2,20
...    LIQUORI ESTERI                                            € 3,10



@{INSTALLATION_SECTIONS_PREZZI}
...    Prezzo=trancio di pizza|3,20


*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}

    ${text_lower}=    Convert To Lowercase    ${text}
    
    Should Contain     ${text_lower}        3,20
    ...    msg=Manca la corretta informazione sul prezzo
  

Get PREZZI Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_PREZZI}

