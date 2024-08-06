import socket
import yaml

# Load configuration file
try:
  with open("config.yml", "r") as file:
    config = yaml.safe_load(file)['config']

    port = config['port']
    sndbuf = config['sndbuf']
    rcvbuf = config['rcvbuf']
except IOError:
  print("Error: Configuration file does not appear to exist.  Using default values.")
  port = 8888
  sndbuf = 8192
  rcvbuf = 8192

# Create socket
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, rcvbuf)
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, sndbuf)
server_socket.bind(('', port))
server_socket.listen(1)

print(f"Simulated Robot listening on port {port}...")

while True:
  conn, addr = server_socket.accept()
  print(f"Connected by {addr}")
  while True:
    data = conn.recv(1024)
    if not data:
      break
    print(f"Received instruction: {data.decode('utf-8')}")
    conn.sendall(b"OK")

  conn.close()
