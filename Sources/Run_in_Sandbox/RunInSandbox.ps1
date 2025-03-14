#***************************************************************************************************************
# Author: Damien VAN ROBAEYS
# Website: http://www.systanddeploy.com
# Twitter: https://twitter.com/syst_and_deploy
#***************************************************************************************************************
Param
 (
	[String]$Type,	  
	[String]$ScriptPath	
 )

$special_char_array = 'é','è','à','â','ê','û','î','ä','ë','ü','ï','ö','ù','ò','~','!','@','#','$','%','^','&','+','=','}','{','|','<','>',';'
foreach($char in $special_char_array)
{
	If($ScriptPath -like "*$char*")
		{
			[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
			[System.Windows.Forms.MessageBox]::Show("There is a special character in the path of the file :-(`nWindows Sandbox does not support this !!!","Issue with your file",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
			EXIT
		}
}

If(($Type -eq "Folder_Inside") -or ($Type -eq "Folder_On"))
{
	$DirectoryName = (get-item $ScriptPath).fullname
}
Else
{
	$FolderPath = Split-Path (Split-Path "$ScriptPath" -Parent) -Leaf
	$DirectoryName = (get-item $ScriptPath).DirectoryName
	$FileName = (get-item $ScriptPath).BaseName
	$Full_FileName = (get-item $ScriptPath).Name	
}

$Sandbox_Desktop_Path = "C:\Users\WDAGUtilityAccount\Desktop"
$Sandbox_Shared_Path = "$Sandbox_Desktop_Path\$FolderPath"
$Full_Startup_Path = "$Sandbox_Shared_Path\$Full_FileName"
$Full_Startup_Path = """$Full_Startup_Path"""

$ProgData = $env:ProgramData
$Run_in_Sandbox_Folder = "$ProgData\Run_in_Sandbox"

$xml = "$Run_in_Sandbox_Folder\Sandbox_Config.xml"
$my_xml = [xml] (Get-Content $xml)
$Sandbox_VGpu = $my_xml.Configuration.VGpu
$Sandbox_Networking = $my_xml.Configuration.Networking
$Sandbox_ReadOnlyAccess = $my_xml.Configuration.ReadOnlyAccess
$Sandbox_WSB_Location = $my_xml.Configuration.WSB_Location
$Sandbox_AudioInput = $my_xml.Configuration.AudioInput
$Sandbox_VideoInput = $my_xml.Configuration.VideoInput
$Sandbox_ProtectedClient = $my_xml.Configuration.ProtectedClient
$Sandbox_PrinterRedirection = $my_xml.Configuration.PrinterRedirection
$Sandbox_ClipboardRedirection = $my_xml.Configuration.ClipboardRedirection
$Sandbox_MemoryInMB = $my_xml.Configuration.MemoryInMB

If($Sandbox_WSB_Location -eq "Default")
	{
		$User_Profile = $env:USERPROFILE
		$User_Desktop = "$User_Profile\Desktop"
		$Sandbox_File_Path = "$env:temp\$FileName.wsb"			
	}
Else
	{
		$Sandbox_File_Path = "$Sandbox_WSB_Location\$FileName.wsb"			
	}

If(test-path $Sandbox_File_Path)
	{
		remove-item $Sandbox_File_Path
	}

If($Type -eq "Intunewin")
	{
		$Intunewin_Folder = "C:\IntuneWin\$FileName.intunewin"	
		$Intunewin_Content_File = "$Run_in_Sandbox_Folder\Intunewin_Folder.txt"
		$Intunewin_Folder | out-file $Intunewin_Content_File
		
		$Full_Startup_Path = $Full_Startup_Path.Replace('"',"")
	
		[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 	| out-null	
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.dll") | out-null 
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.IconPacks.dll") | out-null  	
		function LoadXml ($global:file1)
		{
			$XamlLoader=(New-Object System.Xml.XmlDocument)
			$XamlLoader.Load($file1)
			return $XamlLoader
		}

		$XamlMainWindow=LoadXml("$Run_in_Sandbox_Folder\RunInSandbox_Intunewin.xaml")
		$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
		$Form_PS1 = [Windows.Markup.XamlReader]::Load($Reader)		
			
		$install_command_intunewin = $Form_PS1.findname("install_command_intunewin") 
		$add_install_command = $Form_PS1.findname("add_install_command") 
		
		$add_install_command.add_click({
			$Script:install_command = $install_command_intunewin.Text.ToString()
			$Intunewin_Command_File = "$Run_in_Sandbox_Folder\Intunewin_Install_Command.txt"
			$install_command | out-file $Intunewin_Command_File			
			$Form_PS1.close()
		})
		
		$Form_PS1.Add_Closing({
			$Script:install_command = $install_command_intunewin.Text.ToString()
			$Intunewin_Command_File = "$Run_in_Sandbox_Folder\Intunewin_Install_Command.txt"
			$install_command | out-file $Intunewin_Command_File			
			$Form_PS1.close()		
		})			
				
		$Form_PS1.ShowDialog() | Out-Null			
	}
	

# If($Type -eq "EXE")
	# {
		# $Full_Startup_Path = $Full_Startup_Path.Replace('"',"")

		# [System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null	
		# [System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.dll") | out-null 
		# [System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.IconPacks.dll")      | out-null  
		# function LoadXml ($global:file2)
		# {
			# $XamlLoader=(New-Object System.Xml.XmlDocument)
			# $XamlLoader.Load($file2)
			# return $XamlLoader
		# }

		# $XamlMainWindow=LoadXml("$Run_in_Sandbox_Folder\RunInSandbox_EXE.xaml")
		# $Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
		# $Form_EXE=[Windows.Markup.XamlReader]::Load($Reader)		
			
		# $swicthes_for_exe = $Form_EXE.findname("swicthes_for_exe") 
		# $add_swicthes = $Form_EXE.findname("add_swicthes") 
		
		# $add_swicthes.Add_Click({
			# $Global:Swicthes_EXE = $swicthes_for_exe.Text.ToString()
			# $Script:Startup_Command = "$Full_Startup_Path $Swicthes_EXE"				

			# $EXE_Command_File = "$Run_in_Sandbox_Folder\EXE_Command_File.txt"
			# $Startup_Command | out-file $EXE_Command_File	
			
			# $Form_EXE.close()
		# })		
		
		# $Form_EXE.Add_Closing({
			# $Global:Swicthes_EXE = $swicthes_for_exe.Text.ToString()
			# $Script:Startup_Command = "$Full_Startup_Path $Swicthes_EXE"				

			# $EXE_Command_File = "$Run_in_Sandbox_Folder\EXE_Command_File.txt"
			# $Startup_Command | out-file $EXE_Command_File				
		# })	
		
		# $Form_EXE.ShowDialog() | Out-Null		
	# }

		


	

Function Generate_WSB
	{
		Param
		 (
			[String]$Command_to_Run,
			[String]$SDBApp_File			
		 )	
		 
		new-item $Sandbox_File_Path -type file -force | out-null
		add-content $Sandbox_File_Path  "<Configuration>"	
		add-content $Sandbox_File_Path  "<VGpu>$Sandbox_VGpu</VGpu>"	
		add-content $Sandbox_File_Path  "<Networking>$Sandbox_Networking</Networking>"	
		add-content $Sandbox_File_Path  "<AudioInput>$Sandbox_AudioInput</AudioInput>"	
		add-content $Sandbox_File_Path  "<VideoInput>$Sandbox_VideoInput</VideoInput>"	
		add-content $Sandbox_File_Path  "<ProtectedClient>$Sandbox_ProtectedClient</ProtectedClient>"	
		add-content $Sandbox_File_Path  "<PrinterRedirection>$Sandbox_PrinterRedirection</PrinterRedirection>"	
		add-content $Sandbox_File_Path  "<ClipboardRedirection>$Sandbox_ClipboardRedirection</ClipboardRedirection>"	
		add-content $Sandbox_File_Path  "<MemoryInMB>$Sandbox_MemoryInMB</MemoryInMB>"	

		add-content $Sandbox_File_Path  "<MappedFolders>"	
		If(($Type -eq "Intunewin") -or ($Type -eq "ISO") -or ($Type -eq "PS1System") -or ($Type -eq "SDBApp") -or ($Type -eq "7z") -or ($Type -eq "EXE"))		
			{
				add-content $Sandbox_File_Path  "<MappedFolder>"
				add-content $Sandbox_File_Path  "<HostFolder>C:\ProgramData\Run_in_Sandbox</HostFolder>"
				add-content $Sandbox_File_Path  "<SandboxFolder>C:\Run_in_Sandbox</SandboxFolder>" 	
				add-content $Sandbox_File_Path  "<ReadOnly>$Sandbox_ReadOnlyAccess</ReadOnly>"	
				add-content $Sandbox_File_Path  "</MappedFolder>"
			}

		If($Type -eq "SDBApp")
			{			
				$SDB_Full_Path = $ScriptPath
				copy-item $ScriptPath $Run_in_Sandbox_Folder -Force
				$Get_Apps_to_install = [xml](Get-Content $SDB_Full_Path)				
				$Apps_to_install_path = $Get_Apps_to_install.Applications.Application.Path | select -Unique

				ForEach($App_Path in $Apps_to_install_path)
					{
						add-content $Sandbox_File_Path  "<MappedFolder>"
						add-content $Sandbox_File_Path  "<HostFolder>$App_Path</HostFolder>"	
						add-content $Sandbox_File_Path  "<ReadOnly>$Sandbox_ReadOnlyAccess</ReadOnly>"	
						add-content $Sandbox_File_Path  "</MappedFolder>"					
					}													
			}				
			
		add-content $Sandbox_File_Path  "<MappedFolder>"	
		add-content $Sandbox_File_Path  "<HostFolder>$DirectoryName</HostFolder>"
		If ($Type -eq "IntuneWin"){add-content $Sandbox_File_Path  "<SandboxFolder>C:\IntuneWin</SandboxFolder>"	}
		add-content $Sandbox_File_Path  "<ReadOnly>$Sandbox_ReadOnlyAccess</ReadOnly>"	
		add-content $Sandbox_File_Path  "</MappedFolder>"
		
		add-content $Sandbox_File_Path  "<MappedFolder>"	
		add-content $Sandbox_File_Path  "<HostFolder>C:\ProgramData\Run_in_Sandbox\PsTools</HostFolder>"
		add-content $Sandbox_File_Path  "<SandboxFolder>C:\Pstools</SandboxFolder>"
		add-content $Sandbox_File_Path  "<ReadOnly>false</ReadOnly>"	
		add-content $Sandbox_File_Path  "</MappedFolder>"
		
		add-content $Sandbox_File_Path  "</MappedFolders>"	

		add-content $Sandbox_File_Path  "<LogonCommand>"	
		add-content $Sandbox_File_Path  "<Command>$Command_to_Run</Command>"		
		add-content $Sandbox_File_Path  "</LogonCommand>"	
		add-content $Sandbox_File_Path  "</Configuration>"		
	}

	
If($Type -eq "PS1Params")
	{
		$Full_Startup_Path = $Full_Startup_Path.Replace('"',"")
	
		[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 	| out-null	
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.dll") | out-null 
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.IconPacks.dll") | out-null  	
		function LoadXml ($global:file1)
		{
			$XamlLoader=(New-Object System.Xml.XmlDocument)
			$XamlLoader.Load($file1)
			return $XamlLoader
		}

		$XamlMainWindow=LoadXml("$Run_in_Sandbox_Folder\RunInSandbox_Params.xaml")
		$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
		$Form_PS1 = [Windows.Markup.XamlReader]::Load($Reader)		
			
		$parameters_to_add = $Form_PS1.findname("parameters_to_add") 
		$add_parameters = $Form_PS1.findname("add_parameters") 
		
		$add_parameters.add_click({
			$Script:Paramaters = $parameters_to_add.Text.ToString()
			$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -file $Full_Startup_Path $Paramaters"				
			
			Generate_WSB -Command_to_Run $Startup_Command				
			$Form_PS1.close()
		})
		
		$Form_PS1.Add_Closing({
			$Script:Paramaters = $parameters_to_add.Text.ToString()
			$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -file $Full_Startup_Path $Paramaters"				
			Generate_WSB -Command_to_Run $Startup_Command				
		})			
		
		
		$Form_PS1.ShowDialog() | Out-Null	
	}
	
ElseIf($Type -eq "PS1Basic")
	{
		$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -file $Full_Startup_Path"			
		Generate_WSB -Command_to_Run $Startup_Command		
	}	
	
ElseIf($Type -eq "PS1System")
	{
		$Script:Startup_Command = "C:\Users\WDAGUtilityAccount\Desktop\Run_in_Sandbox\PsExec.exe -accepteula -i -d -s powershell -executionpolicy bypass -file $Full_Startup_Path"
		Generate_WSB -Command_to_Run $Startup_Command	
	}	

ElseIf($Type -eq "ISO")
	{
		$Script:Startup_Command = "C:\Users\WDAGUtilityAccount\Desktop\Run_in_Sandbox\7z\7z.exe x -y -oC:\Users\WDAGUtilityAccount\Desktop\Extracted_ISO $Full_Startup_Path"
		Generate_WSB -Command_to_Run $Startup_Command	
	}	
	
ElseIf($Type -eq "7Z")
	{
		$Script:Startup_Command = "C:\Users\WDAGUtilityAccount\Desktop\Run_in_Sandbox\7z\7z.exe x -y -oC:\Users\WDAGUtilityAccount\Desktop\Extracted_File $Full_Startup_Path"
		Generate_WSB -Command_to_Run $Startup_Command	
	}	

ElseIf($Type -eq "PPKG")
	{		
		$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -command Install-ProvisioningPackage $Full_Startup_Path -forceinstall -quietinstall"			
		Generate_WSB -Command_to_Run $Startup_Command	
	}		
	
ElseIf($Type -eq "MSIX")
	{		
		$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -command Add-AppPackage -Path $Full_Startup_Path"			
		Generate_WSB -Command_to_Run $Startup_Command	
	}		
	
ElseIf(($Type -eq "HTML") -or ($Type -eq "URL"))
	{		
		$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -command start-process $Full_Startup_Path"							
		Generate_WSB -Command_to_Run $Startup_Command	
	}	

ElseIf($Type -eq "7z")
	{
		$Script:Startup_Command = "C:\Users\WDAGUtilityAccount\Desktop\Run_in_Sandbox\7z\7z.exe x -y -oC:\Users\WDAGUtilityAccount\Desktop\Extracted_7Z $Full_Startup_Path"
		Generate_WSB -Command_to_Run $Startup_Command	
	}		
	
ElseIf($Type -eq "Intunewin")
	{
		$Intunewin_Installer = "c:\Run_in_Sandbox\IntuneWin_Install.ps1"
		$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -file $Intunewin_Installer"
		Generate_WSB -Command_to_Run $Startup_Command			
	}	
	
ElseIf($Type -eq "SDBApp")
	{
		$AppBundle_Installer = "$Sandbox_Desktop_Path\Run_in_Sandbox\AppBundle_Install.ps1"
		$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -file $AppBundle_Installer"
		Generate_WSB -Command_to_Run $Startup_Command			
	}	

ElseIf($Type -eq "REG")
	{
		$Script:Startup_Command = "REG IMPORT $Full_Startup_Path"			
		Generate_WSB -Command_to_Run $Startup_Command		
	}	
		
ElseIf($Type -eq "EXE")
	{
		# $Full_Startup_Path = $Full_Startup_Path.Replace('"',"")

		# [System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null	
		# [System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.dll") | out-null 
		# [System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.IconPacks.dll")      | out-null  
		# function LoadXml ($global:file2)
		# {
			# $XamlLoader=(New-Object System.Xml.XmlDocument)
			# $XamlLoader.Load($file2)
			# return $XamlLoader
		# }

		# $XamlMainWindow=LoadXml("$Run_in_Sandbox_Folder\RunInSandbox_EXE.xaml")
		# $Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
		# $Form_EXE=[Windows.Markup.XamlReader]::Load($Reader)		
			
		# $swicthes_for_exe = $Form_EXE.findname("swicthes_for_exe") 
		# $add_swicthes = $Form_EXE.findname("add_swicthes") 
		
		# $add_swicthes.Add_Click({
			# $Global:Swicthes_EXE = $swicthes_for_exe.Text.ToString()
			# $Script:Startup_Command = "$Full_Startup_Path $Swicthes_EXE"				

			# Generate_WSB -Command_to_Run $Startup_Command						
			# $Form_EXE.close()
		# })		
		
		# $Form_EXE.Add_Closing({
			# $Global:Swicthes_EXE = $swicthes_for_exe.Text.ToString()
			# $Script:Startup_Command = "$Full_Startup_Path $Swicthes_EXE"				
			# Generate_WSB -Command_to_Run $Startup_Command						
		# })				
		
		# $Form_EXE.ShowDialog() | Out-Null		



		$Full_Startup_Path = $Full_Startup_Path.Replace('"',"")

		[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null	
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.dll") | out-null 
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.IconPacks.dll")      | out-null  
		function LoadXml ($global:file2)
		{
			$XamlLoader=(New-Object System.Xml.XmlDocument)
			$XamlLoader.Load($file2)
			return $XamlLoader
		}

		$XamlMainWindow=LoadXml("$Run_in_Sandbox_Folder\RunInSandbox_EXE.xaml")
		$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
		$Form_EXE=[Windows.Markup.XamlReader]::Load($Reader)		
			
		$swicthes_for_exe = $Form_EXE.findname("swicthes_for_exe") 
		$add_swicthes = $Form_EXE.findname("add_swicthes") 
		
		$add_swicthes.Add_Click({
			$Global:Swicthes_EXE = $swicthes_for_exe.Text.ToString()
			$Script:Startup_Command = "$Full_Startup_Path $Swicthes_EXE"				

			$EXE_Command_File = "$Run_in_Sandbox_Folder\EXE_Command_File.txt"
			$Startup_Command | out-file $EXE_Command_File	
			
			$Form_EXE.close()
		})		
		
		$Form_EXE.Add_Closing({
			$Global:Swicthes_EXE = $swicthes_for_exe.Text.ToString()
			$Script:Startup_Command = "$Full_Startup_Path $Swicthes_EXE"				

			$EXE_Command_File = "$Run_in_Sandbox_Folder\EXE_Command_File.txt"
			$Startup_Command | out-file $EXE_Command_File				
		})	
		
		$Form_EXE.ShowDialog() | Out-Null	



		$EXE_Installer = "$Sandbox_Desktop_Path\Run_in_Sandbox\EXE_Install.ps1"
		$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -file $EXE_Installer"
		Generate_WSB -Command_to_Run $Startup_Command			
	}	
	
ElseIf($Type -eq "MSI")
	{
		$Full_Startup_Path = $Full_Startup_Path.Replace('"',"")

		[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null	
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.dll") | out-null 
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.IconPacks.dll")      | out-null  
		function LoadXml ($global:file2)
		{
			$XamlLoader=(New-Object System.Xml.XmlDocument)
			$XamlLoader.Load($file2)
			return $XamlLoader
		}

		$XamlMainWindow=LoadXml("$Run_in_Sandbox_Folder\RunInSandbox_EXE.xaml")
		$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
		$Form_MSI=[Windows.Markup.XamlReader]::Load($Reader)		
			
		$swicthes_for_exe = $Form_MSI.findname("swicthes_for_exe") 
		$add_swicthes = $Form_MSI.findname("add_swicthes") 
		
		$add_swicthes.Add_Click({
			$Global:Swicthes_MSI = $swicthes_for_exe.Text.ToString()
			$Script:Startup_Command = "msiexec /i $Full_Startup_Path " + $Swicthes_MSI
			Generate_WSB -Command_to_Run $Startup_Command						
			$Form_MSI.close()
		})		
		
		$Form_MSI.Add_Closing({
			$Global:Swicthes_MSI = $swicthes_for_exe.Text.ToString()
			$Script:Startup_Command = "msiexec /i $Full_Startup_Path " + $Swicthes_MSI
			Generate_WSB -Command_to_Run $Startup_Command


C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -command 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs'
			
		})			
		
		$Form_MSI.ShowDialog() | Out-Null			
	}	

ElseIf($Type -eq "VBSParams")
	{
		$Full_Startup_Path = $Full_Startup_Path.Replace('"',"")
	
		[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 	| out-null	
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.dll") | out-null 
		[System.Reflection.Assembly]::LoadFrom("$Run_in_Sandbox_Folder\assembly\MahApps.Metro.IconPacks.dll") | out-null  	
		function LoadXml ($global:file1)
		{
			$XamlLoader=(New-Object System.Xml.XmlDocument)
			$XamlLoader.Load($file1)
			return $XamlLoader
		}

		$XamlMainWindow=LoadXml("$Run_in_Sandbox_Folder\RunInSandbox_Params.xaml")
		$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
		$Form_VBS = [Windows.Markup.XamlReader]::Load($Reader)		
			
		$parameters_to_add = $Form_VBS.findname("parameters_to_add") 
		$add_parameters = $Form_VBS.findname("add_parameters") 
		
		$add_parameters.add_click({
			$Script:Paramaters = $parameters_to_add.Text.ToString()
			$Script:Startup_Command = "wscript.exe $Full_Startup_Path $Paramaters"	
			Generate_WSB -Command_to_Run $Startup_Command					
			$Form_VBS.close()
		})
		
		$Form_VBS.Add_Closing({
			$Script:Paramaters = $parameters_to_add.Text.ToString()
			$Script:Startup_Command = "wscript.exe $Full_Startup_Path $Paramaters"			
			Generate_WSB -Command_to_Run $Startup_Command						
		})				

		$Form_VBS.ShowDialog() | Out-Null	
	}
	
ElseIf($Type -eq "VBSBasic")
	{
		$Script:Startup_Command = "wscript.exe $Full_Startup_Path"	
		
		Generate_WSB -Command_to_Run $Startup_Command		
	}
	
ElseIf($Type -eq "ZIP")
	{
		$Script:Startup_Command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -noprofile -executionpolicy unrestricted -command Expand-Archive $Full_Startup_Path $Sandbox_Desktop_Path"
		Generate_WSB -Command_to_Run $Startup_Command		
	}
	
ElseIf($Type -eq "Folder_Inside")
	{
		Generate_WSB	
	}

ElseIf($Type -eq "Folder_On")
	{
		Generate_WSB 		
	}	

& $Sandbox_File_Path