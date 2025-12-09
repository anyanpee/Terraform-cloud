@echo off
REM Terraform Cloud Migration Script for Windows
REM This script helps automate the migration from S3 backend to Terraform Cloud

echo ==========================================
echo Terraform Cloud Migration Script
echo ==========================================
echo.

REM Check if Terraform is installed
where terraform >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Terraform is not installed. Please install Terraform first.
    exit /b 1
)

echo [SUCCESS] Terraform is installed
terraform version | findstr /R "Terraform"
echo.

REM Step 1: Backup current state
echo Step 1: Backing up current state...
set BACKUP_FILE=backup-state-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%.json
set BACKUP_FILE=%BACKUP_FILE: =0%
terraform state pull > %BACKUP_FILE% 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] State backed up to %BACKUP_FILE%
) else (
    echo [WARNING] Could not backup state (this is OK if state doesn't exist yet^)
)
echo.

REM Step 2: Get Terraform Cloud details
echo Step 2: Terraform Cloud Configuration
echo --------------------------------------
set /p ORG_NAME="Enter your Terraform Cloud organization name: "
set /p WORKSPACE_NAME="Enter your workspace name: "
echo.

REM Step 3: Check if already logged in
echo Step 3: Checking Terraform Cloud authentication...
if exist "%USERPROFILE%\.terraform.d\credentials.tfrc.json" (
    echo [SUCCESS] Already authenticated with Terraform Cloud
) else (
    echo [INFO] Please login to Terraform Cloud...
    terraform login
)
echo.

REM Step 4: Update backend configuration
echo Step 4: Updating backend configuration...
(
echo terraform {
echo   cloud {
echo     organization = "%ORG_NAME%"
echo.
echo     workspaces {
echo       name = "%WORKSPACE_NAME%"
echo     }
echo   }
echo }
) > backend-override.tf
echo [SUCCESS] Backend configuration created in backend-override.tf
echo.

REM Step 5: Migrate state
echo Step 5: Migrating state to Terraform Cloud...
echo [WARNING] You will be prompted to confirm the migration. Type 'yes' to proceed.
echo.

terraform init -migrate-state
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] State migrated successfully!
) else (
    echo [ERROR] Migration failed. Please check the errors above.
    exit /b 1
)
echo.

REM Step 6: Verify migration
echo Step 6: Verifying migration...
terraform state list >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] State is accessible from Terraform Cloud
    echo.
    echo Resources in state:
    terraform state list
) else (
    echo [ERROR] Could not access state from Terraform Cloud
    exit /b 1
)
echo.

REM Step 7: Cleanup
echo Step 7: Cleanup
set /p CLEANUP="Do you want to remove the backend-override.tf file? (y/n): "
if /i "%CLEANUP%"=="y" (
    del backend-override.tf
    echo [SUCCESS] Cleaned up backend-override.tf
    echo [INFO] Remember to update your main.tf with the cloud backend configuration
)
echo.

REM Success message
echo ==========================================
echo [SUCCESS] Migration completed successfully!
echo ==========================================
echo.
echo Next steps:
echo 1. Configure AWS credentials in Terraform Cloud workspace
echo    - AWS_ACCESS_KEY_ID (mark as sensitive^)
echo    - AWS_SECRET_ACCESS_KEY (mark as sensitive^)
echo.
echo 2. Test the setup:
echo    terraform plan
echo    terraform apply
echo.
echo 3. (Optional^) Connect to GitHub for automatic runs
echo.
echo [INFO] Visit your workspace: https://app.terraform.io/app/%ORG_NAME%/workspaces/%WORKSPACE_NAME%
echo.
pause
