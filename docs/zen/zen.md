# zen.sh

## Overview

Contains the main entry point for the zen command line tool.

## Index

* [zen::environment::init](#zenenvironmentinit)
* [zen::args::process](#zenargsprocess)
* [zen::environment::global::variables](#zenenvironmentglobalvariables)
* [zen::software::args::process](#zensoftwareargsprocess)
* [zen::software::handle_action](#zensoftwarehandleaction)

### zen::environment::init

Initializes the environment for zen commands.

### zen::args::process

Processes command line arguments for zen scripts.

### zen::environment::global::variables

Sets up global variables required for zen's operation.

### zen::software::args::process

Processes command-line arguments for software management commands.

#### Example

```bash
zen::software::args::process "$@"
```

#### Arguments

* **...** (array): Command-line arguments.

#### Output on stdout

* Parses action, username, application name, and options from the arguments.
  Calls zen::software::handle_action with the parsed arguments.

### zen::software::handle_action

Handles the specified action for the given software.

#### Example

```bash
zen::software::handle_action "add" "jason" "radarr"
```

#### Arguments

* **$1** (string): The action to be performed (add, remove, backup, update, reset).
* **$2** (string): The username associated with the application.
* **$3** (string): The name of the application.

#### Output on stdout

* Executes the appropriate action for the specified software.

