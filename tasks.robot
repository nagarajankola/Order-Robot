*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocloud.Secrets


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the pop-up
    Download and read the file
    Make order using csv data
    [Teardown]    Close Browser


*** Keywords ***
Open the robot order website
    ${secret}=    Get Secret    roboSpareBin
    Open Available Browser    ${secret}[siteLink]

Close the pop-up
    Click Button When Visible    //button[@class="btn btn-dark"]

Download and read the file
    Add text input    link    label=Please provide the link to csv file
    ${result}=    Run dialog
    Download    ${result}[link]

Check order status
    FOR    ${i}    IN RANGE    100
        ${order_status}=    Is Element Visible    //div[@class="alert alert-danger"]
        IF    '${order_status}'=='True'    Click Button    //button[@id="order"]
        IF    '${order_status}'=='False'            BREAK
    END

Create receipt for the order
    [Arguments]    ${order_details}
    ${order_receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt}    ${OUTPUT_DIR}${/}output${/}receipts${/}receipt${order_details}[Order number].pdf
    Capture Element Screenshot
    ...    id:robot-preview-image
    ...    ${OUTPUT_DIR}${/}output${/}screenshots${/}robot${order_details}[Order number].png
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}output${/}screenshots${/}robot${order_details}[Order number].png
    ...    ${OUTPUT_DIR}${/}output${/}receipts${/}receipt${order_details}[Order number].pdf
    ...    ${OUTPUT_DIR}${/}output${/}receipts${/}receipt${order_details}[Order number].pdf

Make one order at a time
    [Arguments]    ${order_details}
    Select From List By Value    head    ${order_details}[Head]
    Select Radio Button    body    ${order_details}[Body]
    Input Text    //input[@placeholder="Enter the part number for the legs"]    ${order_details}[Legs]
    Input Text    address    ${order_details}[Address]
    Click Button    id:preview
    Wait Until Page Contains Element    id:robot-preview-image
    Click Button    id:order
    Check order status
    Create receipt for the order    ${order_details}
    Wait Until Page Contains Element    id:order-another
    Click Button    id:order-another
    Close the pop-up

Create zip file of all the order receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}output${/}receipts    ${OUTPUT_DIR}${/}output${/}robot_orders.zip

Make order using csv data
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${order}    IN    @{orders}
        Make one order at a time    ${order}
    END
    Create zip file of all the order receipts
