# Jump / Wofi

I don't like the name, so you can call this Wofi i guess. (Windows + Rofi)

This is a fork of code that has been modified from https://autohotkey.com/board/topic/65367-jump-minimalist-app-launcher/

The original code was weird and it came with no documentation or no information on how to get it work.

So I spent my afternoon on this, and now I have this

This is basically a rofi with wayyy less features and for windows. It runs using AutoHotKey. If you don't know how that works, don't worry, I'll explain how to configure this even if you have no idea what AutoHotKey is.

To run it, [install AutoHotKey](https://www.autohotkey.com/), and after you do that, you can just double click the script and it will run.

## Configuration

[settings.ini](./settings.ini) is a good enough example of how to configure this, but I'll explain how this works.

Also, since all your shortcuts are in `settings.ini`, you don't need to restart the AHK script to update your shortcuts. Editing the ini file is enough.

The shortcut to open the menu is Super (Win) + Enter. This can be changed in the `main.ahk` script to whatever you want.

```
;===== Main Code =====

#Enter::
    WinGetActiveTitle, prevActive
    Gosub, main
return
```

This is the section that runs the menu.

`#` corresponds to the Super/Win key.

This can be replaced with `^`, `!`, or `+` each corresponding to the Ctrl, Alt and Shift keys respectively.

`Enter` corresponds to the Enter key, and this can be replaced by any letter by replacing it with `a`, `b`, etc. If you want to use other special keys, refer to [this](https://www.autohotkey.com/docs/KeyList.htm)

### Running at startup

If you want to run this at startup, run this script, and open your system tray. From there, you can right click this script and select "Run at Startup". This will add it to your startup programs. Clicking it again when it is added will only update the shortcut. This will be useful if you move the script to a different location.

You can remove it from there by hitting Super (Win) + R and typing in `shell:startup`. Hit enter, and it will open the folder where your startup programs are located. You can delete the `Wofi` shortcut from there, and it will no longer run at startup.

### Settings.ini

```ini
; Uses run.exe from https://github.com/microsoft/WSL/issues/841#issuecomment-270375321
[settings]
workingDir = C:\Users\Soumi

[lookups]
list = run wsl ls -la > test.txt
test = run wsl ls
email = example@gmail.com

[takesArgs]
list = false
test = true
email = copy
```

The `settings` section contains your user settings. Remember to replace your workingDir with whatever location you want. **Note that all commands are executed in `workingDir`**

Here, the `lookups` section contains all your commands. When the menu pops up, you can enter these to:

- Run a command directly
- Edit a command and then run it
- Copy text to clipboard using a shortcut

#### Running a command directly

To run a command directly, just name the command in the `lookups` section, and set its value to the command that you want to run.

Eg.

```
list = run wsl ls -la > test.txt
```

This will run the command `run wsl ls -la > test.txt`

The `run` is just an executable from [here](http://www.straightrunning.com/projectrun/) that runs any wsl command without spawning a terminal window. That can get annoying.

`wsl` is just a shotcut to run any command in Windows Subsystem for Linux

and `ls -la > test.txt` is the actual command I'm running.

Basically, `<shortcut> = <command>` is the syntax, where `<shortcut>` is what you will type in the menu to run `<command>`.

Now, since you want to directly run your command, under the `takesArgs` sections, set its value to false.

Eg.

```
list = false
```

#### Running a command after editing it

To run a command after editing it (you can also pass args this way), just name the command in the `lookups` section, and set its value to the command that you want to run. You can edit this command in the menu at runtime.

Eg.

```
test = run wsl ls
```

This will expand `test` into the command `run wsl ls`, which you can edit and run.

Basically, `<shortcut> = <command>` is the syntax, where `<shortcut>` is what you will type in the menu to expand into `<command>`. Note that you can edit `<command>` later.

Now, since you want to edit your command later, set its value under the `takesArgs` section to true. Any text that is not `false` or `copy` will be treated as truthy.

Eg.

```
test = true
```

#### Copy text to clipboard using a shortcut

To create a shorthand for a piece of text, name the shorcut in the `lookups` section and set its value.

Eg.

```
email = example@gmail.com
```

This will copy `example@gmail.com` onto your clipboard when you type `email` into the menu.

Basically, `<shortcut> = <text>` is the syntax, where `<shortcut>` is what you will type in the menu to copy `<text>`.

Since this isn't a command, set its value under the `takesArgs` section to `copy`.

Eg.

```
email = copy
```

## Contributing

This is a fork of code that is 5 years old, which was copied from some forum post in 2011. Needless to say, this code has been in a couple of hands. If you use AHK a lot, and you're good at writing scripts for it, your work would be appreciated.

The code is messy, and I don't know what half of it does, and there's barely any documentation for it. Sorting through this mess could literally produce a Rofi for Windows. It has potential.
