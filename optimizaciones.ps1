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
        return "Error: sección no definida"
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

    [System.Windows.Forms.MessageBox]::Show("Las configuraciones se han optimizado con éxito para un mejor rendimiento.", "Optimización Aplicada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    UpdateStatus
}

function Revert-Optimizations {
    Load-ConfigurationsFromBackup

    [System.Windows.Forms.MessageBox]::Show("Las optimizaciones han sido revertidas a sus valores predeterminados.", "Reversión Completada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    UpdateStatus
}

function UpdateStatus {
    $textboxPowerSettings.Text = "Ajustes de energia: " + (Get-RegistryValue -Section "PowerSettings" -Name "Attributes")
    $textboxTcpIpParameters.Text = "Optimización de red (TCP): " + (Get-RegistryValue -Section "TcpIpParameters" -Name "TcpAckFrequency")
    $textboxMemoryManagement.Text = "Gestion de memoria: " + (Get-RegistryValue -Section "MemoryManagement" -Name "DisablePagingExecutive")
    $textboxPriorityControl.Text = "Prioridad del sistema: " + (Get-RegistryValue -Section "PriorityControl" -Name "Win32PrioritySeparation")
    $textboxMouseSettings.Text = "Velocidad del ratón: " + (Get-RegistryValue -Section "MouseSettings" -Name "MouseSpeed")
    $textboxGameConfigStore.Text = "Ajustes de juego (DVR): " + (Get-RegistryValue -Section "GameConfigStore" -Name "GameDVR_FSEBehaviorMode")
    $textboxMouseDataQueueSize.Text = "Tamaño de cola del ratón: " + (Get-RegistryValue -Section "MouseClass" -Name "MouseDataQueueSize")
    $textboxNetworkOffload.Text = "Desactivación de Offload: " + (Get-RegistryValue -Section "NetworkAdapter" -Name "DisableTaskOffload")
    $textboxNetworkRSS.Text = "RSS Habilitado: " + (Get-RegistryValue -Section "NetworkAdapter" -Name "EnableRSS")
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Optimización del Sistema"
$form.Size = New-Object System.Drawing.Size(600, 550)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$textboxPowerSettings = New-Object System.Windows.Forms.TextBox
$textboxPowerSettings.Location = New-Object System.Drawing.Point(20, 20)
$textboxPowerSettings.Size = New-Object System.Drawing.Size(540, 20)
$textboxPowerSettings.ReadOnly = $true
$textboxTcpIpParameters = New-Object System.Windows.Forms.TextBox
$textboxTcpIpParameters.Location = New-Object System.Drawing.Point(20, 50)
$textboxTcpIpParameters.Size = New-Object System.Drawing.Size(540, 20)
$textboxTcpIpParameters.ReadOnly = $true
$textboxMemoryManagement = New-Object System.Windows.Forms.TextBox
$textboxMemoryManagement.Location = New-Object System.Drawing.Point(20, 80)
$textboxMemoryManagement.Size = New-Object System.Drawing.Size(540, 20)
$textboxMemoryManagement.ReadOnly = $true
$textboxPriorityControl = New-Object System.Windows.Forms.TextBox
$textboxPriorityControl.Location = New-Object System.Drawing.Point(20, 110)
$textboxPriorityControl.Size = New-Object System.Drawing.Size(540, 20)
$textboxPriorityControl.ReadOnly = $true
$textboxMouseSettings = New-Object System.Windows.Forms.TextBox
$textboxMouseSettings.Location = New-Object System.Drawing.Point(20, 140)
$textboxMouseSettings.Size = New-Object System.Drawing.Size(540, 20)
$textboxMouseSettings.ReadOnly = $true
$textboxGameConfigStore = New-Object System.Windows.Forms.TextBox
$textboxGameConfigStore.Location = New-Object System.Drawing.Point(20, 170)
$textboxGameConfigStore.Size = New-Object System.Drawing.Size(540, 20)
$textboxGameConfigStore.ReadOnly = $true
$textboxMouseDataQueueSize = New-Object System.Windows.Forms.TextBox
$textboxMouseDataQueueSize.Location = New-Object System.Drawing.Point(20, 200)
$textboxMouseDataQueueSize.Size = New-Object System.Drawing.Size(540, 20)
$textboxMouseDataQueueSize.ReadOnly = $true
$textboxNetworkOffload = New-Object System.Windows.Forms.TextBox
$textboxNetworkOffload.Location = New-Object System.Drawing.Point(20, 230)
$textboxNetworkOffload.Size = New-Object System.Drawing.Size(540, 20)
$textboxNetworkOffload.ReadOnly = $true
$textboxNetworkRSS = New-Object System.Windows.Forms.TextBox
$textboxNetworkRSS.Location = New-Object System.Drawing.Point(20, 260)
$textboxNetworkRSS.Size = New-Object System.Drawing.Size(540, 20)
$textboxNetworkRSS.ReadOnly = $true

$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Location = New-Object System.Drawing.Point(20, 300)
$applyButton.Size = New-Object System.Drawing.Size(250, 40)
$applyButton.Text = "Aplicar Optimizaciones"
$applyButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$applyButton.Add_Click({
    Apply-Optimizations
})

$revertButton = New-Object System.Windows.Forms.Button
$revertButton.Location = New-Object System.Drawing.Point(310, 300)
$revertButton.Size = New-Object System.Drawing.Size(250, 40)
$revertButton.Text = "Revertir Optimizaciones"
$revertButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$revertButton.Add_Click({
    Revert-Optimizations
})

$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Location = New-Object System.Drawing.Point(150, 360)
$exitButton.Size = New-Object System.Drawing.Size(300, 30)
$exitButton.Text = "Salir"
$exitButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$exitButton.Add_Click({
    $form.Close()
})

$button1 = New-Object System.Windows.Forms.Button
$button1.Location = New-Object System.Drawing.Point(20, 400)
$button1.Size = New-Object System.Drawing.Size(540, 40)
$button1.Text = "Añadir optimización al menú contextual"
$button1.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$button1.Add_Click({
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
        )

        foreach ($file in $files) {
            $filename = [System.IO.Path]::GetFileName($file.Split('?')[0])  # Limpiar la URL para obtener el nombre del archivo
            $destination = [System.IO.Path]::Combine($menuContextualPath, $filename)
            Invoke-WebRequest -Uri $file -OutFile $destination
        }

        $regFileUrl = "https://github.com/thekrowblooder/Windows/blob/main/menucontextual/menucontextual.reg?raw=true"
        Invoke-WebRequest -Uri $regFileUrl -OutFile $tempPath
        Start-Process -FilePath $tempPath -ArgumentList "/s" -Wait

        [System.Windows.Forms.MessageBox]::Show("Los archivos se han descargado y el archivo de registro ha sido ejecutado correctamente.", "Operación completada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }

    Download-Files
})

$form.Controls.AddRange(@($button1))


$form.Controls.AddRange(@($button1))



$form.Controls.AddRange(@(
    $textboxPowerSettings, $textboxTcpIpParameters, $textboxMemoryManagement,
    $textboxPriorityControl, $textboxMouseSettings, $textboxGameConfigStore,
    $textboxMouseDataQueueSize, $textboxNetworkOffload, $textboxNetworkRSS,
    $applyButton, $revertButton, $exitButton, $button1, $button2, $button3
))

UpdateStatus

$form.ShowDialog()
