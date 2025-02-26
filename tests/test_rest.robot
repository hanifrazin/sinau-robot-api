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
Login as Auth - CreateToken
    ${code}    Authenticate as Admin
    Set Suite Variable    ${token}    ${code} 
    Log    ${token}       


Get Bookings from Restful Booker as GetBookingIds
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
            IF    ${var} == 5
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

Get Specific Booking by ID as Get Booking
    Log To Console    \n\tNilai Token adalah ${token}
    ${url}    Set Variable    ${baseUrl}/booking/${id}
    Log    ${url}
    ${response}    GET    ${url}    
    Status Should Be    200
    Should Be Equal    ${response.json()}[lastname]   Gruber
    Log    ${response.json()}[lastname]
    Should Be Equal    ${response.json()}[firstname]   Hans
    Log    ${response.json()}[firstname]   
    Should Be Equal As Numbers    ${response.json()}[totalprice]    200

Update Booking
    Log To Console    \n\t${token}
    ${header}    Create Dictionary    Content-Type=application/json    Accept=application/json    Cookie=token=${token}
    ${booking_dates}    Create Dictionary    checkin=2024-12-01    checkout=2024-12-25
    ${body}    Create Dictionary    firstname=Hario    lastname=Wicaksono    totalprice=10000000    depositpaid=true    bookingdates=${booking_dates}
    ${response}    PUT    url=${baseUrl}/booking/${id}    headers=${header}    json=${body}
    Status Should Be    200
    Should Be Equal    ${response.json()}[lastname]   Wicaksono
    Log    ${response.json()}[lastname]
    Should Be Equal    ${response.json()}[firstname]   Hario
    Log    ${response.json()}[firstname]   
    Should Be Equal As Numbers    ${response.json()}[totalprice]    10000000
    Should be True     ${response.json()}[depositpaid]    true
    

Partial Update Booking
    Log To Console    \n\t${token}
    ${header}    Create Dictionary    Content-Type=application/json    Accept=application/json    Cookie=token=${token}
    ${booking_dates}    Create Dictionary    checkin=2024-12-01    checkout=2024-12-25
    ${body}    Create Dictionary    lastname=Kalita
    ${response}    PATCH    url=${baseUrl}/booking/${id}    headers=${header}    json=${body}
    Status Should Be    200
    Should Be Equal    ${response.json()}[lastname]   Kalita
    Log    ${response.json()}[lastname]
    Should Be Equal    ${response.json()}[firstname]   Hario
    Log    ${response.json()}[firstname]   
    Should Be Equal As Numbers    ${response.json()}[totalprice]    10000000
    Should be True     ${response.json()}[depositpaid]    true 

Delete Booking
    Log To Console    \n\t${token}
    ${header}    Create Dictionary    Content-Type=application/json    Cookie=token=${token}
    ${response}    DELETE    url=${baseUrl}/booking/${id}    headers=${header}   
    Status Should Be    201    ${response}