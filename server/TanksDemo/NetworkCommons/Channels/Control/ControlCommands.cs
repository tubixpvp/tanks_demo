using NetworkCommons.Channels.Control.Commands.Client;

namespace NetworkCommons.Channels.Control;

internal static class ControlCommands
{
    private static readonly Dictionary<byte, Type> IdToCommandType = new()
    {
        [HashRequestCommand.CommandID] = typeof(HashRequestCommand),
        [HashAcceptedCommand.CommandID] = typeof(HashAcceptedCommand),
        [ProduceHashCommand.CommandID] = typeof(ProduceHashCommand),
        [ResourcesLoadedCommand.CommandID] = typeof(ResourcesLoadedCommand),
    };


    public static Type? GetClientCommandType(byte id)
    {
        return IdToCommandType.GetValueOrDefault(id);
    }
}