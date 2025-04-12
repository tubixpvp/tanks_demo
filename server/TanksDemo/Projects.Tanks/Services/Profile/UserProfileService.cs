using Core.GameObjects;
using Network.Channels;
using Network.Session;
using NetworkCommons.Channels.Spaces;
using OSGI.Services;
using Projects.Tanks.Models.Users.Profile;

namespace Projects.Tanks.Services.Profile;

[Service]
internal class UserProfileService
{
    [InjectService]
    private static SpaceChannelHandler SpaceChannelHandler;


    private const string UserProfileObjectKey = "UserProfileObject";
    private const string UserTemporaryProfileKey = "UserTemporaryProfile";

    
    public int GetUserExperience(NetworkSession session)
    {
        return GetUserProfile(session).Experience;
    }
    public string GetUserName(NetworkSession session)
    {
        return GetUserProfile(session).UserName;
    }

    public bool IsRegistered(NetworkSession session)
    {
        return GetControlSession(session).GetAttribute<GameObject>(UserProfileObjectKey) != null;
    }

    public void InitAsTemporaryUser(NetworkSession session, string userName)
    {
        session = GetControlSession(session);
        
        session.SetAttribute(UserTemporaryProfileKey, new UserProfileEntity()
        {
            UserName = userName,
            Experience = 0
        });
    }

    private UserProfileEntity GetUserProfile(NetworkSession session)
    {
        session = GetControlSession(session);
        
        GameObject? userProfileObject = session.GetAttribute<GameObject>(UserProfileObjectKey);

        if (userProfileObject == null)
        {
            return session.GetAttribute<UserProfileEntity>(UserTemporaryProfileKey)!;
        }

        return userProfileObject.GetModelEntity<UserProfileEntity>();
    }

    private NetworkSession GetControlSession(NetworkSession session)
    {
        if (session.ChannelType == ProtocolChannelType.Space)
        {
            return SpaceChannelHandler.GetControlSessionBySpace(session);
        }
        return session;
    }
    
}