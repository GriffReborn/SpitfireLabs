# Define the path to the LABS folder
$LABSFolder = "F:\ProgramData\Spitfire\Spitfire Audio - LABS"

# Define the WhatIf mode (set to $true to enable "what if" mode)
$WhatIf = $true

# Define the path to the "Samples" folder within the LABS folder
$SamplesFolder = Join-Path -Path $LABSFolder -ChildPath "Samples"

# Check if LABS folder and Samples folder exist
if (!(Test-Path -Path $LABSFolder)) {
    Write-Output "The specified LABS folder path does not exist: $LABSFolder"
    return
}
if (!(Test-Path -Path $SamplesFolder)) {
    Write-Output "The specified Samples folder path does not exist within LABS folder: $SamplesFolder"
    return
}

# Step 1 (Reordered): For each LABS-prefixed folder in the Samples folder, create a "Samples" folder in each LABS-prefixed folder and move files
Get-ChildItem -Path $SamplesFolder -Directory | ForEach-Object {
    if ($_.Name -like "LABS*") {
        # Define the new "Samples" folder inside each LABS-prefixed folder
        $NewSamplesFolder = Join-Path -Path $_.FullName -ChildPath "Samples"
        
        # Create the "Samples" folder if it doesn't exist
        if ($WhatIf) {
            Write-Output "What if: Creating folder '$NewSamplesFolder'"
        } else {
            if (!(Test-Path -Path $NewSamplesFolder)) {
                New-Item -ItemType Directory -Path $NewSamplesFolder | Out-Null
            }
        }
        
        # Move each file from the LABS-prefixed folder to the new "Samples" folder
        Get-ChildItem -Path $_.FullName -File | ForEach-Object {
            $Destination = Join-Path -Path $NewSamplesFolder -ChildPath $_.Name
            if ($WhatIf) {
                Write-Output "What if: Moving '$($_.FullName)' to '$Destination'"
            } else {
                Move-Item -Path $_.FullName -Destination $Destination -Force
            }
        }
    }
}

# Step 2 (Moved to second): Move folders with the "LABS" prefix and "common" from "Samples" folder to the LABS folder
Get-ChildItem -Path $SamplesFolder -Directory | ForEach-Object {
    if ($_.Name -like "LABS*" -or $_.Name -eq "common") {
        # Move each LABS-prefixed folder and "common" folder down one level
        $Destination = Join-Path -Path $LABSFolder -ChildPath $_.Name
        if ($WhatIf) {
            Write-Output "What if: Moving '$($_.FullName)' to '$Destination'"
        } else {
            Move-Item -Path $_.FullName -Destination $Destination -Force
        }
    }
}

Write-Output "Script execution complete. Check above output for any 'What if' actions or actual changes."
