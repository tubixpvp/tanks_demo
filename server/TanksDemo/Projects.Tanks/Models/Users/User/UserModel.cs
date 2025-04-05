using Core.Model;
using Core.Model.Communication;
using Logging;
using OSGI.Services;
using SpacesCommons.ClientControl;

namespace Projects.Tanks.Models.Users.User;

[ModelEntity(typeof(UserModelEntity))]
[Model]
internal class UserModel(long modelId) : ModelBase<IUserModelClient>(modelId)
{
    [InjectService]
    private static ClientSpacesControlService ClientSpacesControlService;
    
    [NetworkMethod]
    private void LoginByName(string name)
    {
        GetLogger().Log(LogLevel.Debug,
            $"LoginByName() name=" + name);
        
        ClientSpacesControlService.SwitchSpace(Context.Session!, "Lobby");
    }

    [NetworkMethod]
    private void LoginByUid(string name, string password)
    {
        
    }

    [NetworkMethod]
    private void RegisterUser(string name, string login, string mail, string password, string repPassword)
    {
        
    }

    [NetworkMethod]
    private void LoginByHash(string userHash)
    {
        
    }
}