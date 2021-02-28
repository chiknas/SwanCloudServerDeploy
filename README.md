# SwanCloudServerDeploy

## swan-cloud-server-deploy.sh

Deploys a fresh server to the system by removing and repulling the `chiknas/swancloud:latest` image. if there is already a deployed version with the container name `swancloud` it will shut it down and remove it before pulling the new image. 

### Usage

 Example command:
 `./swan-cloud-server-deploy.sh -k "'key1'" -p /mnt/c/Users/username/Desktop/`

 #### Command line arguments

 * -k|--keys = (REQUIRED) api keys that the server will respond to. any unauthorized request is dropped. Keys should be passed in this form:
 `-k "'key1','key2'"`

 * -p|--path = (REQUIRED) the path in the host machine to mount to the container and use as storage for the uploaded files.
