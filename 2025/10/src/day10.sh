#!/bin/bash

VENV_DIR=".venv"

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment at $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

# Install pulp if not already installed
if ! "$VENV_DIR/bin/pip" show pulp > /dev/null 2>&1; then
    echo "Installing PuLP..."
    "$VENV_DIR/bin/pip" install pulp
fi

# Run the script
"$VENV_DIR/bin/python" d10.py
