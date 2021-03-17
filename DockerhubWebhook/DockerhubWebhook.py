from flask import Flask, Response
from EmailService import sendNotificationEmail
import subprocess
import json

app = Flask(__name__)

@app.route('/8e6fe373-c129-4ecf-97d9-95e36e8b1eac/trigger/call', methods = ['POST'])
def refreshDeployment():
    try:
        deploymentConfig = getDeploymentConfig()
        if not deploymentConfig:
            raise Exception("Server deployment settings not setup")
        
        serverRefreshComand = "sudo ./swan-cloud-server-deploy.sh -k \"\'{keys}\'\" -p {basePath} -t {tag} -s -d {domain}".format(
            keys=deploymentConfig["api_keys"], basePath=deploymentConfig["base_file_path"], 
            tag=deploymentConfig["base_image_tag"], domain=deploymentConfig["domain"], 
        )

        # run server refresh and listen for comand result code
        refreshProcess = subprocess.Popen(serverRefreshComand, shell=True, cwd="../")
        refreshProcess.communicate()[0]
        if refreshProcess.returncode != 0:
            raise Exception('Server refresh command return with error exit code ' + str(refreshProcess.returncode))

        sendNotificationEmail("Server was refreshed successfully!")
        return Response("Webhook processed successfully!", status=200)
    except Exception as e:
        sendNotificationEmail("Server refresh failed with the following error: " + str(e))
        return Response("Webhook failed", status=500)

def getDeploymentConfig():
    with open('application_config.json') as json_file:
        config = json.load(json_file)
        deploymentConfig = config["deployment_settings"]
        if deploymentConfig["api_keys"] and deploymentConfig["base_file_path"] and deploymentConfig["base_image_tag"] and deploymentConfig["domain"]:
            return deploymentConfig

if __name__ == '__main__':
    app.run(host='0.0.0.0')