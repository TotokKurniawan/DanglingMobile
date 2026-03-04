$ErrorActionPreference = "Stop"

$baseDir = "d:\latihan\my repo\dangling\DanglingMobile\lib"

# 1. Create Directories
$dirs = @(
    "core/network",
    "core/theme",
    "core/utils",
    "core/widgets",
    "core/routing",
    "core/providers",
    "features/authentication/views",
    "features/authentication/services",
    "features/authentication/providers",
    "features/orders/views",
    "features/orders/services",
    "features/orders/providers",
    "features/products/views",
    "features/products/services",
    "features/products/providers",
    "features/home/views",
    "features/profile/views",
    "features/chats/views",
    "features/notifications/views",
    "features/splash/views"
)

foreach ($d in $dirs) {
    $path = Join-Path $baseDir $d
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }
}

# 2. Move Files & Folders
function Move-IfExists {
    param($src, $dest)
    $srcPath = Join-Path $baseDir $src
    $destPath = Join-Path $baseDir $dest
    if (Test-Path $srcPath) {
        Move-Item -Force -Path $srcPath -Destination $destPath
    }
}

# Core moves
Move-IfExists "GradientBackground.dart" "core/widgets/"
Move-IfExists "constants.dart" "core/utils/"
Move-IfExists "enums.dart" "core/utils/"
Move-IfExists "theme.dart" "core/theme/"

# Move contents of components and helper to core
if (Test-Path (Join-Path $baseDir "components")) {
    Get-ChildItem -Path (Join-Path $baseDir "components") -File | Move-Item -Destination (Join-Path $baseDir "core/widgets/") -Force
    Remove-Item (Join-Path $baseDir "components") -Recurse -Force
}
if (Test-Path (Join-Path $baseDir "helper")) {
    Get-ChildItem -Path (Join-Path $baseDir "helper") -File | Move-Item -Destination (Join-Path $baseDir "core/utils/") -Force
    Remove-Item (Join-Path $baseDir "helper") -Recurse -Force
}

# Features views moves
Move-IfExists "screen/forgot_password" "features/authentication/views/"
Move-IfExists "screen/sign_in" "features/authentication/views/"
Move-IfExists "screen/sign_up" "features/authentication/views/"

Move-IfExists "screen/history" "features/orders/views/"
Move-IfExists "screen/pesanan" "features/orders/views/"

Move-IfExists "screen/produkAdmin" "features/products/views/"
Move-IfExists "screen/home" "features/home/views/"
Move-IfExists "screen/profil" "features/profile/views/"
Move-IfExists "screen/message" "features/chats/views/"
Move-IfExists "screen/notif" "features/notifications/views/"
Move-IfExists "screen/splash" "features/splash/views/"

# Move routing and main files to core/routing if desired, but we'll leave routes.dart in lib for now or move navigation.
Move-IfExists "navigation.dart" "core/routing/"
Move-IfExists "routes.dart" "core/routing/"

# Remove empty screen folder
if (Test-Path (Join-Path $baseDir "screen")) {
    Remove-Item (Join-Path $baseDir "screen") -Recurse -Force
}

# Move sharedProvider to core/providers
if (Test-Path (Join-Path $baseDir "service\sharedProvider.dart")) {
    Move-Item -Force -Path (Join-Path $baseDir "service\sharedProvider.dart") -Destination (Join-Path $baseDir "core\providers\")
}

# We'll leave ApiService.dart in service for a moment to break it manually later.

# 3. Fix Imports in all dart files
$dartFiles = Get-ChildItem -Path $baseDir -Filter *.dart -Recurse

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Components & Helpers -> core
    $content = $content -replace "package:damping/components/", "package:damping/core/widgets/"
    $content = $content -replace "package:damping/helper/", "package:damping/core/utils/"
    
    # Root level core files
    $content = $content -replace "package:damping/GradientBackground.dart", "package:damping/core/widgets/GradientBackground.dart"
    $content = $content -replace "package:damping/constants.dart", "package:damping/core/utils/constants.dart"
    $content = $content -replace "package:damping/enums.dart", "package:damping/core/utils/enums.dart"
    $content = $content -replace "package:damping/theme.dart", "package:damping/core/theme/theme.dart"
    $content = $content -replace "package:damping/navigation.dart", "package:damping/core/routing/navigation.dart"
    $content = $content -replace "package:damping/routes.dart", "package:damping/core/routing/routes.dart"

    # Shared Provider
    $content = $content -replace "package:damping/service/sharedProvider.dart", "package:damping/core/providers/sharedProvider.dart"

    # Screens -> Features
    $content = $content -replace "package:damping/screen/forgot_password/", "package:damping/features/authentication/views/forgot_password/"
    $content = $content -replace "package:damping/screen/sign_in/", "package:damping/features/authentication/views/sign_in/"
    $content = $content -replace "package:damping/screen/sign_up/", "package:damping/features/authentication/views/sign_up/"
    $content = $content -replace "package:damping/screen/history/", "package:damping/features/orders/views/history/"
    $content = $content -replace "package:damping/screen/pesanan/", "package:damping/features/orders/views/pesanan/"
    $content = $content -replace "package:damping/screen/produkAdmin/", "package:damping/features/products/views/produkAdmin/"
    $content = $content -replace "package:damping/screen/home/", "package:damping/features/home/views/home/"
    $content = $content -replace "package:damping/screen/profil/", "package:damping/features/profile/views/profil/"
    $content = $content -replace "package:damping/screen/message/", "package:damping/features/chats/views/message/"
    $content = $content -replace "package:damping/screen/notif/", "package:damping/features/notifications/views/notif/"
    $content = $content -replace "package:damping/screen/splash/", "package:damping/features/splash/views/splash/"

    Set-Content -Path $file.FullName -Value $content -NoNewline
}

Write-Host "Migration script completed successfully."
