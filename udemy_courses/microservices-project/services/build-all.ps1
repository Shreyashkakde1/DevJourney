# build-all.ps1

# List of service directories
$services = @("accounts", "cards", "configserver", "loans")

# Loop through each folder
foreach ($service in $services) {
    Write-Host "Building $service..."
    Push-Location $service    # cd into the folder
    .\mvnw.cmd compile jib:dockerBuild
    Pop-Location              # return to original folder
    Write-Host "$service build finished.`n"
}