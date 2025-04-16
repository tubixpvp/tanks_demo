# General Info
This is "Tanks" - demo game made by AlternativaPlatform in 2008 as demonstration of their technologies.
This project is about compiling the client and reimplementing the server on C#.

Everything inside `client/libraries` and `client/models` is a leaked code from AlternativaPlaform.
Therefore, the content is not for commercial use.

# How to run
Project is set up to build with VS Code Tasks. You can take a look on it inside `.vscode/tasks.json` if want to build manually.

You will need VS Code with [AS3&MXML Plugin](https://marketplace.visualstudio.com/items?itemName=bowlerhatllc.vscode-as3mxml).
Also, [dotnet9](https://dotnet.microsoft.com/en-us/download/dotnet/9.0) is required to build both client and server.

Make sure you set the directory to your Flash or AIR SDK. You must use SDK version 32, otherwise you will not be able to run the SWF in Flash Player.


Step 1: build the client

Windows/Linux: Press Ctrl+Shift+B

MacOS: Press Command+Shift+B

-> Select 'Game Client Build'


Step 2: run the game server

Windows: open `start.bat` in `/server/` folder.

MacOS/Linux: go to `/server/` folder in terminal and execute the `start.sh` script.


Step 3: Open `http://localhost:8000/AlternativaLoader.swf?debug=true` in Flash Player app.
Press Ctrl + ` to close the console.