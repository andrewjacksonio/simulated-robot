import yaml
import requests
import sys

# Load configuration file
try:
  with open("config.yml", "r") as file:
    config = yaml.safe_load(file)['config']

    port = config['controller']['port']
except IOError:
  print("Error: Configuration file does not appear to exist.  Using default values.")
  port = 5000
  
def send_instruction(instruction):
  url     = f"http://localhost:{port}/send_instruction"
  headers = {'Content-Type': 'application/json'}
  data    = {'instruction': instruction}

  try:
    response = requests.post(url, json=data, headers=headers)
    response.raise_for_status()
    print("Controller response:", response.json())
    return 0
  except requests.exceptions.HTTPError as http_err:
    print(f"HTTP error occurred: {http_err}")
    return 1
  except Exception as err:
    print(f"Other error occurred: {err}")
    return 1

if __name__ == "__main__":
  if len(sys.argv) < 2:
    print("Usage: python client.py <instruction>")
    sys.exit(1)

  instruction = sys.argv[1]
  valid_instructions = ["start", "stop", "left", "right", "forward", "back"]

  if instruction not in valid_instructions:
    print(f"Invalid instruction. Valid instructions are: {', '.join(valid_instructions)}")
    sys.exit(1)

  exit_code = send_instruction(instruction)
  sys.exit(exit_code)
