<div align="center">
  <a href="https://github.com/MediaEase/MediaEase">
    <img src="https://github.com/MediaEase/docs/blob/main/assets/mediaease.png" alt="Logo" width="100" height="100">
  </a>
  <h1>MediaEase</h1>
  <p>
    <a href="https://mediaease.github.io/docs/"><strong>Documentation</strong></a> ·
    <a href="https://github.com/MediaEase/MediaEase/issues/new?assignees=&labels=bug&template=01_BUG_REPORT.md&title=bug%3A+">Report a Bug</a> ·
    <a href="https://github.com/MediaEase/MediaEase/issues/new?assignees=&labels=enhancement&template=02_FEATURE_REQUEST.md&title=feat%3A+">Request a Feature</a> ·
    <a href="https://github.com/MediaEase/MediaEase/discussions">Ask a Question</a>
  </p>
</div>

## About MediaEase

MediaEase is a comprehensive solution designed to streamline the setup and management of dedicated server environments. It offers an all-in-one platform, specifically tailored for Debian servers, to facilitate the installation and administration of various server-side applications and services. The core objective of MediaEase is to simplify complex server management tasks, making it accessible even to those with minimal server administration experience.

### Relationship with HarmonyUI

MediaEase acts as the robust backend for HarmonyUI. It manages all server-side operations and logic, ensuring a seamless integration. HarmonyUI, with its user-friendly interface, serves as the frontend, allowing users to interact with the server environment in a more intuitive way. This symbiotic relationship ensures that while users enjoy a smooth frontend experience with HarmonyUI, MediaEase efficiently handles the complexities of backend processes.

## Features

1. **Easy Installation and Management:** MediaEase simplifies the process of setting up and managing server applications. With its automated scripts, users can easily install and configure server-side applications.

2. **Robust Backend Support for HarmonyUI:** MediaEase provides a stable and powerful backend platform for HarmonyUI, ensuring that the frontend interface operates seamlessly with the underlying server operations.

3. **Automated Scripts for Application Setup:** The platform includes a suite of scripts designed to automate the installation and setup of popular server applications, reducing manual intervention and potential setup errors.

4. **Support for Popular Applications:** MediaEase supports a range of popular applications such as Plex for media streaming, Sonarr for TV show management, and rTorrent for torrenting, making it a versatile platform for various server needs.

> **TIP**
> These features make MediaEase an ideal choice for users seeking an efficient way to manage their server environment with minimal hassle.

## Built With

- Symfony 7
- PHP 8.3
- Bash
- NPM v20

## Getting Started

### Prerequisites

- Debian 12 (bookworm) server
- Fresh server installation

## Installation

To streamline the installation process of MediaEase on a fresh Debian 12 server, you can use the following one-liner command:

```bash
export MEDIAEASE_INIT=true
wget https://github.com/MediaEase/MediaEase/blob/main/mediaEaseInstaller.sh \
chmod +x mediaEaseInstaller.sh \
./mediaEaseInstaller.sh -u [username] -p [password] -d [domain]
```

Replace `[username]`, `[password]`, and `[domain]` with your desired credentials and domain name.

### What This Command Does:

1. **Download the Installer:** The command begins by fetching the `mediaEaseInstaller.sh` script from the provided URL.
2. **Make it Executable:** It then modifies the script's permissions to make it executable.
3. **Run the Installer:** Finally, it executes the script with your specified parameters.

This script automates the installation of all necessary dependencies, including PHP, SQLite, Symfony, and NPM. It's crucial to start with a fresh Debian 12 server to ensure a smooth installation process.

After running this command, follow the on-screen instructions to complete the installation. Once done, MediaEase will be ready for use.

## Usage

- Access HarmonyUI through your web browser at `https://SERVER_IP`
- Log In with the credentials provided during the installation process
- Start using HarmonyUI or the CLI commands, thanks to the `zen` script located at `/usr/bin/zen`
- For detailed usage instructions, refer to the [User Guide](./USER_GUIDE.md).

> **NOTE**
> The `zen` script is the entrypoint of your new server. It's a powerful handler to install your preferred apps or to manage your server with ease!

## Contributing

Contributions to MediaEase are welcome! Please read our [contribution guidelines](./CONTRIBUTING.md).

## License

This project is licensed under the BSD license - see the [LICENSE](LICENSE) file for details.
