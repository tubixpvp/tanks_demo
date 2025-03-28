# General Info
This is "Tanks" - demo game made by AlternativaPlatform in 2008 as demonstration of their technologies.
This project is about compiling the client and reimplementing the server on C#

Current status: abandoned due to existance of [this project](https://github.com/juhe1/alternativa-maven-auto-build).

# How to build
Project is set up to build with VS Code Tasks. You can take a look on it inside `.vscode/tasks.json` if want to build manually.

Make sure you set the directory to your Flash SDK in `.vscode/settings.json`. You can get it [here](https://airsdk.harman.com/download)
Also, [dotnet9](https://dotnet.microsoft.com/en-us/download/dotnet/9.0) is required to build both client and server.

Building:
Windows: Press Ctrl+Shift+B
MacOS: Press Command+Shift+B
-> Select your option: build client or server