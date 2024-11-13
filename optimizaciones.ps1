Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$backupFilePath = "C:\Program Files\TheKrowBlooder\temp\config_backup.txt"

$RegPaths = @{
    "PowerSettings" = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00"
    "TcpIpParameters" = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    "MemoryManagement" = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    "PriorityControl" = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    "MouseSettings" = "HKCU:\Control Panel\Mouse"
    "GameConfigStore" = "HKCU:\System\GameConfigStore"
    "MouseClass" = "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
    "NetworkAdapter" = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
}

function Get-RegistryValue {
    param (
        [string]$Section,
        [string]$Name
    )
    $Path = $RegPaths[$Section]
    if ($Path) {
        try {
            $value = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
            return $value
        } catch {
            return "No configurado"
        }
    } else {
        return "Error: seccion no definida"
    }
}

function Set-RegistryValue {
    param (
        [string]$Section,
        [string]$Name,
        [string]$Value
    )
    $Path = $RegPaths[$Section]
    if ($Path) {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value
    }
}

function Save-CurrentConfigurations {
    if (Test-Path $backupFilePath) {
        return  
    }

    $configurations = @(
        "PowerSettings_Attributes=$((Get-RegistryValue -Section 'PowerSettings' -Name 'Attributes'))",
        "TcpIpParameters_TcpAckFrequency=$((Get-RegistryValue -Section 'TcpIpParameters' -Name 'TcpAckFrequency'))",
        "MemoryManagement_DisablePagingExecutive=$((Get-RegistryValue -Section 'MemoryManagement' -Name 'DisablePagingExecutive'))",
        "PriorityControl_Win32PrioritySeparation=$((Get-RegistryValue -Section 'PriorityControl' -Name 'Win32PrioritySeparation'))",
        "MouseSettings_MouseSpeed=$((Get-RegistryValue -Section 'MouseSettings' -Name 'MouseSpeed'))",
        "GameConfigStore_GameDVR_FSEBehaviorMode=$((Get-RegistryValue -Section 'GameConfigStore' -Name 'GameDVR_FSEBehaviorMode'))",
        "MouseClass_MouseDataQueueSize=$((Get-RegistryValue -Section 'MouseClass' -Name 'MouseDataQueueSize'))",
        "NetworkAdapter_DisableTaskOffload=$((Get-RegistryValue -Section 'NetworkAdapter' -Name 'DisableTaskOffload'))",
        "NetworkAdapter_EnableRSS=$((Get-RegistryValue -Section 'NetworkAdapter' -Name 'EnableRSS'))"
    )
    
    $configurations | Out-File -FilePath $backupFilePath
}


function Load-ConfigurationsFromBackup {
    if (Test-Path $backupFilePath) {
        $configurations = Get-Content -Path $backupFilePath
        foreach ($line in $configurations) {
            $parts = $line.Split("=")
            if ($parts.Length -eq 2) {
                $name = $parts[0]
                $value = $parts[1]
                $section, $key = $name.Split("_")
                Set-RegistryValue -Section $section -Name $key -Value $value
            }
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("No se pudo encontrar el archivo de respaldo. No se puede revertir.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

function Apply-Optimizations {
    Save-CurrentConfigurations
    Set-RegistryValue -Section "PowerSettings" -Name "Attributes" -Value 0
    Set-RegistryValue -Section "TcpIpParameters" -Name "TcpAckFrequency" -Value 1
    Set-RegistryValue -Section "MemoryManagement" -Name "DisablePagingExecutive" -Value 1
    Set-RegistryValue -Section "PriorityControl" -Name "Win32PrioritySeparation" -Value 26
    Set-RegistryValue -Section "MouseSettings" -Name "MouseSpeed" -Value 1
    Set-RegistryValue -Section "GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2
    Set-RegistryValue -Section "MouseClass" -Name "MouseDataQueueSize" -Value 50
    Set-RegistryValue -Section "NetworkAdapter" -Name "DisableTaskOffload" -Value 1
    Set-RegistryValue -Section "NetworkAdapter" -Name "EnableRSS" -Value 1
    [System.Windows.Forms.MessageBox]::Show("Las configuraciones se han optimizado con exito para un mejor rendimiento.", "Optimizacion Aplicada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    UpdateStatus
}

function Revert-Optimizations {
    Load-ConfigurationsFromBackup
    [System.Windows.Forms.MessageBox]::Show("Las optimizaciones han sido revertidas a sus valores predeterminados.", "Reversion Completada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    UpdateStatus
}

function UpdateStatus {
    $textboxPowerSettings.Text = "Ajustes de energia: " + (Get-RegistryValue -Section "PowerSettings" -Name "Attributes")
    $textboxTcpIpParameters.Text = "Optimizacion de red (TCP): " + (Get-RegistryValue -Section "TcpIpParameters" -Name "TcpAckFrequency")
    $textboxMemoryManagement.Text = "Gestion de memoria: " + (Get-RegistryValue -Section "MemoryManagement" -Name "DisablePagingExecutive")
    $textboxPriorityControl.Text = "Prioridad del sistema: " + (Get-RegistryValue -Section "PriorityControl" -Name "Win32PrioritySeparation")
    $textboxMouseSettings.Text = "Velocidad del raton: " + (Get-RegistryValue -Section "MouseSettings" -Name "MouseSpeed")
    $textboxGameConfigStore.Text = "Ajustes de juego (DVR): " + (Get-RegistryValue -Section "GameConfigStore" -Name "GameDVR_FSEBehaviorMode")
    $textboxMouseDataQueueSize.Text = "Tamano de cola del raton: " + (Get-RegistryValue -Section "MouseClass" -Name "MouseDataQueueSize")
    $textboxNetworkOffload.Text = "Desactivacion de Offload: " + (Get-RegistryValue -Section "NetworkAdapter" -Name "DisableTaskOffload")
    $textboxNetworkRSS.Text = "RSS Habilitado: " + (Get-RegistryValue -Section "NetworkAdapter" -Name "EnableRSS")
}

function Download-Files {
    $menuContextualPath = [System.IO.Path]::Combine($env:ProgramFiles, "TheKrowBlooder", "menucontextual")
    $tempPath = [System.IO.Path]::Combine($env:TEMP, "menucontextual.reg")

    if (-not (Test-Path $menuContextualPath)) {
        New-Item -ItemType Directory -Force -Path $menuContextualPath
    }

    $files = @(
        "https://github.com/thekrowblooder/Windows/blob/main/menucontextual/TKB.ico?raw=true",
        "https://github.com/thekrowblooder/Windows/blob/main/menucontextual/mantenimiento.bat?raw=true",
        "https://github.com/thekrowblooder/Windows/blob/main/menucontextual/windowsupdateactive.bat?raw=true",
        "https://github.com/thekrowblooder/Windows/blob/main/menucontextual/windowsupdateinactive.bat?raw=true"
        "https://github.com/thekrowblooder/Windows/blob/main/quitarmenu.bat?raw=true"

    )

    foreach ($file in $files) {
        $filename = [System.IO.Path]::GetFileName($file.Split('?')[0])
        $destination = [System.IO.Path]::Combine($menuContextualPath, $filename)
        Invoke-WebRequest -Uri $file -OutFile $destination
    }

    $regFileUrl = "https://github.com/thekrowblooder/Windows/blob/main/menucontextual/menucontextual.reg?raw=true"
    Invoke-WebRequest -Uri $regFileUrl -OutFile $tempPath
    Start-Process -FilePath $tempPath -ArgumentList "/s" -Wait

    [System.Windows.Forms.MessageBox]::Show("Los archivos se han descargado y el archivo de registro ha sido ejecutado correctamente.", "Operacion completada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function Remove-ContextMenu {
    $batchFilePath = "C:\Program Files\TheKrowBlooder\menucontextual\quitarmenu.bat"
    
    if (Test-Path $batchFilePath) {
        try {
            # Ejecutar el archivo .bat
            Start-Process -FilePath $batchFilePath -Wait
        } catch {
            [System.Windows.Forms.MessageBox]::Show("No se pudo ejecutar. Error: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("No se pudo ejecutar.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}




$form = New-Object System.Windows.Forms.Form
$form.Text = "Configuraciones Avanzadas"
$form.Size = New-Object System.Drawing.Size(600, 540)  # Aumentar altura para acomodar botones
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)  # Fondo claro
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog  # No redimensionable
$form.MaximizeBox = $false  # Deshabilitar maximizar
$form.MinimizeBox = $false  # Deshabilitar minimizar

$font = New-Object System.Drawing.Font("Segoe UI", 10)

function CreateTextBox ($location, $width, $height) {
    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Location = $location
    $textbox.Size = New-Object System.Drawing.Size($width, $height)
    $textbox.Font = $font
    $textbox.ReadOnly = $true
    $textbox.BackColor = [System.Drawing.Color]::White
    $textbox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    return $textbox
}

$textboxPowerSettings = CreateTextBox (New-Object System.Drawing.Point(20, 20)) 540 30
$textboxTcpIpParameters = CreateTextBox (New-Object System.Drawing.Point(20, 60)) 540 30
$textboxMemoryManagement = CreateTextBox (New-Object System.Drawing.Point(20, 100)) 540 30
$textboxPriorityControl = CreateTextBox (New-Object System.Drawing.Point(20, 140)) 540 30
$textboxMouseSettings = CreateTextBox (New-Object System.Drawing.Point(20, 180)) 540 30
$textboxGameConfigStore = CreateTextBox (New-Object System.Drawing.Point(20, 220)) 540 30
$textboxMouseDataQueueSize = CreateTextBox (New-Object System.Drawing.Point(20, 260)) 540 30
$textboxNetworkOffload = CreateTextBox (New-Object System.Drawing.Point(20, 300)) 540 30
$textboxNetworkRSS = CreateTextBox (New-Object System.Drawing.Point(20, 340)) 540 30

function CreateButton ($text, $location, $width, $height) {
    $button = New-Object System.Windows.Forms.Button
    $button.Location = $location
    $button.Size = New-Object System.Drawing.Size($width, $height)
    $button.Text = $text
    $button.Font = $font
    $button.BackColor = [System.Drawing.Color]::FromArgb(100, 149, 237)  # Azul claro
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    return $button
}

$buttonWidth = 250
$buttonHeight = 40
$margin = 20  

$applyButton = CreateButton "Aplicar optimizaciones" (New-Object System.Drawing.Point(20, 380)) $buttonWidth $buttonHeight
$revertButton = CreateButton "Revertir a valores predeterminados" (New-Object System.Drawing.Point(20, 420)) $buttonWidth $buttonHeight
$downloadButton = CreateButton "Anadir opciones de menu contextual" (New-Object System.Drawing.Point(310, 380)) $buttonWidth $buttonHeight
$removeButton = CreateButton "Remover del menu contextual" (New-Object System.Drawing.Point(310, 420)) $buttonWidth $buttonHeight
$applyButton.Location = New-Object System.Drawing.Point(20, 380)
$revertButton.Location = New-Object System.Drawing.Point(20, 420)
$downloadButton.Location = New-Object System.Drawing.Point(310, 380)
$removeButton.Location = New-Object System.Drawing.Point(310, 420)
$applyButton.Add_Click({ Apply-Optimizations })
$revertButton.Add_Click({ Revert-Optimizations })
$downloadButton.Add_Click({
    Download-Files
})
$removeButton.Add_Click({
    Remove-ContextMenu
})

$form.Controls.AddRange(@(
    $textboxPowerSettings, $textboxTcpIpParameters, $textboxMemoryManagement,
    $textboxPriorityControl, $textboxMouseSettings, $textboxGameConfigStore,
    $textboxMouseDataQueueSize, $textboxNetworkOffload, $textboxNetworkRSS,
    $applyButton, $revertButton, $downloadButton, $removeButton
))

UpdateStatus

$form.ShowDialog()
