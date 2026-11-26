# IWD2EE Spell Indicators

版本：**1.3.2（Mass Spell 预览及 Luck 选择修正）**。

为《冰风谷 2》IWD2EE 添加 BG2 风格的法术范围与轨迹预览。独立 WeiDU Mod，不依赖 Tactics；图形由游戏运行时绘制，不需要 BG2 图片素材。

## 组件

| 组件 | 功能 |
| --- | --- |
| **#0 范围与轨迹预览** | 圆形、陷阱双圈、锥形、直线、墙形和 Spiritual Wrath 四向轨迹；包含 Boulder Roll 的方向选择 |
| **#1 自身中心法术预览（可选）** | 将28项自身中心范围法术改为先预览、再点击自己施放；依赖 #0 |

本 Mod 不增加伤害或扩大实际效果范围。#0 中 Boulder Roll 的选方向操作，以及 #1 的选自身操作和 BCS 兼容调整，见下文。

## 预览类型

| 类型 | 外观与行为 |
| --- | --- |
| 圆形范围 | 绿色四瓣轮廓和呼吸动画；采用纵向75%的地面投影 |
| Skull Trap／Glyph of Warding | 绿色伤害范围、黄色触发范围；形状及呼吸节奏一致，两种半径独立计算 |
| 锥形 | 对称的地面梯形，方向跟随鼠标；采用与圆形一致的投影和呼吸动画 |
| 直线 | **3像素实心绿线、平头末端**；终点跟随鼠标，超过配置的最大长度时截断 |
| 墙形 | 在墙体范围内绘制3像素中心线；Prismatic Wall 按七层墙绘制七条平行线 |
| Spiritual Wrath | 从施法者向鼠标、反向及两个垂直方向绘制四条直线，每条最多300像素 |

直线包括 Lightning Bolt、Lance of Disruption、Smashing Wave 和 Boulder Roll。锥形包括 Cone of Cold、Burning Hands、Shout、Prismatic Spray 等已核对投射物的法术。墙形包括 Wall of Moonlight（含 SPIN216）、Wall of Fire、Trial by Fire、Wall of Force 和 Prismatic Wall。

**Boulder Roll**：点击地面仅确定方向，不再将鼠标位置作为滚动终点。沿该方向查询原生地形阻挡，保留原投射物的移动、伤害、击倒及碰墙处理；预览线只表示初始方向，不表示巨石碰撞宽度或完整滚动距离。

## Widen Spell、装备与取消超魔

- 每帧读取当前有效效果，不沿用上一次施法的超魔状态。
- Widen Spell 遵循原生适用条件，将可扩大的伤害半径或锥宽乘以1.5；不会扩大陷阱黄色触发圈。
- Cancel Metamagic 将扩大标记清零后，预览立即恢复，无需等待效果对象删除。
- 支持原生投射物范围修正，包括 **Staff of Widening（USSTAF54）**。装备扩大与 Widen 按原生规则组合；取消主动超魔仍保留装备提供的扩大。
- #1 的自身范围圈共用这套计算。预览不消耗超魔次数，也不创建实际投射物。

## Mass Spell

组件 #0 根据当前 Mass Spell 标记，将适用法术切换为群体范围预览，包括原本没有范围圈的单体法术。角色目标跟随当前指向的角色，地点目标跟随鼠标；取消超魔后恢复原有预览。支持与 Widen Spell、范围装备组合，按原生顺序先处理 Widen、再处理装备修正。能力索引缺失或为哨兵值时回退到0号能力，Mass＋Luck 已通过游戏测试。

**范围说明**：当前 IWD2EE 文案写20 feet，但原生 Mass 弹道半径是256个世界坐标单位，Fireball 为200，因此预览比火球约大28%。本 Mod 按原生实际范围显示，不修改实际半径。Widen 将256扩大为384，之后再处理适用的装备修正。障碍、视线及目标免疫仍影响实际生效。

## 安装与卸载

1. 退出游戏。
2. 将 `IWD2EE_Spell_Indicators` 文件夹和 `setup-IWD2EE_Spell_Indicators.exe` 放入含 `IWD2.exe` 的游戏目录。
3. 先安装 IWD2EE Core；若使用其他法术修改 Mod，建议先安装它们，再安装本 Mod。
4. 若装过 `I2T_AOE_Sample #0`，先卸载，以免重复挂接。若装过 Prayer 测试组件 `I2SI_SelfAOE_Trial #0`，安装 #1 前也须先卸载它。
5. 运行安装器，安装 #0；按需要另选 #1。

安装器根据当前 SPL 法术头生成预览清单，无需 Python，不修改存档。以后若其他 Mod 改变法术投射物或法术头，请重装本 Mod 更新清单。

卸载时退出游戏，再运行同一个安装器选择卸载。#1 可单独卸载，恢复所改法术的直接施放方式及相关 BCS。

## 可选组件 #1：自身中心法术

先显示固定在施法者脚下的范围圈，再点击自己施放。指向队友或地面时保留施法图标，使用原生禁用颜色；错误目标或取消不会扣法术次数。

覆盖 Prayer、Recitation、Chant、Gedlee’s Electric Loop、Sunfire、Holy Word、Blasphemy、Malavon’s Rage、Wail of the Banshee 等28项法术，完整清单见 [自身中心法术清单](Self-centred-spells.md)。Mirror Image、Stoneskin 等个人 Buff 不转换；Bless 等原本可选施法位置的法术保留原操作。

保留原伤害、效果、施法时间、持续时间、弹道和扩散动画。普通战斗脚本中的已核对施法目标改为 `Myself`，不改条件和区块顺序；剧情／陷阱强制施法保持原样。Tactics 战前、战时协调器的 opcode 施法路径不变。具体调用清单见 [BCS 兼容核对](Self-centred-audit.md)，其中数字是开发时快照，不是所有安装环境的固定数量。

## 范围与限制

- 面向已核对的 Windows 原版 IWD2／IWD2EE 引擎。渲染挂接会检查指令签名；不匹配时跳过挂钩。
- 轮廓表示几何范围，实际效果仍受障碍、视线、阵营和免疫影响。它不预测墙面反弹、后续反射或全部自定义 Lua 投射物变形。
- 锥形投影属于视觉预览，不保证逐像素吻合原生命中边界；建议配合 IWD2EE Patch #25 的施法者中心锥形起点修复使用。
- 直线宽度只是显示线宽，不是伤害走廊宽度。Spiritual Wrath 使用原生四向坐标旋转，不额外套用圆形投影。
- 连锁闪电、Lightning Spiral，以及按视野或整张地图选人的法术不猜测为普通圆形。未知投射物不显示推测形状。
- 仅在选中一名施法者、进入支持的目标选择状态且鼠标位于场景内时显示；取消后消失。普通暂停时呼吸动画仍可播放。
- Widen／取消超魔和装备组合已通过离线回归检查；墙形、Spiritual Wrath 的全部角度及其他 Mod 组合仍需更多游戏实测。

## 目录与来源

资源前缀为 `I2SI`。#0 安装 Lua、生成预览清单并修改 Boulder Roll 的选方向操作；#1 另行修改列出的自身范围法术及必要的普通 BCS 调用。不包含游戏 EXE、BG2 图片、存档、个人日志或开发备份。

- [更新记录](CHANGELOG.md)
- [WeiDU 安装器及第三方说明](THIRD_PARTY.md)
- [WeiDU 许可证](WeiDU-COPYING.txt)

