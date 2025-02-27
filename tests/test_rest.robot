*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    Screenshot

*** Variables ***
${token}    123abc123abc
${id}    1950
${baseUrl}    https://restful-booker.herokuapp.com
&{names}    firstname=John


*** Test Cases ***
Login as Auth - CreateToken
    [Documentation]    Mulai Login untuk Autentikasi
    ${body}    Create Dictionary    username=admin    password=password123
    ${response}    POST    url=${baseUrl}/auth    json=${body}
    Set Suite Variable    ${token}    ${response.json()}[token]

Get Bookings from Restful Booker as GetBookingIds
    [Documentation]    Hit API Get Bookings Based on Firstname is John    
    FOR    ${key}    ${value}    IN    &{names}
        ${url}    Set Variable    ${baseUrl}/booking?${key}=${value}
    END
    ${response}    GET    ${url}    
    ${data}    Get Length    ${response.json()}
    Log    JSON : ${response.json()}
    Log    Headers : ${response.headers}
    Log    Cookies : ${response.cookies}
    Status Should Be    200
    FOR    ${index}    ${booking}    IN ENUMERATE    @{response.json()}
        ${var}=    Evaluate    ${index} + 1 
        ${response}    GET    ${baseUrl}/booking/${booking}[bookingid]
        TRY
            IF    ${var} == 5
                Log To Console    Jumlah data sebanyak ${data}
                Exit For Loop
            END
        EXCEPT
            Log    Cannot retrieve JSON due to invalid data
        END
    END


Create a Booking at Restful Booker
    [Documentation]    Buat Data Booking melalui API
    ${booking_dates}    Create Dictionary    checkin=2022-12-31    checkout=2023-01-01
    ${body}    Create Dictionary    firstname=Hans    lastname=Gruber    totalprice=200    depositpaid=${False}    bookingdates=${booking_dates}
    ${response}    POST    url=${baseUrl}/booking    json=${body}
    Log    ${response.headers}
    ${bookingId}    Set Variable    ${response.json()}[bookingid]
    Set Suite Variable    ${id}    ${bookingId}
    &{booking}    Set Variable    ${response.json()}[booking]
    &{booking_check}    Set Variable    ${booking}[bookingdates]
    Status Should Be    200
    Should Be Equal    ${booking}[lastname]   ${body}[lastname]
    Should Be Equal    ${booking}[firstname]   ${body}[firstname]
    Should Be Equal As Strings    ${booking}[lastname]   ${body}[lastname]
    Should Be Equal As Strings    ${booking}[firstname]   ${body}[firstname]  
    Should Be Equal As Numbers    ${booking}[totalprice]    ${body}[totalprice]
    Should Be Equal   ${booking}[depositpaid]    ${False}
    Should Be Equal    ${booking_check}[checkin]    2022-12-31
    Should Be Equal    ${booking_check}[checkout]    2023-01-01
    Should Be Equal As Strings    ${booking_check}[checkin]    2022-12-31
    Should Be Equal As Strings    ${booking_check}[checkout]    2023-01-01


Get Specific Booking by ID as Get Booking
    [Documentation]    Cek Booking ID yang telah dibuat
    ${url}    Set Variable    ${baseUrl}/booking/${id}
    ${response}    GET    ${url}
    &{booking}    Set Variable    ${response.json()}
    &{booking_check}    Set Variable        ${booking}[bookingdates]
    Status Should Be    200
    Should Be Equal    ${booking}[lastname]   Gruber
    Should Be Equal    ${booking}[firstname]   Hans
    Should Be Equal As Strings    ${booking}[lastname]   Gruber
    Should Be Equal As Strings    ${booking}[firstname]   Hans  
    Should Be Equal As Numbers    ${booking}[totalprice]    200
    Should Be Equal   ${booking}[depositpaid]    ${False}
    Should Be Equal    ${booking_check}[checkin]    2022-12-31
    Should Be Equal    ${booking_check}[checkout]    2023-01-01
    Should Be Equal As Strings    ${booking_check}[checkin]    2022-12-31
    Should Be Equal As Strings    ${booking_check}[checkout]    2023-01-01


Update Booking
    [Documentation]    Update Data Booking
    ${header}    Create Dictionary    Content-Type=application/json    Accept=application/json    Cookie=token=${token}
    ${booking_dates}    Create Dictionary    checkin=2024-12-01    checkout=2024-12-25
    ${body}    Create Dictionary    firstname=Hario    lastname=Wicaksono    totalprice=10000000    depositpaid=true    bookingdates=${booking_dates}
    ${response}    PUT    url=${baseUrl}/booking/${id}    headers=${header}    json=${body}
    &{booking}    Set Variable    ${response.json()}
    &{booking_check}    Set Variable        ${booking}[bookingdates]
    Status Should Be    200
    Should Be Equal    ${booking}[lastname]   ${body}[lastname]
    Should Be Equal    ${booking}[firstname]   ${body}[firstname]
    Should Be Equal As Strings    ${booking}[lastname]   ${body}[lastname]
    Should Be Equal As Strings    ${booking}[firstname]   ${body}[firstname]  
    Should Be Equal As Numbers    ${booking}[totalprice]    ${body}[totalprice]
    Should Be Equal   ${booking}[depositpaid]    ${True}
    Should Be Equal    ${booking_check}[checkin]    ${booking_dates}[checkin]
    Should Be Equal    ${booking_check}[checkout]    ${booking_dates}[checkout]
    Should Be Equal As Strings    ${booking_check}[checkin]    ${booking_dates}[checkin]
    Should Be Equal As Strings    ${booking_check}[checkout]    ${booking_dates}[checkout]
    

Partial Update Booking
    [Documentation]    Update beberapa data booking
    ${header}    Create Dictionary    Content-Type=application/json    Accept=application/json    Cookie=token=${token}
    ${booking_dates}    Create Dictionary    checkin=2024-12-03    checkout=2024-12-10
    ${body}    Create Dictionary    lastname=Kalita    bookingdates=${booking_dates}
    ${response}    PATCH    url=${baseUrl}/booking/${id}    headers=${header}    json=${body}
    Status Should Be    200
    ${booking}    Set Variable    ${response.json()}
    ${booking_check}    Set Variable    ${booking}[bookingdates]
    Should Be Equal    ${response.json()}[lastname]   ${body}[lastname]
    Should Be Equal As Strings    ${booking}[lastname]   ${body}[lastname]
    Should Be Equal    ${booking_check}[checkin]    ${booking_dates}[checkin]
    Should Be Equal    ${booking_check}[checkout]    ${booking_dates}[checkout]
    Should Be Equal As Strings    ${booking_check}[checkin]    ${booking_dates}[checkin]
    Should Be Equal As Strings    ${booking_check}[checkout]    ${booking_dates}[checkout] 


Delete Booking
    [Documentation]    Hapus Data Booking yang telah dibuat
    ${header}    Create Dictionary    Content-Type=application/json    Cookie=token=${token}
    ${response}    DELETE    url=${baseUrl}/booking/${id}    headers=${header}   
    Status Should Be    201    ${response}


Ping - HealthCheck
    ${response}    GET    url=${baseUrl}/ping
    Status Should Be    201