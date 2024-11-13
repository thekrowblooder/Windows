Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Ruta para guardar y cargar el archivo de respaldo
$backupFilePath = "C:\Program Files\TheKrowBlooder\temp\config_backup.txt"

# Diccionario de rutas base para claves de registro
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

# Función para obtener valores del registro
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

# Función para establecer valores en el registro
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

# Función para guardar las configuraciones actuales en un archivo
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

    # Guardar las configuraciones en el archivo de respaldo
    $configurations | Out-File -FilePath $backupFilePath
}

# Función para cargar las configuraciones desde el archivo de respaldo
function Load-ConfigurationsFromBackup {
    if (Test-Path $backupFilePath) {
        $configurations = Get-Content -Path $backupFilePath
        foreach ($line in $configurations) {
            $parts = $line.Split("=")
            if ($parts.Length -eq 2) {
                $name = $parts[0]
                $value = $parts[1]
                
                # Separar nombre y sección
                $section, $key = $name.Split("_")
                Set-RegistryValue -Section $section -Name $key -Value $value
            }
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("No se pudo encontrar el archivo de respaldo. No se puede revertir.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Función para aplicar todas las optimizaciones
function Apply-Optimizations {
    # Guardar las configuraciones actuales antes de aplicar las optimizaciones
    Save-CurrentConfigurations

    Set-RegistryValue -Section "PowerSettings" -Name "Attributes" -Value 0
    Set-RegistryValue -Section "TcpIpParameters" -Name "TcpAckFrequency" -Value 1
    Set-RegistryValue -Section "MemoryManagement" -Name "DisablePagingExecutive" -Value 1
    Set-RegistryValue -Section "PriorityControl" -Name "Win32PrioritySeparation" -Value 26
    Set-RegistryValue -Section "MouseSettings" -Name "MouseSpeed" -Value 1
    Set-RegistryValue -Section "GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2
    
    # Añadidos los ajustes faltantes
    Set-RegistryValue -Section "MouseClass" -Name "MouseDataQueueSize" -Value 50
    Set-RegistryValue -Section "NetworkAdapter" -Name "DisableTaskOffload" -Value 1
    Set-RegistryValue -Section "NetworkAdapter" -Name "EnableRSS" -Value 1

    [System.Windows.Forms.MessageBox]::Show("Las configuraciones se han optimizado con éxito para un mejor rendimiento.", "Optimización Aplicada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    UpdateStatus
}

# Función para revertir las optimizaciones a los valores guardados
function Revert-Optimizations {
    # Cargar configuraciones desde el archivo de respaldo y revertir a esos valores
    Load-ConfigurationsFromBackup

    [System.Windows.Forms.MessageBox]::Show("Las optimizaciones han sido revertidas a sus valores predeterminados.", "Reversión Completada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    UpdateStatus
}

# Función para actualizar los valores en la interfaz
function UpdateStatus {
    $textboxPowerSettings.Text = "Ajustes de energia: " + (Get-RegistryValue -Section "PowerSettings" -Name "Attributes")
    $textboxTcpIpParameters.Text = "Optimización de red (TCP): " + (Get-RegistryValue -Section "TcpIpParameters" -Name "TcpAckFrequency")
    $textboxMemoryManagement.Text = "Gestion de memoria: " + (Get-RegistryValue -Section "MemoryManagement" -Name "DisablePagingExecutive")
    $textboxPriorityControl.Text = "Prioridad del sistema: " + (Get-RegistryValue -Section "PriorityControl" -Name "Win32PrioritySeparation")
    $textboxMouseSettings.Text = "Velocidad del ratón: " + (Get-RegistryValue -Section "MouseSettings" -Name "MouseSpeed")
    $textboxGameConfigStore.Text = "Ajustes de juego (DVR): " + (Get-RegistryValue -Section "GameConfigStore" -Name "GameDVR_FSEBehaviorMode")
    
    # Actualizar los nuevos valores
    $textboxMouseDataQueueSize.Text = "Tamaño de cola del ratón: " + (Get-RegistryValue -Section "MouseClass" -Name "MouseDataQueueSize")
    $textboxNetworkOffload.Text = "Desactivación de Offload: " + (Get-RegistryValue -Section "NetworkAdapter" -Name "DisableTaskOffload")
    $textboxNetworkRSS.Text = "RSS Habilitado: " + (Get-RegistryValue -Section "NetworkAdapter" -Name "EnableRSS")
}

# Crear la interfaz gráfica
$form = New-Object System.Windows.Forms.Form
$form.Text = "Optimización del Sistema"
$form.Size = New-Object System.Drawing.Size(600, 550)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# TextBoxes para mostrar los valores de configuración
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

# Botones de aplicar, revertir y salir
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

# Nuevos botones
$button1 = New-Object System.Windows.Forms.Button
$button1.Location = New-Object System.Drawing.Point(20, 400)
$button1.Size = New-Object System.Drawing.Size(175, 30)
$button1.Text = "Botón 1"
$button1.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$button1.Add_Click({
    # Aquí agregarás la acción para el botón 1
})

$button2 = New-Object System.Windows.Forms.Button
$button2.Location = New-Object System.Drawing.Point(215, 400)
$button2.Size = New-Object System.Drawing.Size(175, 30)
$button2.Text = "Botón 2"
$button2.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$button2.Add_Click({
    # Aquí agregarás la acción para el botón 2
})

$button3 = New-Object System.Windows.Forms.Button
$button3.Location = New-Object System.Drawing.Point(410, 400)
$button3.Size = New-Object System.Drawing.Size(175, 30)
$button3.Text = "Botón 3"
$button3.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$button3.Add_Click({
    # Aquí agregarás la acción para el botón 3
})

# Añadir los controles al formulario
$form.Controls.AddRange(@(
    $textboxPowerSettings, $textboxTcpIpParameters, $textboxMemoryManagement,
    $textboxPriorityControl, $textboxMouseSettings, $textboxGameConfigStore,
    $textboxMouseDataQueueSize, $textboxNetworkOffload, $textboxNetworkRSS,
    $applyButton, $revertButton, $exitButton, $button1, $button2, $button3
))

# Actualizar la interfaz con el estado actual
UpdateStatus

# Mostrar el formulario
$form.ShowDialog()
