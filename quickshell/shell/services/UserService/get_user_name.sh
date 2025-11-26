#!/bin/bash
# Get user's full name from passwd
getent passwd "$USER" | cut -d: -f5 | cut -d, -f1
