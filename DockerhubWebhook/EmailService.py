import smtplib, ssl
import json

def sendNotificationEmail(message):

    with open('emailsdetails.json') as json_file:
        data = json.load(json_file)
        emailAddress = data["email"]['address']
        emailPassword = data["email"]['password']

        if emailAddress and emailPassword:
            for receiver in data['receivers']:
                if receiver:

                    content = 'Subject: Swan Cloud Server Update\n\n{}'.format(message)

                    print(content)
                    # Create a secure SSL context
                    context = ssl.create_default_context()

                    with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
                        server.login(emailAddress, emailPassword)
                        server.sendmail(emailAddress, receiver, content)