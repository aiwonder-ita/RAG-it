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
${QUERY}    Nell'esercizio 2 della professoressa maggioni dimmi cos'è B^-1? leggi dalla knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    Nell’esercizio 2 viene riscritto il problema in forma standard con 3 vincoli.
...    Si sceglie come base iniziale quella associata alle variabili s1, s2, s3, quindi B uguale I.
...    In questo caso, B⁻¹ è la matrice identità.
...    Successivamente, dopo uno step del simplesso, la base B cambia.
...    Si calcola la nuova B⁻¹ come l’inversa della nuova matrice base.
...    In quel passaggio, B⁻¹ è:
...    [ 0   1/2   0 ]
...    [ 1  -1/2   0 ]
...    [ 0    0    1 ]

@{INSTALLATION_SECTIONS_MATRICES}=
...    Applicazione del simplesso=variabile entra e lascia la base|nuova base B
...    Calcolo della nuova B⁻¹=inversa della nuova base
...    Nuova matrice ||= frac{1}{2} & -frac{1}{2} & 0|1/2 -1/2 0|1 -1/2 0|1 & -frac{1}{2} & 0


*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
        

    Should Contain    ${text_lower}    inversa
    ...    msg=Manca il concetto di B⁻¹ come inversa della matrice base

    Should Match Regexp    ${text_lower}    b\\^{-1}|b\\^-1|b-1|b\\^\\(-1\\)|b⁻¹
    ...    msg=Non viene esplicitato B⁻¹ nel testo della risposta


    
    Should Match Regexp    ${text_lower}    .*0.*1.*0.*frac\\{1\\}\\{2\\}.*-frac\\{1\\}\\{2\\}.*0.*0.*0.*1.*|.*0.*1.*0.*1/2.*-1/2.*0.*0.*0.*1.*|.*0.*frac\\{1\\}\\{2\\}.*0.*1.*-frac\\{1\\}\\{2\\}.*0.*0.*0.*1.*|.*0.*1/2.*0.*1.*-1/2.*0.*0.*0.*1.*
    ...    msg = Non viene esplicitata la matrice risultato



Get Matrices Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_MATRICES}

