Option Explicit
Dim shell, files, folder, executable, shortcut
Set shell = CreateObject("WScript.Shell")
Set files = CreateObject("Scripting.FileSystemObject")
folder = files.GetParentFolderName(WScript.ScriptFullName)
executable = files.BuildPath(folder, "MobaBot.exe")
If Not files.FileExists(executable) Then
    MsgBox "Extract the entire ZIP first, then run this helper beside MobaBot.exe.", 48, "MobaBot.io"
    WScript.Quit 1
End If
Set shortcut = shell.CreateShortcut(files.BuildPath(shell.SpecialFolders("Desktop"), "MobaBot.io.lnk"))
shortcut.TargetPath = executable
shortcut.WorkingDirectory = folder
shortcut.IconLocation = executable & ",0"
shortcut.Save
MsgBox "Desktop shortcut created. Keep this game folder in its current location.", 64, "MobaBot.io"
