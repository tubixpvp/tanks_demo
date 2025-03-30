# General Info
This is "Tanks" - demo game made by AlternativaPlatform in 2008 as demonstration of their technologies.
This project is about compiling the client and reimplementing the server on C#.

Everything inside `client/libraries` and `client/models` is a leaked code from AlternativaPlaform.
Therefore, the content is not for commercial use.

# How to build
Project is set up to build with VS Code Tasks. You can take a look on it inside `.vscode/tasks.json` if want to build manually.

You will need VS Code with [AS3&MXML Plugin](https://marketplace.visualstudio.com/items?itemName=bowlerhatllc.vscode-as3mxml).
Also, [dotnet9](https://dotnet.microsoft.com/en-us/download/dotnet/9.0) is required to build both client and server.

Make sure you set the directory to your Flash or AIR SDK. You can get it [here](https://airsdk.harman.com/download).

Building:

Windows: Press Ctrl+Shift+B

MacOS: Press Command+Shift+B

-> Select your option: build client or server