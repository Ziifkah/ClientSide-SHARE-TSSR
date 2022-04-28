#CLIENT-SHARE
#Author: Dorian Duboc

#Variables

$global:listdir = (Get-ChildItem -Path $objTextbox.Text -Recurse -Directory).FullName

#Fonctions

#Script

# GUI 
# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms
# Create a new form
$MainForm = New-Object system.Windows.Forms.Form
# Define the size, title and background color
$MainForm.ClientSize         = "500,300"
$MainForm.text               = "Client Side - SHARE TSSR"
$MainForm.BackColor          = "#ffffff"

#List box
$global:listBox = New-Object System.Windows.Forms.ListBox
$global:listBox.Location = New-Object System.Drawing.Point(10,40) 
$global:listBox.Size = New-Object System.Drawing.Size(480,70)
$global:listBox.Anchor = "Top,Right,Bottom,Left" 
$global:listBox.items.AddRange($global:listdir)

#Add an event handler on the listbox to do something with the selected item
$global:listBox.Add_Click({
    #Here code to perform some action with the selected subfolder
    $global:selected = $global:listBox.GetItemText($global:listBox.SelectedItem)
    $clientBrowseButton.Enabled = $true
})
$MainForm.Controls.Add($global:listBox) 

#InputBox change server IP
$objTextbox = New-Object System.Windows.Forms.TextBox
$objTextbox.Location = New-Object System.Drawing.Size(60,10)
$objTextbox.Size = New-Object System.Drawing.Size(150,150)
$MainForm.Controls.Add($objTextbox)

#InputBox change server IP - PLACEHOLDER WATERMARK
$WatermarkText = "\\192.168.1.36\share_tssr"
$objTextbox.ForeColor = "Gray"
$objTextbox.Text = $WatermarkText

$textboxWatermark_Enter={
    if($objTextbox.Text -eq $objTextbox.Tag)
    {
        #Clear the text
        $objTextbox.Text = ""
        $objTextbox.ForeColor = 'WindowText'
    }
}

$textboxWatermark_Leave={
    if($objTextbox.Text -eq "")
    {
        #Display the watermark
        $objTextbox.Text = $objTextbox.Tag
        $objTextbox.ForeColor = 'Gray'
    }
}

$textboxWatermark_VisibleChanged={
    if($objTextbox.Visible -and $objTextbox.Tag -eq $null)
    {
        #Initialize the watermark and save it in the Tag property
        $objTextbox.Tag = $objTextbox.Text;
        $objTextbox.ForeColor = 'Gray'
        #If we have focus then clear out the text
        if($objTextbox.Focused)
        {
            $objTextbox.Text = ""
            $objTextbox.ForeColor = 'WindowText'
        }
    }
}

#InputBox OK button change server IP
$objButton = New-Object System.Windows.Forms.Button
$objButton.Location = New-Object System.Drawing.Size(10,8)
$objButton.Size = New-Object System.Drawing.Size(40,23)
$objButton.Text = "OK"
$objButton.Add_Click($button_click)
$MainForm.Controls.Add($objButton)

#InputBox Ok button Return status
$returnStatus = New-Object System.Windows.Forms.label
$returnStatus.Location = New-Object System.Drawing.Size(310,12)
$returnStatus.Size = New-Object System.Drawing.Size(130,20)
$returnStatus.BackColor = "Transparent"
$returnStatus.Text = ""
$MainForm.Controls.Add($returnStatus)
 
#Action item here
$button_click =
{ 
$returnStatus.Text = ""  
$dirshare = $objTextbox.Text
 
#Output - online  
if (Test-Path $dirshare){
$returnStatus.BackColor = "Transparent"
$returnStatus.ForeColor = "lime"
$returnStatus.Text = "Status: Trouvé"
#$MainForm.Controls.Add($global:listbox)
$global:listbox.Visible = $true
$clientBrowseButton.Visible = $true
$clientBrowseButtonSend.Visible = $true
}
Else{
#Output - offline
$returnStatus.ForeColor= "Red"
$returnStatus.Text = "Status: Introuvable"
#$MainForm.Controls.Remove($global:listbox)
$global:listbox.Visible = $false
$clientBrowseButton.Visible = $false
$global:clientBrowseTextSelection.Visible = $false
$clientBrowseButtonSend.Visible = $false
    } 
}  

#Button client browse file
$clientBrowseButton = New-Object System.Windows.Forms.Button
$clientBrowseButton.Location = New-Object System.Drawing.Size(10,120)
$clientBrowseButton.Size = New-Object System.Drawing.Size(100,20)
$clientBrowseButton.Text = "Sélection fichier"
$clientBrowseButton.Add_Click($clientBrowsebutton_click)
$clientBrowseButton.Enabled = $false
$MainForm.Controls.Add($clientBrowseButton)

#Action button client browse file
$clientBrowsebutton_click = { 
    Add-Type -AssemblyName System.Windows.Forms
    $initialDirectory = [Environment]::GetFolderPath('Desktop')
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Multiselect = $false
    $MainForm.Controls.Remove($global:clientBrowseTextSelection)
    $response = $OpenFileDialog.ShowDialog( ) # $response can return OK or Cancel
        if ( $response -eq 'OK' ) { 
            #Text client browse file selection
            $global:clientBrowseTextSelection = New-Object System.Windows.Forms.label
            $global:clientBrowseTextSelection.Location = New-Object System.Drawing.Size(140,123)
            $global:clientBrowseTextSelection.Size = New-Object System.Drawing.Size(200,80)
            $global:clientBrowseTextSelection.Text = $OpenFileDialog.FileName
            $clientBrowseButtonSend.Enabled = $true
            $MainForm.Controls.Add($global:clientBrowseTextSelection)
         }
}  

#Button send client browse file
$clientBrowseButtonSend = New-Object System.Windows.Forms.Button
$clientBrowseButtonSend.Location = New-Object System.Drawing.Size(10,190)
$clientBrowseButtonSend.Size = New-Object System.Drawing.Size(480,100)
$clientBrowseButtonSend.Text = "ENVOYER"
$clientBrowseButtonSend.Add_Click($clientBrowseButtonSendbutton_click)
$clientBrowseButtonSend.Enabled = $false
$MainForm.Controls.Add($clientBrowseButtonSend)

#Action button send client browse file
$clientBrowseButtonSendbutton_click = { 
Copy-Item –Path "C:\test.txt" –Destination $global:selected
#verif
#Invoke-Command -ScriptBlock { Get-ChildItem -Path "C:\test.txt" } -Session $MYSESSION
}  
   
#Modal
$MainForm.Add_Shown({$MainForm.Activate()})

#Display the form
$MainForm.TopMost = $True
$MainForm.ShowDialog()

