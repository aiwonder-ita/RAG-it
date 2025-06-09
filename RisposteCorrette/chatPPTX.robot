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
${QUERY}    che CNN sono stati usati per la diagnostica dell'azheimers's? leggi dalla knowledge base
${OUTPUT_DIR}    ${CURDIR}/output
${SIMILARITY_THRESHOLD}    0.65    # Soglia di similarità

${FULL_PROCEDURE}
...    Le reti neurali convoluzionali (CNN) sono state utilizzate per la diagnosi dell'Alzheimer.
...    Sono stati usati diversi modelli pre-addestrati: ResNet, VGG16, InceptionV3, MobileNet ed EfficientNet.
...    I dati erano immagini cerebrali (6400) suddivise in 4 classi cliniche: NonDemented, VeryMildDemented, MildDemented, ModerateDemented.
...    Per bilanciare il dataset, è stato anche creato un set binario: Sick / Not Sick.
...    Sono state usate tecniche di **data augmentation** come SMOTE per migliorare le performance dei modelli.
...    Il modello che ha performato meglio è stato **MobileNet con data augmentation**.
...    È stato inoltre utilizzato **Grad-CAM** per interpretare visivamente le decisioni del modello.


@{INSTALLATION_SECTIONS_PPTX}
...    Utilizzo CNN=diagnosi Alzheimer|modelli pre-addestrati|CNN
...    Modelli usati=ResNet|VGG16|InceptionV3|MobileNet|EfficientNet
...    Tecniche=Data augmentation



*** Keywords ***

Check Key Components
    [Documentation]    Verifica la presenza di componenti chiave nella risposta
    [Arguments]    ${text}
    
    ${text_lower}=    Convert To Lowercase    ${text}
        

    Should Contain    ${text_lower}    cnn
    ...    msg=Manca il riferimento alle reti neurali convoluzionali (CNN)

    Should Contain    ${text_lower}    alzheimer
    ...    msg=Manca il riferimento alla diagnosi dell'Alzheimer

    Should Contain    ${text_lower}    resnet
    ...    msg=Manca il riferimento al modello ResNet

    Should Contain    ${text_lower}    vgg16
    ...    msg=Manca il riferimento al modello VGG16
    
    Should Contain    ${text_lower}    inceptionv3
    ...    msg=Manca il riferimento al modello InceptionV3
    
    Should Contain    ${text_lower}    mobilenet
    ...    msg=Manca il riferimento al modello MobileNet
    
    Should Contain    ${text_lower}    efficientnet
    ...    msg=Manca il riferimento al modello EfficientNet
    

Get PPTX Installation Sections
    RETURN    @{INSTALLATION_SECTIONS_PPTX}

