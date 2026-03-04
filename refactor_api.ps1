$ErrorActionPreference = "Stop"
$baseDir = "d:\latihan\my repo\dangling\DanglingMobile\lib"

function Replace-InFile {
    param($Path, $Old, $New)
    $fullPath = Join-Path $baseDir $Path
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw
        $content = $content -replace [regex]::Escape($Old), $New
        Set-Content -Path $fullPath -Value $content -NoNewline
    }
}

# 1. Tambah Pedagang (Profile)
Replace-InFile "features\profile\views\profil\component\tambahpedagang.dart" "import 'package:damping/service/ApiService.dart';" "import 'package:damping/features/profile/services/store_api.dart';"
Replace-InFile "features\profile\views\profil\component\tambahpedagang.dart" "final apiService = ApiService();" "final storeApi = StoreApi();"
Replace-InFile "features\profile\views\profil\component\tambahpedagang.dart" "apiService.upgradeToSeller" "storeApi.upgradeToSeller"

# 2. MyStore (Profile)
Replace-InFile "features\profile\views\profil\component\mystore.dart" "import 'package:damping/service/ApiService.dart';" "import 'package:damping/features/profile/services/store_api.dart';"
Replace-InFile "features\profile\views\profil\component\mystore.dart" "final ApiService apiService = ApiService();" "final StoreApi storeApi = StoreApi();"
Replace-InFile "features\profile\views\profil\component\mystore.dart" "apiService.getStoreStatus()" "storeApi.getStoreStatus()"
Replace-InFile "features\profile\views\profil\component\mystore.dart" "apiService.updateStatus(newStatus)" "storeApi.updateStatus(newStatus)"

# 3. Form Produk
Replace-InFile "features\products\views\produkAdmin\FormProdukScreen.dart" "import '../../service/ApiService.dart';" "import '../../services/product_api.dart';"
Replace-InFile "features\products\views\produkAdmin\FormProdukScreen.dart" "final ApiService _apiService = ApiService();" "final ProductApi _productApi = ProductApi();"
Replace-InFile "features\products\views\produkAdmin\FormProdukScreen.dart" "_apiService.tambahProduk" "_productApi.tambahProduk"

# 4. History
Replace-InFile "features\orders\views\history\historyscreen.dart" "import 'package:damping/service/ApiService.dart';" "import 'package:damping/features/orders/services/order_api.dart';"
Replace-InFile "features\orders\views\history\historyscreen.dart" "final ApiService _apiService = ApiService();" "final OrderApi _orderApi = OrderApi();"
Replace-InFile "features\orders\views\history\historyscreen.dart" "_apiService.orderHistory" "_orderApi.orderHistory"

# 5. Map
Replace-InFile "features\home\views\home\component\map.dart" "import 'package:damping/service/ApiService.dart';" "import 'package:damping/features/home/services/home_api.dart';"
Replace-InFile "features\home\views\home\component\map.dart" "late ApiService _apiService;" "late HomeApi _homeApi;"
Replace-InFile "features\home\views\home\component\map.dart" "_apiService = ApiService();" "_homeApi = HomeApi();"
Replace-InFile "features\home\views\home\component\map.dart" "_apiService.getOnlinePedagang(ApiService.baseUrl, token)" "_homeApi.getOnlinePedagang(token)"

# 6. Sign Up Form
Replace-InFile "features\authentication\views\sign_up\components\sign_up_form.dart" "import 'package:damping/service/ApiService.dart';" "import 'package:damping/features/authentication/services/auth_api.dart';"
Replace-InFile "features\authentication\views\sign_up\components\sign_up_form.dart" "final ApiService _apiService = ApiService();" "final AuthApi _authApi = AuthApi();"
Replace-InFile "features\authentication\views\sign_up\components\sign_up_form.dart" "_apiService.register" "_authApi.register"

# 7. Sign In Form
Replace-InFile "features\authentication\views\sign_in\components\sign_form.dart" "import 'package:damping/service/ApiService.dart';" "import 'package:damping/features/authentication/services/auth_api.dart';"
Replace-InFile "features\authentication\views\sign_in\components\sign_form.dart" "final ApiService apiService = ApiService();" "final AuthApi authApi = AuthApi();"
Replace-InFile "features\authentication\views\sign_in\components\sign_form.dart" "apiService.login" "authApi.login"

Write-Host "Replacement successful"
