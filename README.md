# Workspace

This project sets up a development workspace with necessary directories, SSH keys, and Git configuration. It also installs essential software like Homebrew and Git.

## Prerequisites

- macOS
- Make

## Installation

To set up the workspace, run the following command:

```sh
make install

Student/
├── .ssh/
│   └── student_rsa
│   └── student_rsa.pub
├── .git/
│   └── config
└── .env
```