[h1]What is [i]sm.interop[/i]?[/h1]
At first glance, sm.interop does not seem to add much to the game. But appearances are deceptive. sm.interop is a dependency for other mods, and it allows those mods to make complex scripted parts and custom tools, that work together well with other mods that use sm.interop.

The mod consists of two parts: a workshop part and a game file part. The game file part needs to be installed manually.

Game file mods that change tools or scripts may not be compatible with sm.interop. However, most of those mods can be re-written to work together with sm.interop. If you are a developer of a game file mod and need help with rewriting your mod to work with sm.interop, do not hesitate to contact Xesau#1681 on Discord.

[h1]Features list[/h1]
[b]Workshop part[/b]
[list]
  [*] Custom connection types
  [*] Event system
  [*] Mod startup scripts
  [*] Permission API
  [*] Scheduling API
[/list]
[b]Game file part[/b]
[list]
  [*] Custom chat commands
  [*] Custom tools
  [*] Access to game events, such as scrapmechanic:playerCollision
[/list]

[h1]Installing [i]sm.interop[/i] as user[/h1]
To install the workshop part, you only have to click the 'Subscribe' button and restart your game.

Installing the game file part is a bit more complicated. Go to your game library and right click on Scrap Mechanic. Select Manage -> Browse local files. This opens the [u]steamapps\common\Scrap Mechanic[/u] folder. Navigate back to the steamapps folder, then open [u]workshop\content\387990\2123222134[/u]. Make sure your game is closed, and then double-click on Install.bat. Now open Scrap Mechanic again.
Or watch the video tutorial: https://youtu.be/LxCweEwQSlE

If the installer asks for the path to the Scrap Mechanic folder, you can find that by going to your game library and right-clicking on Scrap Mechanic. Then select Manage -> Browse local files, and copy the path fo the window that opens and paste it in the installer window.

If Install does not work, please run the [u]Install debug[/u] file and send the install.log file to Xesau#1681 on Discord.

[h1]Updating [i]sm.interop[/i][/h1]
To update the mod, you follow the same steps as when installing. But now, you click Update.bat. If that does not work, try just clicking Install.bat again.

[h1]Using [i]sm.interop[/i] as mod developer[/h1]
[olist]
  [*] Read through the [url=https://github.com/smtheguild/sm.interop-example]example project[/url] from GitHub.
  [*] Read the [url=https://docs.google.com/document/d/1gK8PswBa0W6QCNH70BiBQT3ThaEbqlbVslszn8Dex-Y/edit]API documentation[/url] (still Work In Progress)
[/olist]

[h1]Who is The Guild?[/h1]
The Guild is a cooperation between a number of modders. Currently, The Guild consists of: Alstrak, BlueFlame, Brent Batch, DasEtwas, DJ, Fusspawn, Mini, MJM, Sheggy, shinevision, ShrooToo, TechnologicNick, Thumbpick, wingcomstriker405 and Xesau.
