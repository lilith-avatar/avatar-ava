--- 用于场景mesh的一些快捷编辑功能
--- @module SceneMeshEditor
--- @copyright Lilith Games, Avatar Team
--- @author Sid Zhang
local SceneMeshEditor = {}

--- 将当前选中节点下的所有特定名称的mesh节点更改其引用
--- @param _NodeName string 需要被替换资源的节点名字
--- @param _MeshResource string FBX资源路径
--- @param _root object 执行该操作的根节点,缺省则为选中的第一个节点
function SceneMeshEditor:ChangeMesh(_NodeName, _MeshResource, _root)
    if not _root then
        _root = Editor.Selections[1]
    end
    if not _root then
        print('[SceneMeshEditor] 没有选中或输入任何节点')
        return
    end
    for _, v in pairs(_root:GetChildren()) do
        if v.Name == _NodeName and v.ClassName == 'MeshObject' then
            v.Mesh = ResourceManager.GetMesh(_MeshResource)
        end
        self:ChangeMesh(_NodeName, _MeshResource, v)
    end
end

return SceneMeshEditor

-- require(Module.Editor_Module.SceneMeshEditorModule):ChangeMesh()
