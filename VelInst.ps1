[CmdletBinding()]
param (
    [string]$InstallPath = "C:\Program Files\Velociraptor",
    [string]$SourceBinary = ".\velociraptor.exe",
    [string]$SourceConfig = ".\client.config.yaml"
)
# Проверка прав админа
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run as Administrator."
    exit
}
# Создание директории
if (-not (Test-Path $InstallPath)) { 
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null 
}
$DestBinary = Join-Path $InstallPath "velociraptor.exe"
$DestConfig = Join-Path $InstallPath "client.config.yaml"
# Копирование конфигов
Copy-Item -Path $SourceBinary -Destination $DestBinary -Force
Copy-Item -Path $SourceConfig -Destination $DestConfig -Force
# Установка Velociraptor
$Service = Get-Service -Name "Velociraptor" -ErrorAction SilentlyContinue
if ($null -eq $Service) {
    & $DestBinary --config $DestConfig service install
    Start-Sleep -Seconds 2
}
Start-Service -Name "Velociraptor"
Write-Host "Velociraptor client deployed and running."
