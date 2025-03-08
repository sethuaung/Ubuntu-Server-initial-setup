# Ubuntu Server Initial Setup Script and Other Essential Tools

Bash script designed to automate the initial setup and configuration of a new Ubuntu server. It simplifies user account creation, system updates, and other essential configurations.

## Prerequisites

-   **Supported Environment**: Ubuntu 24.04.1.
-   **Root Privileges**: This script must be run as  `root`  or with  `sudo`.

## How to Use

1.  **Clone the Repository**:
    ```
    git clone https://github.com/sethuaung/Ubuntu-Server-initial-setup.git
    ```
2.  **Navigate to the Directory**:
    ```
    cd Ubuntu-Server-initial-setup
    ```
3.  **Make the Script Executable**:
    ```
    chmod +x name_of_script.sh
    ```
4.  **Run the Script**:
    ```
    sudo ./name_of_script.sh
    ```
5.  **Follow the Prompts**:
    
    -   Accept the disclaimer.
    -   Create a new user account.
    -   Optionally fetch and configure SSH keys.
    -   Configure a static IP if desired.
    -   Others ...

## Disclaimer

This script is provided "as is" without any warranty. It was tested on Ubuntu 24.04.1. The author is not responsible for any errors, issues, or damages caused by its use. Review the script before running it and use it at your own discretion.

## License

This project is licensed under the MIT License. See the  [LICENSE](https://github.com/sethuaung/Ubuntu-Server-initial-setup/blob/main/LICENSE)  file for details.
