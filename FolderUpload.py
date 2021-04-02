import requests
from os import listdir
import sys
import time

# add details to the server and upload the specified folder to the server
folder_path=""
server=""
passwd=""

headers = {"Authorization": passwd}

files = listdir(folder_path)

for file in files:
    binaryFile = open(folder_path + "/" + file, "rb")
    response = requests.post(server, files={"data": binaryFile}, headers=headers)
    if response.ok:
        print("Uploaded file: " + file)
    else:
        sys.exit("Upload failed for file: " + file)
    
    time.sleep(0.3)
