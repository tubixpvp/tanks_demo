using Core.Model;
using Core.Model.Communication;
using Network.Session;
using OSGI.Services;
using Projects.Tanks.Services.Profile;

namespace Projects.Tanks.Models.Chat;

[ModelEntity(typeof(ChatModelEntity))]
[Model]
internal class ChatModel(long modelId) : ModelBase<IChatModelClient>(modelId)
{
    [InjectService]
    private static UserProfileService UserProfileService;


    [NetworkMethod]
    private void SendMessage(string text)
    {
        NetworkSession session = Context.Session!;
        
        string userName = UserProfileService.GetUserName(session);
        
        Clients(Context.Object, Context.Space.GetDeployedSessions(Context.Object).Except([session]),
            client => client.ShowMessages([new ChatMessage()
            {
                Name = userName,
                Text = text,
                SelfMessage = false
            }]));
        Clients(Context.Object, [session],
            client => client.ShowMessages([new ChatMessage()
            {
                Name = userName,
                Text = text,
                SelfMessage = true
            }]));
    }
    
}