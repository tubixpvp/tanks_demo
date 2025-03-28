using Core.Generator;

namespace Platform.Models.Core.Layer;

[ClientExport(true)]
public enum LayerModelEnum
{
    Content,
    ContentUI,
    Cursor,
    Dialogs,
    Notices,
    System,
    SystemUI
}