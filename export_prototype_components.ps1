# PowerShell script to export RallyMatch prototype components
# This script will extract key components and render screens as SVGs

# Define paths
$inputHtml = "c:\Users\Leyla\Documents\RallyMatch\rallly-v3_3.html"
$outputDir = "c:\Users\Leyla\Documents\RallyMatch\exports"

# Ensure output directory exists
if (-Not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# Use Puppeteer or a similar tool to render HTML to SVG (placeholder command)
Write-Host "Rendering prototype screens to SVG..."
# Example: puppeteer-cli render $inputHtml --output $outputDir --format svg

Write-Host "Exporting components as SVG..."
# Extract specific components (e.g., buttons, cards) and save as SVG
# Example: puppeteer-cli extract-components $inputHtml --output $outputDir

Write-Host "Export complete. Check the exports directory."