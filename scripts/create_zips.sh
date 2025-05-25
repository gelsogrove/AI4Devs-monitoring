#!/bin/bash

# Set the working directory to the root of the project
cd "$(dirname "$0")/.."
ROOT_DIR=$(pwd)

echo "Creating new zip files from frontend and backend directories..."

# Create frontend zip
echo "Creating frontend.zip..."
cd "$ROOT_DIR/frontend"
rm -f "$ROOT_DIR/frontend.zip"
zip -r "$ROOT_DIR/frontend.zip" . -x "node_modules/*" ".git/*" ".env" "*.log"

# Create backend zip
echo "Creating backend.zip..."
cd "$ROOT_DIR/backend"
rm -f "$ROOT_DIR/backend.zip"
zip -r "$ROOT_DIR/backend.zip" . -x "node_modules/*" ".git/*" ".env" "*.log"

echo "Zip files created successfully:"
echo "- $ROOT_DIR/frontend.zip"
echo "- $ROOT_DIR/backend.zip"
echo "Ready to be uploaded to S3." 