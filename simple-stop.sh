#!/bin/bash

fello_stop_pods() {
    cd /run/media/Data/GS/Projects/Fello/podman-setup

    echo "🛑 Quick stopping pods..."

    # Stop pods but don't remove them
    podman pod exists fello_web && podman pod stop fello_web
    podman pod exists fello_db && podman pod stop fello_db

    echo "✅ Pods stopped!"
}
