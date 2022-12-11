import requests
import os
import sys
import time

# DEPRECATED IN V2. Authentication is now handled with jwt tokens.

# add details to the server and upload the specified folder to the server
folder_path=""
server=""
passwd=""

headers = {"Authorization": passwd}

for path, subdirs, files in os.walk(folder_path):
    for name in files:
        binaryFile = open(os.path.join(path, name), "rb")
        response = requests.post(server, files={"data": binaryFile}, headers=headers)
        if response.ok:
            print("Uploaded file: " + name)
        else:
            print(response)
            sys.exit("Upload failed for file: " + name)
        
        time.sleep(0.3)
