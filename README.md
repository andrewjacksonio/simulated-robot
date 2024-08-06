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
