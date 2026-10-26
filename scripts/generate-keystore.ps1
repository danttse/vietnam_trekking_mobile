# ============================================================================
# Script: Generate Android Keystore for TrekVN App
# Usage: .\scripts\generate-keystore.ps1
# ============================================================================

Write-Host "🔐 TrekVN - Android Keystore Generator" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if keytool is available
try {
    $keytoolVersion = keytool -help 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "keytool not found"
    }
} catch {
    Write-Host "❌ ERROR: keytool not found!" -ForegroundColor Red
    Write-Host "   Please install Java JDK first." -ForegroundColor Yellow
    Write-Host "   Download from: https://www.oracle.com/java/technologies/downloads/`n" -ForegroundColor Yellow
    exit 1
}

# Configuration
$KEYSTORE_NAME = "trekvn-upload-keystore.jks"
$KEY_ALIAS = "trekvn-key-alias"
$KEYSTORE_PATH = "..\android\app\$KEYSTORE_NAME"
$KEY_PROPERTIES_PATH = "..\android\key.properties"

# Check if keystore already exists
if (Test-Path $KEYSTORE_PATH) {
    Write-Host "⚠️  Keystore already exists at: $KEYSTORE_PATH" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (yes/no)"
    if ($overwrite -ne "yes") {
        Write-Host "❌ Aborted. Existing keystore preserved." -ForegroundColor Yellow
        exit 0
    }
    Remove-Item $KEYSTORE_PATH -Force
}

Write-Host "📝 Please provide the following information:`n" -ForegroundColor Green

# Collect information
$storePassword = Read-Host "Enter keystore password (remember this!)" -AsSecureString
$storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword)
)

$keyPassword = Read-Host "Enter key password (can be same as keystore)" -AsSecureString
$keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword)
)

Write-Host "`n📋 Organization information:" -ForegroundColor Cyan
$dname = @{
    CN = Read-Host "Your name or organization name"
    OU = Read-Host "Organizational unit (e.g., Development)"
    O = Read-Host "Organization (e.g., TrekVN)"
    L = Read-Host "City (e.g., Ho Chi Minh City)"
    ST = Read-Host "State/Province (e.g., Ho Chi Minh)"
    C = Read-Host "Country code (e.g., VN)"
}

$dnameString = "CN=$($dname.CN), OU=$($dname.OU), O=$($dname.O), L=$($dname.L), ST=$($dname.ST), C=$($dname.C)"

Write-Host "`n🔨 Generating keystore..." -ForegroundColor Green

# Generate keystore
$generateCmd = "keytool -genkey -v -keystore `"$KEYSTORE_PATH`" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias `"$KEY_ALIAS`" -storepass `"$storePasswordPlain`" -keypass `"$keyPasswordPlain`" -dname `"$dnameString`""

try {
    Invoke-Expression $generateCmd
    
    if (Test-Path $KEYSTORE_PATH) {
        Write-Host "`n✅ Keystore generated successfully!" -ForegroundColor Green
        Write-Host "   Location: $KEYSTORE_PATH`n" -ForegroundColor Gray
        
        # Create key.properties file
        Write-Host "📝 Creating key.properties file..." -ForegroundColor Cyan
        
        $keyPropertiesContent = @"
storePassword=$storePasswordPlain
keyPassword=$keyPasswordPlain
keyAlias=$KEY_ALIAS
storeFile=app/$KEYSTORE_NAME
"@
        
        Set-Content -Path $KEY_PROPERTIES_PATH -Value $keyPropertiesContent
        
        Write-Host "✅ key.properties created successfully!" -ForegroundColor Green
        Write-Host "   Location: $KEY_PROPERTIES_PATH`n" -ForegroundColor Gray
        
        # Security reminder
        Write-Host "⚠️  IMPORTANT SECURITY REMINDERS:" -ForegroundColor Yellow
        Write-Host "   1. BACKUP your keystore file to a safe location" -ForegroundColor Yellow
        Write-Host "   2. NEVER commit .jks or key.properties to Git" -ForegroundColor Yellow
        Write-Host "   3. SAVE your passwords in a secure password manager" -ForegroundColor Yellow
        Write-Host "   4. Losing the keystore = cannot update app on Play Store!`n" -ForegroundColor Red
        
        # Save passwords reminder
        Write-Host "📋 Save these credentials securely:" -ForegroundColor Cyan
        Write-Host "   Keystore Password: $storePasswordPlain" -ForegroundColor Gray
        Write-Host "   Key Password: $keyPasswordPlain" -ForegroundColor Gray
        Write-Host "   Key Alias: $KEY_ALIAS`n" -ForegroundColor Gray
        
        Write-Host "✅ Setup complete! You can now build a signed release." -ForegroundColor Green
        Write-Host "   Next step: Run .\scripts\build-release.ps1`n" -ForegroundColor Cyan
        
    } else {
        throw "Keystore file not created"
    }
    
} catch {
    Write-Host "`n❌ ERROR: Failed to generate keystore" -ForegroundColor Red
    Write-Host "   Details: $_" -ForegroundColor Red
    exit 1
}
