namespace Projects.Tanks.Models.Chat;

internal interface IChatModelClient
{
    public void ShowMessages(ChatMessage[] messages);

    public void ShowSystemMessage(ChatMessage message);
}