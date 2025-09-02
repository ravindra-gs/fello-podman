#!/bin/bash

fello_stop_and_remove_pods() {
    cd /run/media/Data/GS/Projects/Fello/podman-setup

    echo "🛑 Stopping Fello Podman Setup..."

    # Stop and remove Web Services Pod
    echo "🌐 Stopping Web Services Pod..."
    podman pod exists fello_web && {
        podman pod stop fello_web
        podman pod rm fello_web
    }

    # Stop and remove Database Pod
    echo "🗄️  Stopping Database Pod..."
    podman pod exists fello_db && {
        podman pod stop fello_db
        podman pod rm fello_db
    }

    echo "✅ All pods stopped successfully!"
    echo "💾 Data preserved in volumes directory"
}
