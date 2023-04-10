$ascii = @"  

     **       ****     ****   ****** 
    /**      /**/**   **/**  **////**
    /**      /**//** ** /** **    // 
    /**      /** //***  /**/**       
    /**      /**  //*   /**/**  
    /**      /**   /    /**//**    ** 
    /********/**        /** //******   v4.0
    //////// //         //   //////     

"@
#Funcion pendiente
#Script para robocopy (copiar de X a Y, Y a X, etc.)  Ejemplo copiar respaldo \\LMCSV03\Backup_LMC\lmcraj1-rc-1 a LMCNB0773
#Script para sacar informacion de equipo (modelo, sistema operativo, etc)


#Variables globales
#sourcePath = $PSScriptRoot

#Archivos globales
$defaultFileName = "computers.txt"
$tempFileName = "temp.txt"


<# MENU / SUB-MENUS #>
function Show-Menu {
    param ([string]$ascii = $ascii
    )
    Clear-Host
    Write-Host $ascii -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Menu principal"
    Write-Host ""
    Write-Host "1: Scripts de analisis y reconocimiento."
    Write-Host "2: Scripts de schtasks."
    Write-Host "3: Scripts de backup."
    Write-Host "4: Scripts de control de acceso."
    Write-Host "5: Scripts de MPCMDRUN."
    Write-Host "0: Salir."
    Write-Host ""
}

function Show-AnalisisMenu {
    Clear-Host
    Write-Host $ascii -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Scripts de analisis y reconocimiento"
    Write-Host ""
    Write-Host "1: Ping / Nslookup"
    Write-Host "2: Mostrar equipos online"
    Write-Host "3: Mostrar equipos offline"
    Write-Host "4: Mostrar equipos con VPN"
    Write-Host "5: Leer archivo generado (temp.txt)"
    Write-Host "0: Volver al menu principal"
    Write-Host ""
}

function Show-SchTasksMenu {
    Clear-Host
    Write-Host $ascii -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Scripts de Schtasks"
    Write-Host ""
    Write-Host "1: Crear X tarea en Schtasks"
    Write-Host "2: Leer X tarea en Schtasks"
    Write-Host "3: Modificar X tarea en Schtasks"
    Write-Host "4: Eliminar X tarea en Schtasks"
    Write-Host "0: Volver al menu principal"
    Write-Host ""
}

function Show-BackupMenu {
    Clear-Host
    Write-Host $ascii -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Scripts de backup"
    Write-Host ""
    Write-Host "1: Copiar archivos para el respaldo"
    Write-Host "2: Modificar archivos para el respaldo"
    Write-Host "3: Enviar archivos al equipo de destino"
    Write-Host "4: Crear carpeta en servidor"
    Write-Host "5: Obtener herencia de la carpeta"
    Write-Host "6: Deshabilitar herencia de la carpeta"
    Write-Host "7: Obtener permisos de la carpeta"
    Write-Host "8: Modificar permisos de la carpeta"
    Write-Host "0: Volver al menu principal"
    Write-Host ""
}

function Show-AccessControlMenu {
    Clear-Host
    Write-Host $ascii -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Scripts de control de acceso"
    Write-Host ""
    Write-Host "1: Obtener permisos de acceso de la carpeta"
    Write-Host "2: Ver permisos de X usuario en la carpeta"
    Write-Host "3: Agregar permisos de X usuario en la carpeta"
    Write-Host "0: Volver al menu principal"
    Write-Host ""
}

function Show-MPCMDRUNMenu {
    Clear-Host
    Write-Host $ascii -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Scripts de MPCMDRUN"
    Write-Host ""
    Write-Host "1: Analizar equipo con Windows Defender"
    Write-Host "2: Obtener log de resultados."
    Write-Host "0: Volver al menu principal"
    Write-Host ""
}

<# FUNCIONES DE DEPURACIÓN#>
function Test-Function {
    Show-Message -Message "Test" -Category "custom" -Delay 1 -Color "Cyan"
}

<# FUNCIONES AUXILIARES#>

# Mensajes <Success, Warning, Info, Error>
function Show-Message {
    
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$Category,
        [int]$Delay = 0,
        [string]$Color
    )
    
    switch ($Category.ToLower()) {
        "info" {
            $Color = "Blue"
            Write-Host $Message -ForegroundColor $Color
            Start-Sleep -Seconds $Delay 
        }
        "warning" {
            $Color = "DarkYellow"
            Write-Host $Message -ForegroundColor $Color 
            Start-Sleep -Seconds $Delay
        }
        "error" {
            $Color = "Red"
            Write-Host $Message -ForegroundColor $Color
            Start-Sleep -Seconds $Delay
        }
        "success" {
            $Color = "Green"
            Write-Host $Message -ForegroundColor $Color
            Start-Sleep -Seconds $Delay
        }
        "custom" {
            $Color = $Color
            Write-Host $Message -ForegroundColor $Color
            Start-Sleep -Seconds $Delay
        }
    }
}

# Validacion de directorio
function Test-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] 
        [string]$filePath
    )

    if (Test-Path $filePath -PathType Leaf) {
        $fileContent = Get-Content -Path $filePath -Raw 

        if ([string]::IsNullOrEmpty($fileContent) -eq $false) {
            return $true
        }
        else {
            Show-Message -Message "$filePath se encuentra vacio." -Category "Error" -Delay 1 
            return $false 
        }
    }
    else {
        Show-Message -Message "No se encuentra $filePath" -Category "Error" -Delay 1 
        return $false 
    }
}

#Select TextFile
function Select-TextFile {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $fileBrowser.Filter = "Text Files (*.txt)|*.txt"
    $fileBrowser.Title = "Seleccione un archivo de texto"
    $result = $fileBrowser.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return Get-Content $fileBrowser.FileName
    }
}

# Metodo de entrada de datos <Manual, Read file, Default>
function Set-Input {
    Write-Host $ascii -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Seleccionar el metodo de entrada para el ingreso de valores."
    Write-Host "1: Manual"
    Write-Host "2: Abrir un archivo .txt"
    Write-Host "3: Leer computers.txt (archivo por defecto)"
    Write-Host "0: Ir hacia atras"
    Write-Host ""

    do {
        $opt = Read-Host "Por favor seleccione un metodo de entrada"
    } while ($opt -notin ("1", "2", "3", "0"))

    if ($opt -eq "1") {
        $values = @()
        do {
            $value = Read-Host "Ingrese un valor (o escriba 'q' para terminar)"
            if ($value -ne "q") {
                $values += $value
            }
        } while ($value -ne "q")

        $saveFile = Read-Host "Desea guardar los valores en un archivo de texto? (Y/N)"
        if ($saveFile.ToUpper() -eq "Y") {
            $path = Read-Host "Ingrese la ruta y el nombre del archivo de texto donde desea guardar los valores (ej. \servers.txt)"
            $values | Out-File -FilePath $path
            Show-Message -Message "[$($values -join ', ')] Guardado exitosamente en $path" -Category "Success" -Delay 1
            return $values
        }
        else {
            return $values
        }
    }
    elseif ($opt -eq "2") {
        $values = Select-TextFile
        if (-not $values) {
            Show-Message -Message "No se ha seleccionado ningún archivo." -Category "Warning" -Delay 1
        }
    }
    elseif ($opt -eq "3") {
        $filePath = Join-Path -Path $PSScriptRoot -ChildPath $defaultFileName
        if (Test-Path -Path $filePath -PathType Leaf) {
            Show-Message -Message "Leyendo el archivo $defaultFileName, espera un momento..." -Category "Warning" -Delay 1
            $values = Get-Content $filePath
        }
        else {
            Show-Message -Message "El archivo por defecto no existe." -Category "Error" -Delay 1
        }
    }
    elseif ($opt -eq "0") {
        break
    }

    if ($values) {
        return $values
    }
}

#Generar archivo temporal con resultados
function New-TempFile {
    param (
        [Parameter(Mandatory = $false)]
        [string]$fileName,
        [Parameter(Mandatory = $false)]
        [array]$values
    )
    
    #Escribimos el valor en un archivo temporal
    $filePath = Join-Path -Path $PSScriptRoot -ChildPath $fileName
    $values | Out-File -FilePath $filePath -Encoding utf8

    #Devolvemos la ruta del archivo temporal
    Show-Message -Message "Se ha creado un archivo en $PSScriptRoot." -Category "Info" -Delay 5
}

#Leer archivo temporal con resultados
function Show-TempContent {
    $filePath = Join-Path -Path $PSScriptRoot -ChildPath $tempFileName

    if (Test-File -filePath $filePath) {
        $contentFile = Get-Content $filePath
        $contentFile | Sort-Object | Out-Host
        Show-Message -Message "Ubicacion: $filePath" -Category "Info" -Delay 3
    } 
}

<# FUNCIONES PRINCIPALES #>
function Ping-Nslookup {
    Clear-Host

    #Le preguntamos al usuario como va a ingresar los valores (Manual / Read file / Default)
    $values = Set-Input

    if ($values) {
        #Ejecutamos la funcion Ping-Values
        $pingResults = Ping-Values -values $values
        #Resultados
        $resultsArray = @()

        foreach ($key in $pingResults.Keys) {
            $value = $pingResults[$key]
            $result = [PSCustomObject]@{
                "Name"   = $key
                "IP"     = $value.IP
                "Status" = $value.Status
            }
            $resultsArray += $result
        }
    
        New-TempFile -values $resultsArray -fileName $tempFileName
    }
}

<# FUNCIONES SECUNDARIAS #>
function Ping-Values {
    param (
        [Parameter(Mandatory = $true)]
        [array]$values
    )

    # Crear una nueva tabla
    $results = @{}

    foreach ($value in $values) {
        try {
            # Hacemos un ping al valor actual del array
            $pingResult = Test-Connection -ComputerName $value -Count 1 -Quiet
            # Hacemos nslookup al valor actual del array
            $nslookupResult = nslookup $value 2>$null
            # Hacemos Resolve-DnsName al valor actual del array
            $resolveDnsResult = Resolve-DnsName -Name $value -ErrorAction SilentlyContinue

            # Obtenemos la dirección IP del resultado de nslookup
            if ($nslookupResult) {
                $ipAddress = ($nslookupResult | Select-String 'Address' | Select-Object -Skip 1 -First 1).ToString().Split(':')[1].Trim()
            }
            # Si nslookup no funciona, intentamos con Resolve-DnsName
            elseif ($resolveDnsResult) {
                $ipAddress = $resolveDnsResult.IPAddress
            }
            # Si ninguna de las dos funciona, dejamos la dirección IP vacía
            else {
                $ipAddress = ""
            }

            # Verifica si la dirección IP comienza con 172
            if ($pingResult -and $ipAddress.StartsWith("172")) {
                $status = "VPN"
            }
            # Si el ping y nslookup o Resolve-DnsName son exitosos y la IP no comienza con 172, se agrega una entrada al hashtable $results con la dirección IP del equipo
            elseif ($pingResult -and $ipAddress) {
                $status = "ONLINE"
            }
            # Si el ping es exitoso pero nslookup o Resolve-DnsName falla, se agrega una entrada al hashtable $results indicando que hay un problema de DNS, sin la dirección IP
            elseif ($pingResult -and !$ipAddress) {
                $status = "DNS_ERROR2"
            }
            # Si el ping no es exitoso, se agrega una entrada al hashtable $results sin la dirección IP
            else {
                $status = "OFFLINE"
            }

            $results.Add($value, [PSCustomObject]@{
                    "Name"   = $value
                    "IP"     = $ipAddress
                    "Status" = $status
                })

        }
        catch {
            # Si hay un error en el servidor DNS, se agrega una entrada al hashtable $results indicando que hay un problema de DNS, sin la dirección IP
            $status = "DNS_ERROR"
        }
    }

    return $results
}


Function Show-Status {
    param (
        [Parameter(Mandatory = $false)]
        [string]$status
    )
    $filePath = Join-Path -Path $PSScriptRoot -ChildPath $tempFileName
    if (Test-File -filePath $filePath) {
        $content = Get-Content $filePath | Select-String -Pattern $status

        foreach ($line in $content) {
            $data = $line -split '\s+' | Select-Object -Skip 1
            $name = $data[0]
            $ipAddress = $data[1]
            Show-Message -Message "$name ($ipAddress)" -Category "Success" -Delay 1
        }
    }

}


while ($true) {
    Show-Menu
    $inputOpt = Read-Host "Seleccione una opcion"
    switch ($inputOpt) {
        '1' {
            while ($true) {
                Show-AnalisisMenu
                $inputAnalisis = Read-Host "Seleccione una opcion"
                if ($inputAnalisis -eq '0') {
                    break 
                }
                elseif ($inputAnalisis -match '^[0-5]$') {
                    switch ($inputAnalisis) {
                        '1' { Ping-Nslookup }
                        '2' { Show-Status -status "ONLINE" }
                        '3' { Show-Status -status "OFFLINE" }
                        '4' { Test-Function }
                        '5' { Show-TempContent }
                    }
                }
                else {
                    Show-Message -Message "Opcion no valida. Por favor, intente de nuevo." -Category "Error" -Delay 1
                }
            }
        }
        '2' {
            while ($true) {
                Show-SchTasksMenu
                $inputSchTasks = Read-Host "Seleccione una opcion"
                if ($inputSchTasks -eq '0') {
                    break 
                }
                elseif ($inputSchTasks -match '^[0-4]$') {
                    switch ($inputSchTasks) {
                        '1' { Test-Function }
                        '2' { Test-Function }
                        '3' { Test-Function }
                        '4' { Test-Function }
                    }
                }
                else {
                    Show-Message -Message "Opcion no valida. Por favor, intente de nuevo." -Category "Error" -Delay 1
                }
            }
            
        }
        '3' {
            while ($true) {
                Show-BackupMenu
                $inputBackup = Read-Host "Seleccione una opcion"
                if ($inputBackup -eq '0') {
                    break 
                }
                elseif ($inputBackup -match '^[0-8]$') {
                    switch ($inputBackup) {
                        '1' { Test-Function }
                        '2' { Test-Function }
                        '3' { Test-Function }
                        '4' { Test-Function }
                        '5' { Test-Function }
                        '6' { Test-Function }
                        '7' { Test-Function }
                        '8' { Test-Function }
                    }
                }
                else {
                    Show-Message -Message "Opcion no valida. Por favor, intente de nuevo." -Category "Error" -Delay 1
                }
            }
        }
        '4' {
            while ($true) {
                Show-AccessControlMenu
                $inputAccessControl = Read-Host "Seleccione una opcion"
                if ($inputAccessControl -eq '0') {
                    break 
                }
                elseif ($inputAccessControl -match '^[0-3]$') {
                    switch ($inputAccessControl) {
                        '1' { Test-Function }
                        '2' { Test-Function }
                        '3' { Test-Function }
                    }
                }
                else {
                    Show-Message -Message "Opcion no valida. Por favor, intente de nuevo." -Category "Error" -Delay 1
                }
            }
        }
        '5' {
            while ($true) {
                Show-MPCMDRUNMenu
                $inputMPCMDRUN = Read-Host "Seleccione una opcion"
                if ($inputMPCMDRUN -eq '0') {
                    break 
                }
                elseif ($inputMPCMDRUN -match '^[0-2]$') {
                    switch ($inputMPCMDRUN) {
                        '1' { Test-Function }
                        '2' { Test-Function }
                    }
                }
                else {
                    Show-Message -Message "Opcion no valida. Por favor, intente de nuevo." -Category "Error" -Delay 1
                }
            }
        }
        '0' { 
            $confirm = Read-Host "Esta seguro de que desea salir? (Y/N)"
            if ($confirm -eq 'Y') {
                Show-Message -Message "Saliendo..." -Category "Info" -Delay 1
                exit
            }
            else {
                Show-Message -Message "Volviendo al menu principal" -Category "Info" -Delay 1
                break
            }
        } 
    }
}
