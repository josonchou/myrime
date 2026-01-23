# Oh-My-Rime 开发指南

本项目是 Rime 输入法配置模板，包含多个输入方案（薄荷拼音、小鹤双拼、地球拼音、五笔等）和扩展功能（Lua 脚本）。

## 项目结构

```
Rime/
├── *.yaml                    # 输入方案配置文件（rime_mint.schema.yaml 等）
├── dicts/                    # 词库目录（.dict.yaml 文件）
├── lua/                      # Lua 扩展脚本目录
│   ├── mint_calculator_translator.lua  # 计算器功能
│   ├── shijian.lua           # 日期时间功能
│   ├── chineseLunarCalendar_translator.lua  # 农历功能
│   ├── corrector_filter.lua  # 纠错过滤器
│   └── ...                   # 其他功能脚本
├── opencc/                   # OpenCC 转换配置（ emoji.json、fly_Chaifen.json）
├── plum/                     # Plum 配置（用于在线部署）
├── build/                    # Rime 编译后的二进制文件（自动生成）
├── tools/                    # 工具脚本
└── rime.lua                  # Lua 入口文件
```

## 构建与测试

### 部署测试

Rime 输入法配置不依赖传统构建流程，而是通过"部署"来编译和验证：

```bash
# 重新部署 Rime（验证配置正确性）
# - macOS: 鼠须管 -> 重新部署
# - Windows: 小狼毫 -> 重新部署
# - Linux: 根据不同前端，命令不同

# 查看 Rime 编译日志（macOS）
log show --predicate 'eventMessage CONTAINS "Squirrel"' --last 5m

# 查看编译后的字典文件
ls -lah build/*.table.bin build/*.prism.bin
```

### 在线部署测试（使用 Docker）

项目提供 CNB 在线部署配置：

```bash
# 使用 Docker 验证 schema 编译
docker run -it --rm -v $(pwd):/rime cnbcool/mintimate/rime/deploy-schema
```

### 语法检查

```bash
# 验证 YAML 语法
python3 -c "import yaml; yaml.safe_load(open('rime_mint.schema.yaml'))"

# 检查 Lua 语法
lua -c lua/mint_calculator_translator.lua

# 验证词库文件
lua -e "dofile('rime_mint.dict.yaml')" 2>&1 | head -20
```

## 代码风格指南

### YAML 配置文件

**命名规范**：
- Schema 文件：`{方案名}.schema.yaml`（如 `rime_mint.schema.yaml`）
- 字典文件：`{词库名}.dict.yaml`（如 `rime_mint.dict.yaml`）
- 自定义文件：`{原始名}.custom.yaml`（如 `default.custom.yaml`）
- 配置文件：`{用途}.yaml`（如 `squirrel.yaml`、`weasel.yaml`）

**文件头格式**：
```yaml
# Rime schema/dictionary/configuration
# encoding: utf-8

schema/dictionary/config:
  schema_id: rime_mint
  name: 薄荷拼音-全拼输入
  version: "24.11.11"
  author:
    - mintimate <@Mintimate|https://www.mintimate.cn>
  description: |
    详细描述...
```

**缩进与格式**：
- 使用 2 空格缩进
- 键名使用下划线分隔：`ascii_mode`、`page_size`
- 布尔值使用 `true`/`false`（非 yes/no）
- 字符串值使用引号包裹，尤其是包含空格或特殊字符的值
- 注释使用 `#`，放在行上方或行尾

**Engine 配置规范**：
```yaml
engine:
  processors:
    - lua_processor@*ascii_on_esc
    - speller
  segmentors:
    - matcher
    - abc_segmentor
  translators:
    - lua_translator@*shijian
  filters:
    - lua_filter@*corrector_filter
```

### Lua 脚本规范

**文件头注释**：
```lua
-- author: https://github.com/username
-- description: 功能说明
-- modified: Mintimate
```

**命名规范**：
- 函数名使用小写下划线：`calculate_sum()`
- 模块名使用驼峰：`CalculatorTranslator`
- 变量名使用小写下划线：`local result_value`

**代码风格**：
```lua
-- 缩进：2 空格
local function calculate(a, b)
  if a and b then
    return a + b
  else
    return 0
  end
end

-- 字符串使用双引号
local name = "calculator"

-- 注释风格
-- 单行注释使用 --
--[[ 多行注释 ]]
```

### 词库文件规范

**格式**：
```yaml
# Rime dictionary
# encoding: utf-8
---
name: custom_simple
version: "2023.11.30"
sort: by_weight
...

# 词条格式：词语 编码 权重
哈哈	ha ha	99
Mintimate	mintimate	1
```

**注意事项**：
- 词条使用 Tab 分隔（不是空格）
- 权重数值越大，词频越高
- 自定义词库放在 `custom_simple.dict.yaml`

## 常用命令

### 重新部署

```bash
# 触发 Rime 重新编译配置
# 方法1：在输入法中手动触发（推荐）
# 方法2：删除编译缓存强制重新编译
rm -rf build/
```

### 调试输出

```bash
# 启用 Lua 调试日志
# 在 lua/log.lua 中配置
tail -f /tmp/rime.*.log

# macOS 日志
log show --predicate 'eventMessage CONTAINS "rime"' --last 1m
```

### 词库管理

```bash
# 检查词库语法
python3 -c "import yaml; yaml.safe_load(open('dicts/rime_mint.base.dict.yaml'))"

# 统计词条数量
grep -c "^[^#]" dicts/rime_mint.base.dict.yaml
```

## 开发工作流

1. **修改配置文件**（.yaml 或 .lua）
2. **语法检查**（验证 YAML/Lua 语法）
3. **重新部署 Rime**（输入法重新部署）
4. **测试功能**（在实际使用中验证）
5. **提交变更**（git commit）

## 参考资源

- [Rime 官方文档](https://rime.im/doc/)
- [Rime Schema 规范](https://github.com/rime/home/wiki/RimeWithSchemata)
- [librime-lua Wiki](https://github.com/hchunhui/librime-lua/wiki/Scripting)
- [薄荷文档](https://www.mintimate.cc/zh/guide/)
