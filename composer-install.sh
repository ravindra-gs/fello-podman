#!/bin/bash

# Load environment variables
source .env

echo "📦 Installing PHP dependencies with Composer..."

# Projects that need composer install
projects=(
    "fc-inventory-api"
    "fc-inventory" 
    "fello-ims"
    "fello-new"
)

for project in "${projects[@]}"; do
    project_path="../${project}"
    
    if [ -d "$project_path" ] && [ -f "$project_path/composer.json" ]; then
        echo "🔧 Installing dependencies for $project..."
        
        # Run composer install using temporary PHP 8.2 container
        podman run --rm \
            -v "$PWD/$project_path:/app:Z" \
            -w /app \
            php:8.2-cli-bullseye \
            sh -c "apt-get update && apt-get install -y git unzip && \
                   curl -sS https://getcomposer.org/installer | php && \
                   php composer.phar install"
        
        if [ $? -eq 0 ]; then
            echo "✅ $project dependencies installed successfully"
        else
            echo "❌ Failed to install dependencies for $project"
        fi
    else
        echo "⚠️  Skipping $project (not found or no composer.json)"
    fi
    echo ""
done

echo "🎉 Composer installation complete!"
echo ""
echo "💡 Note: If you need to install development dependencies, run:"
echo "   podman exec -it fello-php-fpm composer install"