using Core.Generator;

namespace Projects.Tanks.Models.Chat;

[ClientExport]
internal class ChatMessage
{
    public string Name;

    public string Text;

    public bool SelfMessage;
}