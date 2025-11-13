# PowerShell script to check for deprecated methods in Flutter project
# This script helps prevent using deprecated APIs

Write-Host "Checking for deprecated Flutter methods..." -ForegroundColor Blue

# Check for common deprecated methods
$deprecatedMethods = @(
    "withOpacity", 
    "FlatButton",
    "RaisedButton", 
    "OutlineButton"
)

$foundIssues = $false

foreach ($method in $deprecatedMethods) {
    $files = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match $method) {
            Write-Host "WARNING: Found potentially deprecated method '$method' in: $($file.Name)" -ForegroundColor Yellow
            $foundIssues = $true
        }
    }
}

if (-not $foundIssues) {
    Write-Host "SUCCESS: No deprecated methods found!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Found deprecated methods. Please update them." -ForegroundColor Red
    Write-Host "Run 'dart analyze' for detailed information." -ForegroundColor Cyan
}

# Run official dart analyze
Write-Host ""
Write-Host "Running official Dart analysis..." -ForegroundColor Blue
dart analyze