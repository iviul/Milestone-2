import json
import os
import http.client
from urllib.parse import urlparse

def lambda_handler(event, context):
    message = json.loads(event['Records'][0]['Sns']['Message'])
    
    discord_message = {
        "embeds": [{
            "title": message['AlarmName'],
            "description": message['AlarmDescription'],
            "color": 16711680 if message['NewStateValue'] == 'ALARM' else 65280,
            "fields": [
                {
                    "name": "State",
                    "value": message['NewStateValue'],
                    "inline": True
                },
                {
                    "name": "Reason",
                    "value": message['NewStateReason'],
                    "inline": False
                },
                {
                    "name": "Time",
                    "value": message['StateChangeTime'],
                    "inline": True
                }
            ]
        }]
    }
    
    try:
        url = urlparse(os.environ['DISCORD_WEBHOOK_URL'])
        conn = http.client.HTTPSConnection(url.netloc)
        conn.request(
            'POST',
            url.path,
            body=json.dumps(discord_message),
            headers={'Content-Type': 'application/json'}
        )
        
        response = conn.getresponse()
        response_data = response.read().decode('utf-8')
        conn.close()
        
        return {
            'statusCode': response.status,
            'body': response_data
        }
    except Exception as e:
        print(f"Error sending message to Discord: {str(e)}")
        raise
