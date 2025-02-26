*** Settings ***
Library    RequestsLibrary
Library    Collections
Resource    ../resources/keywords.resource

*** Variables ***
${token}    123abc123abc
${id}    1950
${baseUrl}    https://restful-booker.herokuapp.com
${firstName}    John


*** Test Cases ***
Login
    ${code}    Authenticate as Admin
    Set Suite Variable    ${token}    ${code} 
    Log    ${token}       


Get Bookings from Restful Booker
    Log To Console    \n\tNilai Token adalah ${token}
    ${url}    Set Variable    ${baseUrl}/booking?firstname=${firstName}
    Log    ${url}
    ${response}    GET    ${url}    
    Status Should Be    200
    Log    ${response}
    FOR    ${index}    ${booking}    IN ENUMERATE    @{response.json()}
        ${var}=    Evaluate    ${index} + 1 
        ${response}    GET    ${baseUrl}/booking/${booking}[bookingid]
        TRY
            Log    ${response.json()}
            IF    ${var} == 10
                Exit For Loop
            END
        EXCEPT
            Log    Cannot retrieve JSON due to invalid data
        END
        
        
        
    END

Create a Booking at Restful Booker
    ${booking_dates}    Create Dictionary    checkin=2022-12-31    checkout=2023-01-01
    ${body}    Create Dictionary    firstname=Hans    lastname=Gruber    totalprice=200    depositpaid=false    bookingdates=${booking_dates}
    ${response}    POST    url=${baseUrl}/booking    json=${body}
    Log    ${response.json()}[bookingid]
    ${bookingId}    Set Variable    ${response.json()}[bookingid]
    Set Suite Variable    ${id}    ${bookingId}
    &{booking}    Set Variable    ${response.json()}[booking]
    Should Be Equal    ${booking}[lastname]   Gruber
    Log    ${booking}[lastname]
    Should Be Equal    ${booking}[firstname]   Hans
    Log    ${booking}[firstname]   
    Should Be Equal As Numbers    ${booking}[totalprice]    200
    # Dictionary Should Contain Value     ${booking}    2022-12-31

Delete Booking
    Log To Console    \n\t${token}
    ${header}    Create Dictionary    Content-Type=application/json    Cookie=token=${token}
    ${response}    DELETE    url=${baseUrl}/booking/${id}    headers=${header}   
    Status Should Be    201    ${response}