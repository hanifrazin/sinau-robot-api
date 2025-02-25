*** Settings ***
Library    RequestsLibrary

*** Keywords ***
Authenticate as Admin
    ${body}    Create Dictionary    username=admin    password=password123
    ${response}    POST    url=https://restful-booker.herokuapp.com/auth    json=${body}
    Log    ${response.json()}
    ${token}    Set Variable    ${response.json()}[token]
    RETURN    ${token}

Create Query String
    [Arguments]    ${dictionary}
    ${query_string}    Set Variable    ${EMPTY}
    FOR    ${key}    ${value}    IN    &{dictionary}
        ${query_string}    Set Variable    ${query_string}&${key}=${value}
        ${query_string}    Set Variable    ${query_string}    ${query_string}[1:]  # Remove leading '&'
    END
    RETURN    ${query_string}