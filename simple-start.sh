#!/bin/bash

# Simple start script - starts pods without rebuilding
source .env

echo "🚀 Quick starting pods..."

# Start Database Pod if it exists and is stopped
if podman pod exists fello-db-pod; then
    echo "📂 Starting Database Pod..."
    podman pod start fello-db-pod
else
    echo "❌ Database pod doesn't exist. Run ./start-pods.sh first."
    exit 1
fi

# Start Web Services Pod if it exists and is stopped
if podman pod exists fello-web-pod; then
    echo "🌐 Starting Web Services Pod..."
    podman pod start fello-web-pod
else
    echo "❌ Web services pod doesn't exist. Run ./start-pods.sh first."
    exit 1
fi

echo "✅ Pods started!"
./status-pods.sh