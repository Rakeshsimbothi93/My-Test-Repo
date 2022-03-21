##################################################################################
#NOTE- This Script is designed under Deloitte DCI Launcher Team.                 #
#-Any changes to this script have to be taken consent from DCI Launcher Team.    #
#-STRICTLY- No Circulation of Scripts are allowed within Teams.                  #
#-All feedbacks will need to be communicated to DCI Launcher Team.               #
#-As a PILOT group, Please Adhere to the rules. 				 #
#-Script Owners: 								 #
#	-Gadepalli, Abhinav <agadepalli@DELOITTE.com>				 #
#	-Patnaik, Sandeep <sanpatnaik@deloitte.com>				 #
##################################################################################
Param(
#	[string]$giturl = $(throw "sourcesDirectory is null!"),
#   [string]$sourcebranch = $(throw "sourcebranch is null!"),
#   [string]$targetbranch = $(throw "targetbranch is null!"),
[string]$buildtype = $(throw "Build Type is null!"),
[string]$A2SourceBranch,
[string]$A2TargetBranch
)
function BuildDeltaStructure {
    Write-Host -ForegroundColor "Green" "****************************************"
    Write-Host -ForegroundColor "Green" "Starting build of delta structure......."
    $path = "./delta.txt"
    $drive = "./deploy-artifacts"
    New-Item -Path "./" -Name "deploy-artifacts" -ItemType "directory"
    #read line one by one
    ForEach($line in Get-Content -Path $path)
    {
        if ($line -Match "force-app"){
        $Fline = $line
        Write-Debug $Fline
    # get the file name
        $presult = $Fline.Substring(0, $Fline.LastIndexOf('/'))
        Write-Debug $presult
    #remove the file name from the path
        $result = $Fline.Trim($presult)
        Write-Debug $result
    #create the directory
        If(!(test-path $drive\$presult)){
            New-Item -Path $drive\$presult -ItemType Directory
        }
        else{
            Write-Debug "Directory already exist"
        }
    }
    else {
        Write-Debug "Delta build out of scope"
    }
    }
    Write-Host -ForegroundColor "Green" "Finishing build of delta structure......."
    Write-Host -ForegroundColor "Green" "****************************************"
}
function Copydeltafiles {
    Write-Host -ForegroundColor "Green" "***********************************"
    Write-Host -ForegroundColor "Green" "Starting Copy of delta files......."
    $path = "./delta.txt"
    $drive = "./deploy-artifacts"
    #read line one by one
    ForEach($line in Get-Content -Path $path)
    {
        if ($line -Match "force-app"){
		$sfline= $line
		#Write-Debug "Line is" $sfline
		#$sftype = ($sfline -split "/")[3]
		#Write-Debug "Type is" $sftype
        switch ($sfline) {
            {($_ -Match "classes") -or ($_ -Match "contentassets") -or ($_ -Match "pages") -or ($_ -Match "triggers") -or ($_ -Match "components")} {
                Write-Debug "Entering Classes type Condition"
                $Fline = $line
                Write-Debug $Fline
            # get the file name
                $presult = $Fline.Substring(0, $Fline.LastIndexOf('/'))
                Write-Debug $presult
            #remove the file name from the path
                $result = $Fline.Trim($presult)
                Write-Debug $result
            #For Classes
                $linexml= -join($line,"-meta.xml")
            #create the directory
				if ($line -Match "-meta.xml"){
                Copy-Item -Path $line $drive\$presult}
				else {
				Copy-Item -Path $line $drive\$presult 
                Copy-Item -Path $linexml $drive\$presult}}
            {($_ -Match "aura") -or ($_ -Match "lwc")} {
                Write-Debug "Entering Aura and LWC Condition"
                $Fline = $line
                Write-Debug $Fline
            # get the file name
                $presult = $Fline.Substring(0, $Fline.LastIndexOf('/'))
                Write-Debug $presult
            #remove the file name from the path
                #$result = $Fline.Trim($presult)
                #Write-Host $result
            #create the directory
                    Copy-Item -Path $presult\* $drive\$presult -recurse}
			{($_ -Match "staticresources")} {
                Write-Debug "Entering StaticResources"
                $Fline = $line
                Write-Debug $Fline
            # get the file name
                $presult = -join("force-app/main/default/","staticresources")
                Write-Debug $presult
            #remove the file name from the path
                #$result = $Fline.Trim($presult)
                #Write-Host $result
            #create the directory
                    Copy-Item -Path $presult\* $drive\$presult -recurse -Force}
			{($_ -Match "experiences")} {
                Write-Debug "Entering experiences"
                $Fline = $line
                Write-Debug $Fline
            # get the file name
                $presult = -join("force-app/main/default/","experiences")
                Write-Debug $presult
            #remove the file name from the path
                #$result = $Fline.Trim($presult)
                #Write-Host $result
            #create the directory
                    Copy-Item -Path $presult\* $drive\$presult -recurse -Force}
            {($_ -Match "reports")} {
                Write-Debug "Entering Reports Condition"
                $Fline = $line
                Write-Debug $Fline
            # get the file name
                $presult = $Fline.Substring(0, $Fline.LastIndexOf('/'))
                $pfresult = $presult.Substring(0, $presult.LastIndexOf('/'))
                Write-Debug $presult
            #remove the file name from the path
            $folname = ($presult.Substring($presult.LastIndexOf('/'))).Trim('/')
            $finfolname= -join($folname,".reportFolder-meta.xml")
            #create the directory
            if ($line -Match ".reportFolder-meta.xml")
			{
			Copy-Item -Path $line $drive\$presult -ErrorAction SilentlyContinue
			}
			else{
			Copy-Item -Path $line $drive\$presult -ErrorAction SilentlyContinue
            Copy-Item -Path $pfresult\$finfolname $drive\$pfresult -ErrorAction SilentlyContinue
			}}
            {($_ -Match "dashboards")} {
                Write-Debug "Entering Dashboards Condition"
                $Fline = $line
                Write-Debug $Fline
            # get the file name
                $presult = $Fline.Substring(0, $Fline.LastIndexOf('/'))
                $pfresult = $presult.Substring(0, $presult.LastIndexOf('/'))
                Write-Debug $presult
            #remove the file name from the path
            $folname = ($presult.Substring($presult.LastIndexOf('/'))).Trim('/')
            $finfolname= -join($folname,".dashboardFolder-meta.xml")
            #create the directory
			if ($line -Match ".dashboardFolder-meta.xml")
			{
			Copy-Item -Path $line $drive\$presult
			}
			else{
			Copy-Item -Path $line $drive\$presult
            Copy-Item -Path $pfresult\$finfolname $drive\$pfresult
			}}
            Default {
                Write-Debug "Entering Default Condition"
                $Fline = $line
                Write-Debug $Fline
            # get the file name
                $presult = $Fline.Substring(0, $Fline.LastIndexOf('/'))
                Write-Debug $presult
            #remove the file name from the path
                $result = $Fline.Trim($presult)
                Write-Debug $result
            #create the directory
				If(test-path $line){
                Copy-Item -Path $line $drive\$presult}
				else{Write-Debug "Artifact not found"}}
        }
    }
    else {
        Write-Debug "Delta build out of scope"
    }
    }
    Write-Host -ForegroundColor "Green" "Ending Copy of delta files......."
    Write-Host -ForegroundColor "Green" "***********************************"
	#$wshell = New-Object -ComObject Wscript.Shell
	#$wshell.Popup("Success: Delta Package built with name deploy-artifacts",0,"Done",0x40)
}
function gitactivity{
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

	$objForm = New-Object System.Windows.Forms.Form 
	$objForm.Text = "Delta Package Builder"
	$objForm.Size = New-Object System.Drawing.Size(320,400) 
	$objForm.StartPosition = "CenterScreen"

	$objForm.KeyPreview = $True
	$objForm.Add_KeyDown({
		if ($_.KeyCode -eq "Enter" -or $_.KeyCode -eq "Escape"){
			$objForm.Close()
		}
	})

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Size(75,250)
	$OKButton.Size = New-Object System.Drawing.Size(75,23)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$OKButton.Add_Click({$objForm.Close()})
	$objForm.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Size(150,250)
	$CancelButton.Size = New-Object System.Drawing.Size(75,23)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$CancelButton.Add_Click({$objForm.Close()})
	$objForm.Controls.Add($CancelButton)

	$objLabel = New-Object System.Windows.Forms.Label
	$objLabel.Location = New-Object System.Drawing.Size(10,20) 
	$objLabel.Size = New-Object System.Drawing.Size(350,40) 
	$objLabel.Text = "          Welcome to SFDX Delta Package Builder           "
	$objForm.Controls.Add($objLabel) 

	$objLabel = New-Object System.Windows.Forms.Label
	$objLabel.Location = New-Object System.Drawing.Size(10,60) 
	$objLabel.Size = New-Object System.Drawing.Size(280,20) 
	$objLabel.Text = "Enter GIT Repository URL:"
	$objForm.Controls.Add($objLabel)

	$giturl = New-Object System.Windows.Forms.TextBox 
	$giturl.Location = New-Object System.Drawing.Size(10,80) 
	$giturl.Size = New-Object System.Drawing.Size(260,20) 
	$objForm.Controls.Add($giturl) 

	$objLabel = New-Object System.Windows.Forms.Label
	$objLabel.Location = New-Object System.Drawing.Size(10,120) 
	$objLabel.Size = New-Object System.Drawing.Size(280,20) 
	$objLabel.Text = "Enter GIT Source Branch:"
	$objForm.Controls.Add($objLabel)
	$sourcebranch = New-Object System.Windows.Forms.TextBox 
	$sourcebranch.Location = New-Object System.Drawing.Size(10,140) 
	$sourcebranch.Size = New-Object System.Drawing.Size(260,20) 
	$objForm.Controls.Add($sourcebranch)

	$objLabel = New-Object System.Windows.Forms.Label
	$objLabel.Location = New-Object System.Drawing.Size(10,180) 
	$objLabel.Size = New-Object System.Drawing.Size(280,20) 
	$objLabel.Text = "Enter GIT Target Branch:"
	$objForm.Controls.Add($objLabel)
	$targetbranch = New-Object System.Windows.Forms.TextBox 
	$targetbranch.Location = New-Object System.Drawing.Size(10,200) 
	$targetbranch.Size = New-Object System.Drawing.Size(260,20) 
	$objForm.Controls.Add($targetbranch) 

	$objLabel = New-Object System.Windows.Forms.Label
	$objLabel.Location = New-Object System.Drawing.Size(10,340) 
	$objLabel.Size = New-Object System.Drawing.Size(280,20) 
	$objLabel.Text = "                             *Powered by Deloitte*                                "
	$objForm.Controls.Add($objLabel)

	$objForm.Topmost = $True

	$objForm.Add_Shown({$objForm.Activate()})
	$result = $objForm.ShowDialog()
	#Write-Host -ForegroundColor "Green" $result
	if (($giturl.Text) -and ($sourcebranch.Text) -and ($targetbranch.Text) -and ($result -eq "OK"))
	{
	Write-Host -ForegroundColor "Green" "GIT Repository URL: "$giturl.Text
	Write-Host -ForegroundColor "Green" "GIT Source Branch: "$sourcebranch.Text
	Write-Host -ForegroundColor "Green" "GIT Target Branch: "$targetbranch.Text

    Write-Host -ForegroundColor "Green" "*******************************************************"
	Write-Host -ForegroundColor "Green" "*                                                     *"
	Write-Host -ForegroundColor "Green" "*        *************************************        *"
	Write-Host -ForegroundColor "Green" "*     *SFDX Delta Deployment Launcher by Deloitte*    *"
	Write-Host -ForegroundColor "Green" "*        *************************************        *"
	Write-Host -ForegroundColor "Green" "*                                                     *"
	Write-Host -ForegroundColor "Green" "*******************************************************"
    Write-Host -ForegroundColor "Green" "Starting GIT Activities......."
	$giturlclone = $giturl.Text
	$sourcebranchgit = $sourcebranch.Text
	$targetbranchgit = $targetbranch.Text
    Write-Host -ForegroundColor "Green" "Cloning GIT Repository"
    $commandClone = -join("git clone ",$giturlclone)
    iex $commandClone
    $commandPost = -join("cd Salesforce_SCE")
    iex $commandPost
    Write-Host -ForegroundColor "Green" "Checking out Target Branch"
    $commandCheckoutTarget = -join("git checkout ",$targetbranchgit)
    iex $commandCheckoutTarget
    Write-Host -ForegroundColor "Green" "Checking out Source Branch"
    $commandCheckoutSource = -join("git checkout ",$sourcebranchgit)
    iex $commandCheckoutSource
    Write-Host -ForegroundColor "Green" "Computing Delta between branches......."
    $commandClone = -join("git diff --name-only ",$targetbranchgit," 1>delta.txt 2>&1")
    iex $commandClone
    Write-Host -ForegroundColor "Green" "Ending GIT Activities......."
    Write-Host -ForegroundColor "Green" "***********************************"
	}
	elseif ($result -eq "Cancel"){
	$wshell = New-Object -ComObject Wscript.Shell
	$wshell.Popup("Exit the Tool",0,"Exit",0x20)
	exit
	}
	else {
	$wshell = New-Object -ComObject Wscript.Shell
	$wshell.Popup("Error: Please enter required inputs",0,"Error",0x40)
	exit
	}
}
    try {
		if ($buildtype -eq "Manual"){
		Write-Host -ForegroundColor "Green" "Manual Build Type Selected"
		gitactivity
        	BuildDeltaStructure
        	Copydeltafiles
		}
		elseif ($buildtype -eq "AutomaticType1"){
		Write-Host -ForegroundColor "Green" "Automatic-Head<--->Head(n-1) Build Type Selected"
		#Any CI jobs will Clone the branch when the Job starts therefore cloning git repo is not required in Automatic path
		Write-Host -ForegroundColor "Green" "Checking out Target Branch"
		$commandCheckoutTarget = -join("git checkout ",$targetbranchgit)
		iex $commandCheckoutTarget
		Write-Host -ForegroundColor "Green" "Computing Delta between branches......."
		#Command to compute the delta and write to a delta.txt file
		$commandCompute = -join("git diff --name-only HEAD HEAD~1 ","1>delta.txt 2>&1")
		iex $commandCompute
		BuildDeltaStructure
        	Copydeltafiles
		}
		elseif ($buildtype -eq "AutomaticType2"){
		Write-Host -ForegroundColor "Green" "Automatic-Commit Build Type Selected"
		#Any CI jobs will Clone the branch when the Job starts therefore cloning git repo is not required in Automatic path
		Write-Host -ForegroundColor "Green" "Checking out Target Branch"
		$commandCheckoutTarget = -join("git checkout ",$A2TargetBranch)
		iex $commandCheckoutTarget
		Write-Host -ForegroundColor "Green" "Checking out Source Branch"
		$commandCheckoutSource = -join("git checkout ",$A2SourceBranch)
		iex $commandCheckoutSource
		Write-Host -ForegroundColor "Green" "Auto-Rebasing Source from Target"
		$commandMergeSource = -join("git rebase ",$A2TargetBranch)
		iex $commandMergeSource
		Write-Host -ForegroundColor "Green" "Fetching the latest commit from Source Branch"
		$commandSoureCommit = -join("git rev-parse --verify ",$A2SourceBranch)
		$Out1 = iex $commandSoureCommit
		Write-Host -ForegroundColor "Green" "Latest Commit from Source Branch " $A2SourceBranch "is" $Out1
		Write-Host -ForegroundColor "Green" "Fetching the latest commit from Target Branch"
		$commandTargetCommit = -join("git merge-base ",$A2SourceBranch," ",$A2TargetBranch)
		$Out2 = iex $commandTargetCommit
		Write-Host -ForegroundColor "Green" "Latest Commit from Target Branch " $A2TargetBranch "is" $Out2
		Write-Host -ForegroundColor "Green" "Computing Delta between branches......."
		#Command to compute the delta and write to a delta.txt file
		$commandCompute = -join("git diff --name-only ",$Out1," ",$Out2," 1>delta.txt 2>&1")
		iex $commandCompute
		BuildDeltaStructure
       		Copydeltafiles
		}
		elseif ($buildtype -eq "AutomaticType3"){
		Write-Host -ForegroundColor "Green" "Automatic-Commit Build Type Selected"
		#Any CI jobs will Clone the branch when the Job starts therefore cloning git repo is not required in Automatic path
		Write-Host -ForegroundColor "Green" "Checking git status"
		$commandPull = -join("git ","status")
		iex $commandPull
		Write-Host -ForegroundColor "Green" "Rebasing with Target branch for calculating diff"
		$commandRebase = -join("git rebase origin/",$A2TargetBranch)
		iex $commandRebase
		Write-Host -ForegroundColor "Green" "Computing Delta between branches......."
		#Command to compute the delta and write to a delta.txt file
		$commandCompute = -join("git diff --name-only origin/",$A2TargetBranch," 1>delta.txt 2>&1")
		iex $commandCompute
		BuildDeltaStructure
        	Copydeltafiles
		Write-Host -ForegroundColor "Green" "Delta Deployment Package:"
		$commandShowDelta = -join("Get-ChildItem -r ","deploy-artifacts/force-app/main/default")
		iex $commandShowDelta
		}
		elseif ($buildtype -eq "AutomaticType4"){
		Write-Host -ForegroundColor "Green" "*******************************************************"
		Write-Host -ForegroundColor "Green" "*                                                     *"
		Write-Host -ForegroundColor "Green" "*        *************************************        *"
		Write-Host -ForegroundColor "Green" "*     *SFDX Delta Deployment Launcher by Deloitte*    *"
		Write-Host -ForegroundColor "Green" "*        *************************************        *"
		Write-Host -ForegroundColor "Green" "*                                                     *"
		Write-Host -ForegroundColor "Green" "*******************************************************"
		Write-Host -ForegroundColor "Green" "Branch Comparision Build Type Selected"
		#Any CI jobs will Clone the branch when the Job starts therefore cloning git repo is not required in Automatic path
		git config user.name "USIndiaSCEDevOps"
		git config user.email usindiascedevops@deloitte.com
		Write-Host -ForegroundColor "Green" "Checkout Target Branch"
		$commandChkTarget = -join("git checkout ",$A2TargetBranch)
		iex $commandChkTarget
		Write-Host -ForegroundColor "Green" "Checkout Source Branch"
		$commandChkSource = -join("git checkout ",$A2SourceBranch)
		iex $commandChkSource
		Write-Host -ForegroundColor "Green" "Merging Source Branch with Target"
		$commandMerge = -join("git merge ",$A2TargetBranch)
		iex $commandMerge
		Write-Host -ForegroundColor "Green" "Computing Delta between branches......."
		#Command to compute the delta and write to a delta.txt file
		$commandCompute = -join("git diff --diff-filter=d --name-only ",$A2TargetBranch," 1>delta.txt 2>&1")
		iex $commandCompute
		BuildDeltaStructure
        Copydeltafiles
		Write-Host -ForegroundColor "Green" "Delta Deployment Package:"
		$commandShowDelta = -join("Get-ChildItem -r ","deploy-artifacts/force-app/main/default")
		iex $commandShowDelta
		}
		elseif ($buildtype -eq "AutomaticType5"){
		Write-Host -ForegroundColor "Green" "*******************************************************"
		Write-Host -ForegroundColor "Green" "*                                                     *"
		Write-Host -ForegroundColor "Green" "*        *************************************        *"
		Write-Host -ForegroundColor "Green" "*        *SFDX Delta Deployment Launcher by Deloitte* 	      *"
		Write-Host -ForegroundColor "Green" "*        *************************************        *"
		Write-Host -ForegroundColor "Green" "*                                                     *"
		Write-Host -ForegroundColor "Green" "*******************************************************"
		Write-Host -ForegroundColor "Green" "*******************************************************"
		Write-Host -ForegroundColor "Green" "Current Branch Build Type Selected"
		Write-Host -ForegroundColor "Green" "*******************************************************"
		#Any CI jobs will Clone the branch when the Job starts therefore cloning git repo is not required in Automatic path
		Write-Host -ForegroundColor "Green" "Checking Current Commit"
		$commandChkCurrentCommit = -join("git rev-parse ","HEAD")
		$commandChkCurrentCommitrslt= iex $commandChkCurrentCommit
		Write-Host -ForegroundColor "Green" "Current Commit is: "$commandChkCurrentCommitrslt
		Write-Host -ForegroundColor "Green" "*******************************************************"
		Write-Host -ForegroundColor "Green" "Checking Previous deployed commit"
		$commandChkLastCommit = -join("git merge-base ","HEAD HEAD~1")
		$commandChkLastCommitrslt = iex $commandChkLastCommit
		Write-Host -ForegroundColor "Green" "Previous deployed Commit is: "$commandChkLastCommitrslt
		Write-Host -ForegroundColor "Green" "*******************************************************"
		Write-Host -ForegroundColor "Green" "Computing Delta between two commits......."
		#Command to compute the delta and write to a delta.txt file
		$commandCompute = -join("git diff --name-only ",$commandChkCurrentCommitrslt," ",$commandChkLastCommitrslt," 1>delta.txt 2>&1")
		Write-Debug $commandCompute
		iex $commandCompute
		BuildDeltaStructure
        Copydeltafiles
		Write-Host -ForegroundColor "Green" "Delta Deployment Package:"
		$commandShowDelta = -join("Get-ChildItem -r ","deploy-artifacts/force-app/main/default")
		iex $commandShowDelta
		}
		else {
		$wshell = New-Object -ComObject Wscript.Shell
		$wshell.Popup("Error: Invalid Build Type",0,"Error",0x40)
		exit
		}
    }catch {
        Write-Host "##[error][$(get-date -Format 'dd/MM/yyyy HH:mm')] :: Error!"
        throw
    }
