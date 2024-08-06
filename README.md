# Simulated Robot Control System
DevOps Technical Test

## Component Overview

- **Simulated Robot (`simulated_robot.py`)**: A server application that listens for instructions on a specified port and processes them.
- **Controller (`controller.py`)**: A Flask-based web server that acts as a communication layer between the client and the simulated robot. It logs all received instructions to a SQLite database.
- **Client (`client.py`)**: A command-line tool that sends robot instructions to the controller.


## Setup

### Prerequisites

- Python 3.7 or higher
- Required Python packages: `PyYAML`

### Installation

1. Clone the repository:
  ```
  git clone https://github.com/andrewjacksonio/simulated-robot.git
  cd simulated-robot
  ```

2. Install the required Python packages:
  ```
  pip install -r requirements.txt
  ```

3. Create the configuration file for the simulated robot.  If configuration file is not created, default values will be used:
  ```yaml
  # config.yml
  config:
    robot:
      host: localhost
      port: 8888
      sndbuf: 8192
      rcvbuf: 8192
    controller:
      port: 5000
  ```

## Usage

### Running the Applications

1. **Start the Simulated Robot:**

  ```
  python simulated_robot.py
  ```

2. **Start the Controller:**

  In a separate terminal, start the controller:

  ```
  python controller.py
  ```

3. **Send Commands Using the Client:**

  In another terminal, send commands via the controller:

  ```
  python client.py start
  python client.py stop
  ```

  The command will be processed by the controller, forwarded to the simulated robot, and the response will be printed out to the client.

### Viewing Logs

Robot Instructions are are logged to a SQLite database (`log.sqlite`).  To retrieve logs in the terminal you must have sqlite3 installed first.  To retrieve the last 50 instruction logs, run command:

```
sqlite3 log.sqlite "SELECT * FROM instructions_log LIMIT 50;"
```
