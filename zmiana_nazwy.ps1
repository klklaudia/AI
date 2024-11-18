# Przeszukaj wszystkie pliki w bieżącym folderze i podfolderach
Get-ChildItem -Recurse -File | ForEach-Object {
    # Sprawdź, czy nazwa pliku zawiera "PM25"
    if ($_.Name -like "*PM25*") {
        # Zamiana "PM25" na "PM2.5" w nazwie pliku
        $newName = $_.Name -replace "PM25", "PM2.5"

        # Utwórz pełną ścieżkę nowej nazwy pliku
        $newFullName = Join-Path -Path $_.DirectoryName -ChildPath $newName

        # Zmień nazwę pliku
        Rename-Item -Path $_.FullName -NewName $newFullName
        Write-Host "Zmieniono nazwę: $($_.FullName) na $newFullName"
    }
}
