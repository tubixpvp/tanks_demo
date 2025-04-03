using System.Reflection;
using System.Text;
using Core.GameObjects;
using Core.Generator;

namespace ClientGenerator.Flash;

internal class FlashCodeGenerator(string packageName, string[]? defaultImports = null)
{
    private static readonly Dictionary<Type, (string? package, string flashImportName, string flashDeclarationName)> PredefinedTypes =
        new ()
        {
            [typeof(int)] = (null, "Int", "int"),
            [typeof(float)] = ("alternativa.protocol.type", "Float", "Number"),
            [typeof(double)] = (null, "Number", "Number"),
            [typeof(string)] = (null, "String", "String"),
            [typeof(bool)] = (null, "Boolean", "Boolean"),
            [typeof(short)] = ("alternativa.protocol.type", "Short", "int"),
            [typeof(byte)] = ("alternativa.protocol.type", "Byte", "int"),
            [typeof(long)] = ("alternativa.types", "Long", "Long"),
            [typeof(uint)] = ("alternativa.protocol.types", "UInt", "int"),
            [typeof(ushort)] = ("alternativa.protocol.types", "UShort", "int"),
            [typeof(GameObject)] = ("alternativa.object", "ClientObject", "ClientObject")
        };
    
    public static string GetFlashDeclarationTypeString(Type type)
    {
        if (PredefinedTypes.TryGetValue(type, out var data))
        {
            return data.flashDeclarationName;
        }

        if (type.IsArray)
        {
            //return $"Vector.<{GetFlashDeclarationTypeString(type.GetElementType()!)}>";
            return "Array";
        }
        return type.Name;
    }
    
    private readonly StringBuilder _builder = new();

    private readonly List<Type> _imports = new();

    private int _tabsNum = 0;

    private string GetTabsSpace()
    {
        return new string('\t', _tabsNum);
    }
    
    public void AddLine(string text)
    {
        _builder.Append(GetTabsSpace() + text + '\n');
    }

    public void AddEmptyLine()
    {
        _builder.Append('\n');
    }

    public void OpenCurvedBrackets()
    {
        AddLine("{");
        _tabsNum++;
    }

    public void CloseCurvedBrackets()
    {
        _tabsNum--;
        AddLine("}");
    }

    public string GetResult()
    {
        string[] code = _builder.ToString().Split('\n');
        
        _builder.Clear();

        AddLine("package " + packageName);
        OpenCurvedBrackets();

        if (defaultImports != null)
        {
            foreach (string importStr in defaultImports)
            {
                AddLine($"import {importStr};");
            }
        }
        
        AddImportsDeclarations();

        _builder.AppendLine();

        string tabs = GetTabsSpace();
        foreach (string line in code)
        {
            _builder.Append(tabs + line + '\n');
        }
        
        CloseCurvedBrackets();

        _builder.Append("//Generated at UTC: " + DateTime.UtcNow);
        
        return _builder.ToString();
    }

    private void AddImportsDeclarations()
    {
        foreach (Type type in _imports)
        {
            if (PredefinedTypes.TryGetValue(type, out var typeData))
            {
                if (typeData.package != null)
                {
                    AddLine($"import {typeData.package}.{typeData.flashImportName};");
                }
                continue;
            }
            ClientExportAttribute? exportAttribute =
                type.GetCustomAttribute<ClientExportAttribute>();
            if (exportAttribute != null)
            {
                if (exportAttribute.CustomPackage != null)
                {
                    AddLine($"import {exportAttribute.CustomPackage}.{type.Name};");
                    continue;
                }

                string package = type.Namespace!.ToLower();
                
                AddLine($"import {package}.{type.Name};");
                continue;
            }

            throw new Exception("Flash type not found: " + type.Namespace + "." + type.Name);
        }
    }

    public void AddImport(Type type)
    {
        if (!_imports.Contains(type))
        {
            _imports.Add(type);
        }
    }
}