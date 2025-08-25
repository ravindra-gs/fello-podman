#!/bin/bash

echo "📊 Fello Podman Setup Status"
echo "=============================="

# Check pods
echo ""
echo "🏗️  PODS:"
podman pod ls --format "table {{.Name}} {{.Status}} {{.Created}} {{.Ports}}"

echo ""
echo "📦 CONTAINERS:"
podman ps --format "table {{.Names}} {{.Status}} {{.Ports}} {{.Image}}"

echo ""
echo "📡 NETWORKS:"
podman network ls

echo ""
echo "💾 VOLUMES:"
echo "MySQL Data: $(du -sh volumes/mysql 2>/dev/null || echo 'N/A')"
echo "Logs: $(du -sh volumes/logs 2>/dev/null || echo 'N/A')"

echo ""
echo "🔗 URLs:"
if podman pod exists fello-web-pod && [ "$(podman pod inspect fello-web-pod --format '{{.State}}')" == "Running" ]; then
    echo "✅ FC Inventory API:  http://fc-inventory-api.localhost"
    echo "✅ FC Inventory:      http://fc-inventory.localhost"
    echo "✅ Fello IMS:         http://fello-ims.localhost"
    echo "✅ Fello New:         http://fello-new.localhost"
else
    echo "❌ Web services are not running"
fi

if podman pod exists fello-db-pod && [ "$(podman pod inspect fello-db-pod --format '{{.State}}')" == "Running" ]; then
    source .env
    echo "✅ PHPMyAdmin:        http://localhost:$PMA_PORT"
else
    echo "❌ Database services are not running"
fi