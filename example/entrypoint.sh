#!/bin/bash

# Start Docker daemon in the background
dockerd &

# Wait for Docker to be ready
while ! docker info >/dev/null 2>&1; do
    echo "Waiting for Docker daemon to start..."
    sleep 2
done

echo "Docker daemon is ready"

# Start SSH daemon
/usr/sbin/sshd -D

