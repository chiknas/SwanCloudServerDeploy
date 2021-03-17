# SwanCloudServerDeploy

## swan-cloud-server-deploy.sh

Deploys a fresh server to the system by removing and repulling the `chiknas/swancloud:latest` image. if there is already a deployed version with the container name `swancloud` it will shut it down and remove it before pulling the new image.

### Usage

Example command:
`./swan-cloud-server-deploy.sh -k "'key1'" -p /mnt/c/Users/username/Desktop/`

#### Command line arguments

- -k|--keys = (REQUIRED) api keys that the server will respond to. any unauthorized request is dropped. Keys should be passed in this form:
  `-k "'key1','key2'"`

- -p|--path = (REQUIRED) the path in the host machine to mount to the container and use as storage for the uploaded files.

- -s|--ssl = (OPTIONAL) is the server will be deployed with ssl enabled or not. for this to work we need a `swancloudcert.p12` file is needed in the same directory as this file.

## DockerhubWebhook

Python mini server which exposes an endpoint for POST requests on `/8e6fe373-c129-4ecf-97d9-95e36e8b1eac/trigger/call`. This will trigger a server refresh using the `swan-cloud-server-deploy.sh` file. If `application_config.json` is setup it will also send notification emails on the list of `receivers` when a refresh is triggered.
`deployment_settings` object in the `application_config.json` are required for the correct deployment of the server.

### Usage

0.  `cd Dockerhubwebhook` change directory to the python project
1.  `python3 -m venv venv/dockerhub-webhook` Create new python3 environment to install required dependencies on.
2.  `pip3 install -r requirements.txt` Install required dependencies
3.  `python3 DockerhubWebhook.py` Start the server
