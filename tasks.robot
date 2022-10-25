*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
# Library    RPA.SAP


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the pop-up
    Download and read the file
    Make order using csv data


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the pop-up
    Click Button When Visible    //button[@class="btn btn-dark"]

Download and read the file
    Download    https://robotsparebinindustries.com/orders.csv

Check order status
    FOR    ${i}    IN RANGE    100
        ${order_status}=    Is Element Visible    //div[@class="alert alert-danger"]
        IF    '${order_status}'=='True'    Click Button    //button[@id="order"]
        IF    '${order_status}'=='False'            BREAK
    END

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
    Wait Until Page Contains Element    id:order-another
    Click Button    id:order-another
    Close the pop-up

Make order using csv data
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${order}    IN    @{orders}
        Make one order at a time    ${order}
    END
