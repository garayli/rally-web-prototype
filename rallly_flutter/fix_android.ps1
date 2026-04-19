# Regenerate the Android project structure
$FLUTTER_SDK = "C:\Users\Leyla\.puro\envs\stable\flutter"
$DART        = "$FLUTTER_SDK\bin\cache\dart-sdk\bin\dart.exe"
$TOOLS_DART  = "$FLUTTER_SDK\packages\flutter_tools\bin\flutter_tools.dart"
$PKG_CONFIG  = "$FLUTTER_SDK\packages\flutter_tools\.dart_tool\package_config.json"

$env:FLUTTER_ROOT     = $FLUTTER_SDK
$env:ANDROID_HOME     = "C:\Users\Leyla\AppData\Local\Android\Sdk"
$env:ANDROID_SDK_ROOT = "C:\Users\Leyla\AppData\Local\Android\Sdk"
$env:JAVA_HOME        = "C:\Program Files\Android\Android Studio\jbr"

Set-Location $PSScriptRoot

# Back up our custom AndroidManifest before regenerating
$manifestSrc = "$PSScriptRoot\android\app\src\main\AndroidManifest.xml"
$manifestBak = "$PSScriptRoot\AndroidManifest.xml.bak"
Write-Output "Backing up AndroidManifest.xml..."
Copy-Item $manifestSrc $manifestBak -Force

# Regenerate Android platform files
Write-Output "Regenerating Android project structure..."
& $DART "--packages=$PKG_CONFIG" $TOOLS_DART create . --platforms android --org io.supabase.rallly 2>&1

Write-Output "Done! Restoring custom AndroidManifest.xml..."
Copy-Item $manifestBak $manifestSrc -Force
Remove-Item $manifestBak

Write-Output ""
Write-Output "Android project regenerated. Now building APK..."
& $DART "--packages=$PKG_CONFIG" $TOOLS_DART build apk --release
Write-Output ""
if ($LASTEXITCODE -eq 0) {
    $apk = "$PSScriptRoot\build\app\outputs\flutter-apk\app-release.apk"
    Write-Output "SUCCESS! APK at: $apk"
} else {
    Write-Output "Build failed - check errors above"
}
