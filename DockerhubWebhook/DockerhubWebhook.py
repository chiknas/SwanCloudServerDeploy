from flask import Flask
from flask import request

app = Flask(__name__)

@app.route('/8e6fe373-c129-4ecf-97d9-95e36e8b1eac/trigger/call', methods = ['POST'])
def handleNewSwanCloudImage():
    return 'Hello World!'


if __name__ == '__main__':
    app.run(host='0.0.0.0')