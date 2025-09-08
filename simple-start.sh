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
        DB_STATUS=$(podman pod inspect fello_db --format '{{.State}}')
        if [ "$DB_STATUS" = "Running" ]; then
            echo "📂 Database Pod is already running."
        else
            echo "📂 Starting Database Pod..."
            podman pod start fello_db
        fi
    else
        echo "❌ Database pod doesn't exist. Run ./start-pods.sh first."
        exit 1
    fi

    # Start Web Services Pod if it exists and is stopped
    if podman pod exists fello_web; then
        WEB_STATUS=$(podman pod inspect fello_web --format '{{.State}}')
        if [ "$WEB_STATUS" = "Running" ]; then
            echo "🌐 Web Services Pod is already running."
        else
            echo "🌐 Starting Web Services Pod..."
            podman pod start fello_web

            if ! declare -f fello_disable_xdebug > /dev/null; then
                source "./helper.sh"
            fi
            fello_disable_xdebug
        fi
    else
        echo "❌ Web services pod doesn't exist. Run ./start-pods.sh first."
        exit 1
    fi

    echo "✅ Pods started!"
}
