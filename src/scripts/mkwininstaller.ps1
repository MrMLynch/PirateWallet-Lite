param (
    [Parameter(Mandatory=$true)][string]$version
)

$target="piratewallet-v$version"

Remove-Item -Path release/wininstaller -Recurse -ErrorAction Ignore  | Out-Null
New-Item release/wininstaller -itemtype directory                    | Out-Null

Copy-Item release/$target/piratewallet.exe     release/wininstaller/
Copy-Item release/$target/LICENSE           release/wininstaller/
Copy-Item release/$target/README.md         release/wininstaller/
Copy-Item release/$target/komodod.exe        release/wininstaller/
Copy-Item release/$target/komodo-cli.exe     release/wininstaller/

Get-Content src/scripts/pirate-qt-wallet.wxs | ForEach-Object { $_ -replace "RELEASE_VERSION", "$version" } | Out-File -Encoding utf8 release/wininstaller/pirate-qt-wallet.wxs

candle.exe release/wininstaller/pirate-qt-wallet.wxs -o release/wininstaller/pirate-qt-wallet.wixobj 
if (!$?) {
    exit 1;
}

light.exe -ext WixUIExtension -cultures:en-us release/wininstaller/pirate-qt-wallet.wixobj -out release/wininstaller/piratewallet.msi 
if (!$?) {
    exit 1;
}

New-Item artifacts -itemtype directory -Force | Out-Null
Copy-Item release/wininstaller/piratewallet.msi ./artifacts/Windows-installer-$target.msi