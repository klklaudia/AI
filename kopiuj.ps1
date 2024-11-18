param (
    [Parameter(Mandatory = $true)]
    [string]$DestinationPath,  # Folder docelowy
    
    [Parameter(Mandatory = $true)]
    [string]$SearchPattern     # Wzorzec w nazwie pliku
)

# Pobierz ścieżkę folderu, w którym uruchomiono skrypt
$SourcePath = Get-Location

# Tworzy folder docelowy, jeśli nie istnieje
if (!(Test-Path -Path $DestinationPath)) {
    New-Item -ItemType Directory -Path $DestinationPath
}

# Przeszukiwanie folderów i kopiowanie plików
Get-ChildItem -Path $SourcePath -Recurse -File | Where-Object {
    $_.Name -like "*$SearchPattern*"
} | ForEach-Object {
    # Określenie ścieżki docelowej
    $DestinationFile = Join-Path -Path $DestinationPath -ChildPath $_.Name

    # Kopiowanie pliku tylko, jeśli nie istnieje w folderze docelowym
    if (!(Test-Path -Path $DestinationFile)) {
        Copy-Item -Path $_.FullName -Destination $DestinationFile
        Write-Host "Skopiowano: $($_.FullName) do $DestinationPath"
    } else {
        Write-Host "Plik już istnieje: $DestinationFile"
    }
}
