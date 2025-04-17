# PowerShell Script to create BackgroundProcessing solution for .NET 9
# This script creates a new solution with Web API project and two class libraries

# Set the location where you want to create the solution
$solutionPath = "C:\Projects\slimbgprocessor"

# Create solution directory if it doesn't exist
if (-not (Test-Path $solutionPath)) {
    New-Item -ItemType Directory -Path $solutionPath | Out-Null
    Write-Host "Created solution directory at $solutionPath" -ForegroundColor Green
}

# Navigate to solution directory
Set-Location $solutionPath

# Create new solution
Write-Host "Creating new solution 'BackgroundProcessing.sln'..." -ForegroundColor Cyan
dotnet new sln --name BackgroundProcessing

# Create BackgroundProcessing.API project (Web API)
Write-Host "Creating BackgroundProcessing.API project..." -ForegroundColor Cyan
dotnet new webapi --framework net9.0 --name BackgroundProcessing.API --output BackgroundProcessing.API

# Create Weather class library
Write-Host "Creating Weather class library..." -ForegroundColor Cyan
dotnet new classlib --framework net9.0 --name Weather --output Weather

# Create StockLoader class library
Write-Host "Creating StockLoader class library..." -ForegroundColor Cyan
dotnet new classlib --framework net9.0 --name StockLoader --output StockLoader

# Add projects to solution
Write-Host "Adding projects to solution..." -ForegroundColor Cyan
dotnet sln add BackgroundProcessing.API\BackgroundProcessing.API.csproj
dotnet sln add Weather\Weather.csproj
dotnet sln add StockLoader\StockLoader.csproj

# Add project references
Write-Host "Adding project references..." -ForegroundColor Cyan
dotnet add BackgroundProcessing.API\BackgroundProcessing.API.csproj reference Weather\Weather.csproj
dotnet add BackgroundProcessing.API\BackgroundProcessing.API.csproj reference StockLoader\StockLoader.csproj

# Clean up default files that we don't need
Remove-Item -Path "Weather\Class1.cs" -ErrorAction SilentlyContinue
Remove-Item -Path "StockLoader\Class1.cs" -ErrorAction SilentlyContinue

# Create directories for models and services
New-Item -ItemType Directory -Path "Weather\Models" -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "Weather\Services" -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "StockLoader\Models" -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "StockLoader\Services" -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "BackgroundProcessing.API\Controllers" -ErrorAction SilentlyContinue | Out-Null

# Done
Write-Host "Solution setup complete!" -ForegroundColor Green
Write-Host "Structure created:" -ForegroundColor Yellow
Write-Host "  - BackgroundProcessing.sln" -ForegroundColor White
Write-Host "  - BackgroundProcessing.API (Web API, .NET 9)" -ForegroundColor White
Write-Host "  - Weather (Class Library, .NET 9)" -ForegroundColor White
Write-Host "  - StockLoader (Class Library, .NET 9)" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Magenta
Write-Host "1. Create the Weather models, interfaces, and services" -ForegroundColor White
Write-Host "2. Create the StockLoader models, interfaces, and services" -ForegroundColor White
Write-Host "3. Configure the API Program.cs to register services" -ForegroundColor White
Write-Host "4. Create controllers in the API project" -ForegroundColor White
Write-Host ""
Write-Host "To build the solution, run: dotnet build" -ForegroundColor Cyan