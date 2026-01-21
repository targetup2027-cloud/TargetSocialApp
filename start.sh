#!/bin/bash
set -e

echo "Building the application..."
dotnet restore
dotnet build -c Release

echo "Running API..."
dotnet TargetSocialApp.API/bin/Release/net8.0/TargetSocialApp.API.dll
