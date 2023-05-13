#!/bin/bash

## Create SAM docker network
if [ ! "$(docker network ls | grep sam)" ]; then
echo "Creating sam network ..."
  docker network create sam
else
  echo "sam network exists."
fi

## Create dynamodb container
if [ ! "$(docker ps | grep dynamodb)" ]; then
    if [ "$(docker ps -aq -f name=dynamodb)" ]; then
        echo "Cleaning dynamodb ..."
        docker rm dynamodb
    fi
    echo "Running dynamodb in sam network ..."
    docker run -p 8000:8000 --network sam --name dynamodb -d amazon/dynamodb-local
else
  echo "Dynamodb already running."
fi

## Create dynamodb table
aws dynamodb create-table --table-name local-TodosDynamoDbTable --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 --endpoint-url http://localhost:8000 --region us-east-1

## build sam project usinf container
sam build --use-container

## run api in local env
sam local start-api --port 8081 --env-vars localEnvironment.json --docker-network sam