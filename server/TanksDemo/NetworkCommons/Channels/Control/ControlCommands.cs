using NetworkCommons.Channels.Control.Commands.Client;

namespace NetworkCommons.Channels.Control;

internal static class ControlCommands
{
    private static readonly Dictionary<byte, Type> IdToCommandType = new()
    {
        [HashRequestCommand.CommandId] = typeof(HashRequestCommand)
    };


    public static Type? GetCommandType(byte id)
    {
        return IdToCommandType.GetValueOrDefault(id);
    }
}