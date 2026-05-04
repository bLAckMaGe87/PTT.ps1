#if necessary import the audio device cmdlets
# Install the module
Install-Module -Name AudioDeviceCmdlets -Force

# Import it into your current session
Import-Module AudioDeviceCmdlets

function PTT()
{
param ( 
         [string]$portName
        )
$Signature = @'
[DllImport("user32.dll")]
public static extern short GetAsyncKeyState(int vKey);
'@
            $User32 = Add-Type -MemberDefinition $Signature -Name "Win32GetAsyncKeyState" -Namespace Win32Functions -PassThru
            $KeyToWatch = 0x10
            $KeyToWatch2 = 0x45 
            $KeyToWatch3 = 0x57
            $KeyToWatch4 = 0x54
            $breakloop = 0
            


            
            $dog = Get-AudioDevice -List | Where-Object { $_.Type -eq "Playback" }
            $cat = $dog | Where-Object {$_.name-match "AIOC*"} #name your AIOC playback device i.e. "...{$_.name-match "KO6HTC-AIOC*"}
            Set-AudioDevice -Index $cat.index #-Playback
            $port = New-Object System.IO.Ports.SerialPort $portName,9600,None,8,one #check your com number per device
            $port.open()
            Write-Host "PORT OPENING" -BackgroundColor DarkRed -ForegroundColor Blue
            Write-Host "DEFAULT PRESS <Q> to HOLD TX, <SHIFT> anytime TO PTT" -BackgroundColor DarkRed -ForegroundColor Blue
            Write-Host "<T> to terminate (close port)" -BackgroundColor DarkRed -ForegroundColor Blue

            #$alreadySaidOn = 0
            $alreadySaidOff = 0
            $keyBeingPushed = 0
            $keyAlreadyOn = 0 
            $PTTisOn = 0
             
            while($breakloop -ne 1)
            {
                
                $KeyState = $User32::GetAsyncKeyState($KeyToWatch)
                $isHeld = [bool]($KeyState -band 0x8000)
                $KeyState2 = $User32::GetAsyncKeyState($KeyToWatch2)
                $isHeld2 = [bool]($KeyState2 -band 0x8000)
                $KeyState3 = $User32::GetAsyncKeyState($KeyToWatch3)
                $isHeld3 = [bool]($KeyState3 -band 0x8000)
                $KeyState4 = $User32::GetAsyncKeyState($KeyToWatch4)
                $isHeld4 = [bool]($KeyState4 -band 0x8000)

                if($isHeld2)
                {
                    [System.Console]::Beep(1300, 200)

                }
                if($isHeld3)
                {
                    [System.Console]::Beep(900, 400)

                }
                if($isHeld4)
                {
                    $breakloop = 1

                }

                if($isHeld) 
                {
                        if($keyBeingPushed -eq 0)
                        {
                        write-host "_____________ON_____*_______" -BackgroundColor Black -ForegroundColor Green  
                        $port.DtrEnable = $true
                        $keyBeingPushed = 1
                        $keyAlreadyOn = 0
                            
                        }
                   
                }
                else 
                {

                    if($keyAlreadyOn -eq 0)
                    {
                    write-host "_____________OFF_____*_______" -BackgroundColor Black -ForegroundColor RED  
                    $port.DtrEnable = $false
                    $keyAlreadyOn = 1
                    }
                    $keyBeingPushed = 0
                   
                }
                if ([Console]::KeyAvailable)
                {

                   $key = [Console]::ReadKey($true) 
                   if($keyBeingPushed -eq 0)
                   {
                       if ($key.Key -eq "Q") 
                       {
                                if($PTTisOn -eq 0)
                                {
                                    write-host "_____________ON_____________" -BackgroundColor Black -ForegroundColor Green
                                    $port.DtrEnable = $true
                                     
                                    $PTTisOn = 1
                                }
                                elseif($PTTisOn -eq 1)
                                {
                                    write-host "_____________OFF_____ _______" -BackgroundColor Black -ForegroundColor RED
                                    $port.DtrEnable = $false
                                    $PTTisOn = 0
                                }
                             
                       } 
                       else 
                       {
                                    write-host "WRONG : KEY" -BackgroundColor Black -ForegroundColor YELLOW
                                    $port.DtrEnable = $false
                                    $PTTisOn = 0
                                    $alreadySaidOff = 1
                       }
                   }
                  
                }
 
            }
            $port.close()
}
<#
     .SYNOPSIS
        With the AIOC or similar CM108 functionality transmit via the DTR pin.
        May add device name later as a parameter.
    .DESCRIPTION
        Pressing (Q) with the function running will causes a transmission, (W) a semi-functional long tone and (E) a short one.
        Press (T) to terminate and close the loop and port. Press [SHIFT] anytime to transmit. The same for (T) to terminate.
    .PARAMETER portName
        We will (portName) to name the functional COM port used to activate the DTR pin. 
        Select your own output and input media to go with it.
     .EXAMPLE
        PTT -portName "COM3"
        PTT -portName COM5
        
#>
