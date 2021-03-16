#!/bin/sh

# This file is used to run curl command and test API endpoint

URL='http://sample-api-lb-966673533.ap-southeast-1.elb.amazonaws.com'

curl --location --request POST "$URL" \
--header 'Content-Type: application/json' \
--data-raw '{
    "id":"223445",
    "firstName": "Mike",
    "lastName": "Wong",
    "class":"3 A",
    "nationality": "Singapore"
}'

curl --location --request POST "${URL}" \
--header 'Content-Type: application/json' \
--data-raw '{
    "id":"122390",
    "firstName": "Michelle",
    "lastName": "Wong",
    "class":"3 A",
    "nationality": "Singapore"
}'

curl --location --request POST "${URL}" \
--header 'Content-Type: application/json' \
--data-raw '{
    "id":"128890",
    "firstName": "Michelle",
    "lastName": "Wong",
    "class":"3 B",
    "nationality": "Singapore"
}'

curl --location --request PUT "${URL}" \
--header 'Content-Type: application/json' \
--data-raw '{
    "id":"128890",
    "class":"3 C"
}'

curl --location --request DELETE "${URL}" \
--header 'Content-Type: application/json' \
--data-raw '{
    "id":"128890"
}'

curl --location --request GET "${URL}/fetchStudents?id=223445"

curl --location --request GET "${URL}/fetchStudents?class=3%20A"

