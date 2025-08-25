#!/bin/bash

echo "🛑 Quick stopping pods..."

# Stop pods but don't remove them
podman pod exists fello-web-pod && podman pod stop fello-web-pod
podman pod exists fello-db-pod && podman pod stop fello-db-pod

echo "✅ Pods stopped!"