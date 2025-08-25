#!/bin/bash

echo "🛑 Stopping Fello Podman Setup..."

# Stop and remove Web Services Pod
echo "🌐 Stopping Web Services Pod..."
podman pod exists fello-web-pod && {
    podman pod stop fello-web-pod
    podman pod rm fello-web-pod
}

# Stop and remove Database Pod
echo "🗄️  Stopping Database Pod..."
podman pod exists fello-db-pod && {
    podman pod stop fello-db-pod
    podman pod rm fello-db-pod
}

echo "✅ All pods stopped successfully!"
echo "💾 Data preserved in volumes directory"