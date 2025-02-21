from flask import Flask, jsonify, request
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route("/")
def hello():
    logger.info("Request received: python")
    return jsonify({
        "message": "Hello, KubeCon!",
        "language": "python"
    })

if __name__ == '__main__':  
   app.run(host='0.0.0.0', port=3000)
