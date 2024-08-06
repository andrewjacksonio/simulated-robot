import yaml
import sqlite3
import socket
import json
from flask import Flask, request, jsonify
from datetime import datetime

# Load configuration file
try:
  with open("config.yml", "r") as file:
    config = yaml.safe_load(file)['config']

    ROBOT_HOST      = config['robot']['host']
    ROBOT_PORT      = config['robot']['port']
    CONTROLLER_PORT = config['controller']['port']
except IOError:
  print("Error: Configuration file does not appear to exist.  Using default values.")
  ROBOT_HOST      = "localhost"
  ROBOT_PORT      = 8888
  CONTROLLER_PORT = 5000
  
app = Flask(__name__)

# Initialize SQLite database
conn = sqlite3.connect('log.sqlite', check_same_thread=False)
cursor = conn.cursor()
cursor.execute('''CREATE TABLE IF NOT EXISTS instructions_log (
                    timestamp TEXT,
                    ip_address TEXT,
                    http_method TEXT,
                    instruction TEXT
                )''')
conn.commit()

def send_instruction_to_robot(instruction, sender_ip):
    message = json.dumps({'sender': sender_ip, 'instruction': instruction})
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.connect((ROBOT_HOST, ROBOT_PORT))
        sock.sendall(message.encode('utf-8'))
        response = sock.recv(1024)
    return response.decode('utf-8')

@app.route('/send_instruction', methods=['POST'])
def send_instruction():
    instruction = request.json.get('instruction')
    if instruction not in ['start', 'stop', 'left', 'right', 'forward', 'back']:
        return jsonify({'error': 'Invalid instruction'}), 400

    ip_address = request.remote_addr
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    http_method = request.method

    # Log the instruction to SQLite database
    cursor.execute("INSERT INTO instructions_log (timestamp, ip_address, http_method, instruction) VALUES (?, ?, ?, ?)",
                   (timestamp, ip_address, http_method, instruction))
    conn.commit()

    # Send instruction to robot and get response
    response = send_instruction_to_robot(instruction, ip_address)
    
    if response == "OK":
        return jsonify({'status': 'OK'}), 200
    else:
        return jsonify({'error': 'Failed to send instruction to robot'}), 500

if __name__ == '__main__':
    app.run(port=CONTROLLER_PORT, debug=True)
