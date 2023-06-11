import json
import decimalencoder
import todoList


def get(event, context):
    # create a response
    item = todoList.get_translated_item(event['pathParameters']['id'], event['pathParameters']['lang'])
    if item:
        response = {
            "statusCode": 200,
            "body": json.dumps(item,
                               cls=decimalencoder.DecimalEncoder)
        }
    else:
        response = {
            "statusCode": 404,
            "body": ""
        }
    return response
