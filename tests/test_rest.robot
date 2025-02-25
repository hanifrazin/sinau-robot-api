*** Settings ***
Library    RequestsLibrary
Library    Collections
Resource    ../resources/keywords.resource


*** Variables ***
${token}    0
${id}    1942
${baseUrl}    https://restful-booker.herokuapp.com


*** Test Cases ***
Login
    ${token}    Authenticate as Admin

Get Bookings from Restful Booker
    ${body}    Create Dictionary    firstname=John
    ${response}    GET    ${baseUrl}?${body}
    Status Should Be    200
    # Log    ${response.json()}
    # FOR  ${booking}  IN  @{response.json()}
    #     ${response}    GET    ${baseUrl} /booking/ ${booking}[bookingid]
    #     TRY
    #         Log    ${response.json()}
    #     EXCEPT
    #         Log    Cannot retrieve JSON due to invalid data
    #     END
    # END

Create a Booking at Restful Booker
    ${booking_dates}    Create Dictionary    checkin=2022-12-31    checkout=2023-01-01
    ${body}    Create Dictionary    firstname=Hans    lastname=Gruber    totalprice=200    depositpaid=false    bookingdates=${booking_dates}
    ${response}    POST    url=${baseUrl}/booking    json=${body}
    # ${id}    RETURN    ${response.json()}[bookingid]
    ${response}    GET    ${baseUrl}/booking/${id}
    Log    ${response.json()}
    Should Be Equal    ${response.json()}[lastname]    Smith
    Should Be Equal    ${response.json()}[firstname]    John   
    Should Be Equal As Numbers    ${response.json()}[totalprice]    111
    Dictionary Should Contain Value     ${response.json()}    Breakfast

Delete Booking
    ${token}    Authenticate as Admin
    ${header}    Create Dictionary    Content-Type=application/json    Cookie=token=${token}
    ${response}    DELETE    url=${baseUrl}/booking/${id}    headers=${header}   
    Status Should Be    201    ${response}