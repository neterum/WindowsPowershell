$ProfileRoot = (Split-Path -Parent $script:MyInvocation.MyCommand.Path)
$env:path += ";$ProfileRoot"
$docs    =  $(resolve-path "$Env:userprofile\documents")
$desktop =  $(resolve-path "$Env:userprofile\desktop")
$repos = $(resolve-path "$Env:userprofile\source\repos")
