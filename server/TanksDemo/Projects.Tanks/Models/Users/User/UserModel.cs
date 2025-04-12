using Core.Model;
using Core.Model.Communication;
using Logging;
using OSGI.Services;
using Projects.Tanks.Services.Profile;
using SpacesCommons.ClientControl;

namespace Projects.Tanks.Models.Users.User;

[ModelEntity(typeof(UserModelEntity))]
[Model]
internal class UserModel(long modelId) : ModelBase<IUserModelClient>(modelId)
{
    [InjectService]
    private static ClientSpacesControlService ClientSpacesControlService;

    [InjectService]
    private static UserProfileService UserProfileService;
    
    
    [NetworkMethod]
    private void LoginByName(string name)
    {
        GetLogger().Log(LogLevel.Debug,
            "LoginByName() name=" + name);

        UserModelEntity entity = GetEntity<UserModelEntity>();

        if (name.Length < entity.MinNameLength)
        {
            LoginFailed(LoginErrorsEnum.NameMinLength);
            return;
        }
        if (name.Length > entity.MaxNameLength)
        {
            LoginFailed(LoginErrorsEnum.NameMaxLength);
            return;
        }

        UserProfileService.InitAsTemporaryUser(Context.Session!, name);
        
        ClientSpacesControlService.SwitchSpace(Context.Session!, "Lobby");
    }

    private void LoginFailed(LoginErrorsEnum reason)
    {
        Clients(Context, client => client.LoginFailed(reason));
    }
    private void RegistrationFailed(RegisterErrorsEnum reason)
    {
        Clients(Context, client => client.RegistrFailed(reason));
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