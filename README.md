# Simulated Robot Control System
DevOps Technical Test

## Component Overview

- **Simulated Robot (`simulated_robot.py`)**: A server application that listens for instructions on a specified port and processes them.

## Setup

### Prerequisites

- Python 3.7 or higher
- Required Python packages: `PyYAML`

### Installation

1. Clone the repository:
  ```
  git clone https://github.com/andrewjacksonio/simulated-robot.git
  cd simulated-robot-control-system
  ```

2. Install the required Python packages:
  ```
  pip install -r requirements.txt
  ```

3. Create the configuration file for the simulated robot:
  ```yaml
  # config.yml
  config:
    port: 8888
    sndbuf: 8192
    rcvbuf: 8192
  ```

## Usage

### Running the Applications

1. **Start the Simulated Robot:**

  ```
  python simulated_robot.py
  ```

  This will start the simulated robot, which listens on the port specified in `config.yml`.
