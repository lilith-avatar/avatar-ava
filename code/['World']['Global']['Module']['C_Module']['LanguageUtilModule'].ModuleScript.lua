---  语言包模块：根据游戏内语言设置返回对应的+
-- @module  LanguageUtil, Client-side
-- @copyright Lilith Games, Avatar Team
-- @author Xiexy, Yuancheng Zhang
---@module LanguageUtil
local LanguageUtil, this = ModuleUtil.New('LanguageUtil', ClientBase)
local lang = Config.GlobalSetting.DefaultLanguage
local defaultLang = Const.LanguageEnum.CHS

--- 设置当前语言
function LanguageUtil.SetLanguage(_lang)
    assert(Const.LanguageEnum[_lang], string.format('[LanguageUtil] %s 语言码不存在，请检查ConstModule', _lang))
    print(string.format('[LanguageUtil] 更改当前语言：%s => %s', lang, _lang))
    lang = _lang
end

--- 根据ID返回当前游戏语言对应的文本信息，如果对应语言为空，默认返回'*'+中文内容
-- @param @number _id LanguagePack.xls中的编号
function LanguageUtil.GetText(_id)
    assert(not string.isnilorempty(_id), '[LanguageUtil] 翻译ID为空，请检查策划表和LanguagePack')
    assert(
        Config.LanguagePack[_id],
        string.format('[LanguageUtil] LanguagePack[%s] 不存在对应翻译ID，请检查策划表和LanguagePack', _id)
    )
    local text = Config.LanguagePack[_id][lang]
    if string.isnilorempty(text) then
        print(string.format('[LanguageUtil] LanguagePack[%s][%s] 不存在对应语言翻译内容，默认使用中文', _id, lang))
        text = '*' .. Config.LanguagePack[_id][defaultLang]
    end
    return text
end

return LanguageUtil
