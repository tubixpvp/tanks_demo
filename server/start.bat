cd .\TanksDemo\TanksDemo\
dotnet run -fileServPort 8000 -resourcesPath .\..\..\..\file_server_data\ -clientDir .\..\..\..\client\ -prod false -models .\..\..\..\cache\models.json -resCacheDir .\..\..\..\cache\resources_cache
pause