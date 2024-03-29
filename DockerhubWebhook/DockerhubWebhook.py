from flask import Flask, Response, request
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

        # check the request is for the image tag we are currently interested in
        content = request.json
        imageTag = content["push_data"]["tag"]
        if imageTag != deploymentConfig["base_image_tag"]:
            return Response("Not interested", status=200)
        
        serverRefreshComand = "sudo ./swan-cloud-server-deploy.sh -ac {admin_accounts} -p {basePath} -db {dbPath} -t {tag} -s -d {domain}".format(
            admin_accounts=deploymentConfig["admin_accounts"], basePath=deploymentConfig["base_file_path"], 
            tag=deploymentConfig["base_image_tag"], domain=deploymentConfig["domain"], 
            dbPath=deploymentConfig["database_path"]
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
        if deploymentConfig["admin_accounts"] and deploymentConfig["base_file_path"] and deploymentConfig["base_image_tag"] and deploymentConfig["domain"]:
            return deploymentConfig

if __name__ == '__main__':
    app.run(host='0.0.0.0')