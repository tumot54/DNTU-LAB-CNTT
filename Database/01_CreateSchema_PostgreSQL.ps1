# DNTULAB POSTGRESQL - TAO/CAP NHAT SCHEMA BANG EF CORE MIGRATION
# Chay PowerShell tai thu muc chua DntuLab.API.csproj.
# Lenh nay ap dung cac migration da co; KHONG reset database.
# LUU Y: migration RemoveTemporaryIncidentNotes se xoa bang GhiNhanTam cu.
# Hay sao luu database truoc neu can giu lich su GN00x.

$ErrorActionPreference = 'Stop'

if (-not (Test-Path ".\DntuLab.API.csproj")) {
    throw "Khong tim thay DntuLab.API.csproj. Hay mo PowerShell tai thu muc project Backend."
}

dotnet ef database update
if ($LASTEXITCODE -ne 0) {
    throw "EF Core database update that bai. Dung lai, khong chay cac file seed."
}

Write-Host "Da ap dung migration PostgreSQL thanh cong." -ForegroundColor Green
