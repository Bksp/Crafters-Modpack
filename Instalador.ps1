Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Crafters"
$form.Size = New-Object System.Drawing.Size(317, 120)
$form.StartPosition = "CenterScreen"

# Configurar colores para un tema oscuro
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White

$buttonUpdate = New-Object System.Windows.Forms.Button
$buttonUpdate.Location = New-Object System.Drawing.Point(0, 15)
$buttonUpdate.Size = New-Object System.Drawing.Size(150, 50)
$buttonUpdate.Text = "Actualizar Minecraft"
$buttonUpdate.BackColor = [System.Drawing.Color]::Purple # Color de fondo blanco
$buttonUpdate.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255) # Azul de Windows 11
$buttonUpdate.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat # Para un aspecto más moderno
$buttonUpdate.Add_Click({
    # Eliminar la carpeta "mods" si existe
    if (Test-Path "$env:APPDATA\.minecraft\mods") {
        Remove-Item -Path "$env:APPDATA\.minecraft\mods" -Recurse -Force
        Write-Host "   Eliminada la carpeta 'mods'" -ForegroundColor DarkMagenta
    }

    # Copiar los archivos
    Copy-Item -Path ".minecraft\*" -Destination "$env:APPDATA\.minecraft\" -Recurse -Force

    Write-Host " "
    Write-Host "Copia completa de todos los mods" -ForegroundColor DarkMagenta
    Write-Host " "
    Write-Host "              <3" -ForegroundColor Red

    # Cambiar el color del botón a verde
    $buttonUpdate.BackColor = [System.Drawing.Color]::Green
    $buttonUpdate.Text = "Listo"

    # Abrir ".\SKlauncher-3.2.exe"
    Start-Process -FilePath ".\SKlauncher-3.2.exe"
    # Cerrar el formulario después de hacer clic en "OK"
    $form.Close()
})
$form.Controls.Add($buttonUpdate)

$buttonCancel = New-Object System.Windows.Forms.Button
$buttonCancel.Location = New-Object System.Drawing.Point(150, 15)
$buttonCancel.Size = New-Object System.Drawing.Size(150, 50)
$buttonCancel.Text = "Cancelar"
$buttonCancel.BackColor = [System.Drawing.Color]::red # Color de fondo blanco
$buttonCancel.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255) # Rojo de Windows 11
$buttonCancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat # Para un aspecto más moderno
$buttonCancel.Add_Click({
    # Agrega aquí el código para cancelar la operación
    $form.Close()
})
$form.Controls.Add($buttonCancel)

# Definir el estilo del formulario
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false

# Mostrar el formulario
$form.ShowDialog() | Out-Null
