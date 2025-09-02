#!/bin/bash

fello_start_pods() {
    cd /run/media/Data/GS/Projects/Fello/podman-setup
    if [ "$(sysctl -n net.ipv4.ip_unprivileged_port_start)" != "80" ]; then
        sudo sysctl net.ipv4.ip_unprivileged_port_start=80
    fi

    # Simple start script - starts pods without rebuilding
    source .env

    echo "🚀 Quick starting pods..."

    # Start Database Pod if it exists and is stopped
    if podman pod exists fello_db; then
        echo "📂 Starting Database Pod..."
        podman pod start fello_db
    else
        echo "❌ Database pod doesn't exist. Run ./start-pods.sh first."
        exit 1
    fi

    # Start Web Services Pod if it exists and is stopped
    if podman pod exists fello_web; then
        echo "🌐 Starting Web Services Pod..."
        podman pod start fello_web
    else
        echo "❌ Web services pod doesn't exist. Run ./start-pods.sh first."
        exit 1
    fi

    echo "✅ Pods started!"
    ./status-pods.sh
}
