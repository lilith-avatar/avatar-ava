--- @module NpcBehavior NPC行为树
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local NpcBehavior = ModuleUtil.New('NpcBehavior', ServerBase)

---所有游戏模式的NPC行为树
local BTJson = {}

---占点模式的行为树
BTJson[Const.GameModeEnum.OccupyMode] =
    [[
{
  "version": "0.3.0",
  "scope": "tree",
  "id": "200f98af-509f-43e8-a587-6d47f0897975",
  "title": "CommonNpc",
  "description": "通用的机器人行为树",
  "root": "36685ffb-3d2a-4501-8029-184b5ce5ccbc",
  "properties": {},
  "nodes": {
    "c25a3300-68f2-4be5-9065-266ab4550557": {
      "id": "c25a3300-68f2-4be5-9065-266ab4550557",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 684,
        "y": -60
      },
      "children": [
        "29befb59-122c-4f9b-8cfb-baed682e06e5",
        "d1f154b2-e09f-4213-acc8-e468c6dc2ec8"
      ]
    },
    "dfa6a411-4afd-4d3d-81a2-ea10048523c2": {
      "id": "dfa6a411-4afd-4d3d-81a2-ea10048523c2",
      "name": "Priority",
      "category": "composite",
      "title": "Priority",
      "description": "",
      "properties": {},
      "display": {
        "x": 84,
        "y": 312
      },
      "children": [
        "7bfb4f5d-cb92-4495-8b98-74d3dfd34f33",
        "4e57bc5a-7b7a-4a01-8a8d-f5783638a5bb"
      ]
    },
    "df8e270c-0e95-4964-a919-3e239a5072ba": {
      "id": "df8e270c-0e95-4964-a919-3e239a5072ba",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 684,
        "y": 72
      },
      "children": [
        "5707a78e-b2b5-4af6-9a0c-277a36717664",
        "cfe9a951-5c2b-4145-910a-84908d785d1c"
      ]
    },
    "8ea125fd-dc21-45e2-8381-8f01a23f3df6": {
      "id": "8ea125fd-dc21-45e2-8381-8f01a23f3df6",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 684,
        "y": 204
      },
      "children": [
        "757841ea-d804-4fb8-8073-9d529bb12d47",
        "b95cac9c-77e0-4e7c-a226-b237fad8f36e"
      ]
    },
    "29befb59-122c-4f9b-8cfb-baed682e06e5": {
      "id": "29befb59-122c-4f9b-8cfb-baed682e06e5",
      "name": "DisCheck",
      "category": "condition",
      "title": "DisCheck",
      "description": "",
      "properties": {
        "distance": 10,
        "hasView": 1
      },
      "display": {
        "x": 864,
        "y": -96
      }
    },
    "5707a78e-b2b5-4af6-9a0c-277a36717664": {
      "id": "5707a78e-b2b5-4af6-9a0c-277a36717664",
      "name": "DisCheck",
      "category": "condition",
      "title": "DisCheck",
      "description": "",
      "properties": {
        "distance": 20,
        "hasView": 1
      },
      "display": {
        "x": 864,
        "y": 48
      }
    },
    "d1f154b2-e09f-4213-acc8-e468c6dc2ec8": {
      "id": "d1f154b2-e09f-4213-acc8-e468c6dc2ec8",
      "name": "AttackAction",
      "category": "action",
      "title": "AttackAction",
      "description": "",
      "properties": {},
      "display": {
        "x": 864,
        "y": -12
      }
    },
    "36685ffb-3d2a-4501-8029-184b5ce5ccbc": {
      "id": "36685ffb-3d2a-4501-8029-184b5ce5ccbc",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": -360,
        "y": 264
      },
      "children": [
        "127073e3-b9c7-4633-81fc-2e8a1e6cd242",
        "dfa6a411-4afd-4d3d-81a2-ea10048523c2"
      ]
    },
    "133dfd7e-03b3-419d-a597-34407915cd7a": {
      "id": "133dfd7e-03b3-419d-a597-34407915cd7a",
      "name": "HpCheck",
      "category": "condition",
      "title": "HpCheck",
      "description": "",
      "properties": {
        "hpRate": 0
      },
      "display": {
        "x": -24,
        "y": 132
      }
    },
    "b09f1a4f-a5c8-448d-824d-f66b9e60baf5": {
      "id": "b09f1a4f-a5c8-448d-824d-f66b9e60baf5",
      "name": "HpCheck",
      "category": "condition",
      "title": "HpCheck",
      "description": "",
      "properties": {
        "hpRate": 50
      },
      "display": {
        "x": 408,
        "y": -108
      }
    },
    "4e57bc5a-7b7a-4a01-8a8d-f5783638a5bb": {
      "id": "4e57bc5a-7b7a-4a01-8a8d-f5783638a5bb",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "P2阶段,防守欲望强",
      "properties": {},
      "display": {
        "x": 192,
        "y": 600
      },
      "children": [
        "755316eb-dab9-4dd3-a154-065013094c89",
        "7a049ff8-8a1d-4d46-84ea-28b600e6c56a"
      ]
    },
    "755316eb-dab9-4dd3-a154-065013094c89": {
      "id": "755316eb-dab9-4dd3-a154-065013094c89",
      "name": "HpCheck",
      "category": "condition",
      "title": "HpCheck",
      "description": "",
      "properties": {
        "hpRate": 0
      },
      "display": {
        "x": 432,
        "y": 492
      }
    },
    "e8481cf2-ef31-4edd-a1be-fd39e9f2b4f2": {
      "id": "e8481cf2-ef31-4edd-a1be-fd39e9f2b4f2",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 672,
        "y": 576
      },
      "children": [
        "8343b15e-7b78-4703-8f79-9c57e597c9d1",
        "7f6eddc0-109d-4366-b149-168adc554105"
      ]
    },
    "230de690-d0b2-4f24-a15f-8488d121c147": {
      "id": "230de690-d0b2-4f24-a15f-8488d121c147",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 660,
        "y": 720
      },
      "children": [
        "0e5b423a-d44d-4f43-8cdb-b6e0ede17c96",
        "1613cee9-d58f-4c24-88a0-7d4e226e04c6"
      ]
    },
    "dcfa057a-0535-401a-98bb-5604e551118d": {
      "id": "dcfa057a-0535-401a-98bb-5604e551118d",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 672,
        "y": 840
      },
      "children": [
        "64950c7c-1253-4fde-9bd1-974711483010",
        "48a6a8cd-ca52-46b0-a06d-d571122c8fd4"
      ]
    },
    "8343b15e-7b78-4703-8f79-9c57e597c9d1": {
      "id": "8343b15e-7b78-4703-8f79-9c57e597c9d1",
      "name": "DisCheck",
      "category": "condition",
      "title": "DisCheck",
      "description": "",
      "properties": {
        "distance": 10,
        "hasView": 1
      },
      "display": {
        "x": 864,
        "y": 540
      }
    },
    "0e5b423a-d44d-4f43-8cdb-b6e0ede17c96": {
      "id": "0e5b423a-d44d-4f43-8cdb-b6e0ede17c96",
      "name": "DisCheck",
      "category": "condition",
      "title": "DisCheck",
      "description": "",
      "properties": {
        "distance": 20,
        "hasView": 1
      },
      "display": {
        "x": 864,
        "y": 660
      }
    },
    "7f6eddc0-109d-4366-b149-168adc554105": {
      "id": "7f6eddc0-109d-4366-b149-168adc554105",
      "name": "AttackAction",
      "category": "action",
      "title": "AttackAction",
      "description": "",
      "properties": {},
      "display": {
        "x": 864,
        "y": 600
      }
    },
    "2018be26-43ec-4868-8339-70b612a6176b": {
      "id": "2018be26-43ec-4868-8339-70b612a6176b",
      "name": "Priority",
      "category": "composite",
      "title": "Priority",
      "description": "",
      "properties": {},
      "display": {
        "x": 360,
        "y": 108
      },
      "children": [
        "c25a3300-68f2-4be5-9065-266ab4550557",
        "df8e270c-0e95-4964-a919-3e239a5072ba",
        "8ea125fd-dc21-45e2-8381-8f01a23f3df6",
        "d9d37cc0-b9d2-4819-8445-d592671cc197",
        "faba6ee9-f835-4a4b-9837-8ee1d88bec17"
      ]
    },
    "7bfb4f5d-cb92-4495-8b98-74d3dfd34f33": {
      "id": "7bfb4f5d-cb92-4495-8b98-74d3dfd34f33",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 216,
        "y": -24
      },
      "children": [
        "b09f1a4f-a5c8-448d-824d-f66b9e60baf5",
        "2018be26-43ec-4868-8339-70b612a6176b"
      ]
    },
    "7a049ff8-8a1d-4d46-84ea-28b600e6c56a": {
      "id": "7a049ff8-8a1d-4d46-84ea-28b600e6c56a",
      "name": "Priority",
      "category": "composite",
      "title": "Priority",
      "description": "",
      "properties": {},
      "display": {
        "x": 348,
        "y": 696
      },
      "children": [
        "e8481cf2-ef31-4edd-a1be-fd39e9f2b4f2",
        "230de690-d0b2-4f24-a15f-8488d121c147",
        "dcfa057a-0535-401a-98bb-5604e551118d",
        "10c7fe01-3885-453c-8ab3-45e5243769cd"
      ]
    },
    "cfe9a951-5c2b-4145-910a-84908d785d1c": {
      "id": "cfe9a951-5c2b-4145-910a-84908d785d1c",
      "name": "MoveAction",
      "category": "action",
      "title": "PursueAction",
      "description": "感知有敌人在视野范围内,进行追击",
      "properties": {},
      "display": {
        "x": 864,
        "y": 108
      }
    },
    "1613cee9-d58f-4c24-88a0-7d4e226e04c6": {
      "id": "1613cee9-d58f-4c24-88a0-7d4e226e04c6",
      "name": "MoveAction",
      "category": "action",
      "title": "Flee",
      "description": "感知到视野范围内有敌人后进行逃跑,目标是最近的掩体路点",
      "properties": {},
      "display": {
        "x": 864,
        "y": 732
      }
    },
    "757841ea-d804-4fb8-8073-9d529bb12d47": {
      "id": "757841ea-d804-4fb8-8073-9d529bb12d47",
      "name": "GetHoldPoint",
      "category": "condition",
      "title": "GetHoldPoint",
      "description": "获取非己方占领的据点,获取不到返回失败,否则更新目标的m_targetPoint并返回成功",
      "properties": {},
      "display": {
        "x": 864,
        "y": 180
      }
    },
    "b95cac9c-77e0-4e7c-a226-b237fad8f36e": {
      "id": "b95cac9c-77e0-4e7c-a226-b237fad8f36e",
      "name": "MoveAction",
      "category": "action",
      "title": "MoveToTargetPoint",
      "description": "",
      "properties": {},
      "display": {
        "x": 864,
        "y": 252
      }
    },
    "d9d37cc0-b9d2-4819-8445-d592671cc197": {
      "id": "d9d37cc0-b9d2-4819-8445-d592671cc197",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 684,
        "y": 360
      },
      "children": [
        "94e11589-3bf7-474a-9b96-72d3fb978ef8",
        "ba4b3c63-b0dc-45df-9c3d-4ecb84c112dd"
      ]
    },
    "94e11589-3bf7-474a-9b96-72d3fb978ef8": {
      "id": "94e11589-3bf7-474a-9b96-72d3fb978ef8",
      "name": "DisCheck",
      "category": "condition",
      "title": "DisCheck",
      "description": "检查地图范围内一个敌方",
      "properties": {
        "distance": 2000
      },
      "display": {
        "x": 864,
        "y": 324
      }
    },
    "ba4b3c63-b0dc-45df-9c3d-4ecb84c112dd": {
      "id": "ba4b3c63-b0dc-45df-9c3d-4ecb84c112dd",
      "name": "MoveAction",
      "category": "action",
      "title": "PursueAction",
      "description": "感知有敌人在视野范围内,进行追击",
      "properties": {},
      "display": {
        "x": 864,
        "y": 396
      }
    },
    "faba6ee9-f835-4a4b-9837-8ee1d88bec17": {
      "id": "faba6ee9-f835-4a4b-9837-8ee1d88bec17",
      "name": "Succeeder",
      "category": "action",
      "title": "Succeeder",
      "description": "",
      "properties": {},
      "display": {
        "x": 744,
        "y": 468
      }
    },
    "64950c7c-1253-4fde-9bd1-974711483010": {
      "id": "64950c7c-1253-4fde-9bd1-974711483010",
      "name": "GetHoldPoint",
      "category": "condition",
      "title": "GetHoldPoint",
      "description": "获取非己方占领的据点,获取不到返回失败,否则更新目标的m_targetPoint并返回成功",
      "properties": {},
      "display": {
        "x": 864,
        "y": 816
      }
    },
    "48a6a8cd-ca52-46b0-a06d-d571122c8fd4": {
      "id": "48a6a8cd-ca52-46b0-a06d-d571122c8fd4",
      "name": "MoveAction",
      "category": "action",
      "title": "MoveToTargetPoint",
      "description": "",
      "properties": {},
      "display": {
        "x": 864,
        "y": 900
      }
    },
    "10c7fe01-3885-453c-8ab3-45e5243769cd": {
      "id": "10c7fe01-3885-453c-8ab3-45e5243769cd",
      "name": "Succeeder",
      "category": "action",
      "title": "Succeeder",
      "description": "",
      "properties": {},
      "display": {
        "x": 732,
        "y": 972
      }
    },
    "f6ba7449-d37e-4085-bbd8-6069e64b68ae": {
      "id": "f6ba7449-d37e-4085-bbd8-6069e64b68ae",
      "name": "MoveAction",
      "category": "action",
      "title": "StopMove",
      "description": "死亡状态下停止移动",
      "properties": {},
      "display": {
        "x": -24,
        "y": 216
      }
    },
    "127073e3-b9c7-4633-81fc-2e8a1e6cd242": {
      "id": "127073e3-b9c7-4633-81fc-2e8a1e6cd242",
      "name": "Priority",
      "category": "composite",
      "title": "Priority",
      "description": "",
      "properties": {},
      "display": {
        "x": -216,
        "y": 180
      },
      "children": [
        "133dfd7e-03b3-419d-a597-34407915cd7a",
        "f6ba7449-d37e-4085-bbd8-6069e64b68ae"
      ]
    }
  },
  "display": {
    "camera_x": 702,
    "camera_y": 274.5,
    "camera_z": 0.75,
    "x": -480,
    "y": 264
  },
  "custom_nodes": [
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "DisCheck",
      "category": "condition",
      "title": null,
      "description": null,
      "properties": {},
      "parent": null
    },
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "AttackAction",
      "category": "action",
      "title": null,
      "description": null,
      "properties": {},
      "parent": null
    },
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "HpCheck",
      "category": "condition",
      "title": null,
      "description": null,
      "properties": {},
      "parent": null
    },
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "MoveAction",
      "category": "action",
      "title": null,
      "description": null,
      "properties": {},
      "parent": null
    },
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "GetHoldPoint",
      "category": "condition",
      "title": null,
      "description": "获取非己方占领的据点,获取不到返回失败,否则更新目标的m_targetPoint并返回成功",
      "properties": {},
      "parent": null
    }
  ],
  "custom_folders": []
}
]]

---死斗模式的行为树
BTJson[Const.GameModeEnum.DeathmatchMode] =
    [[
{
  "version": "0.3.0",
  "scope": "tree",
  "id": "ef08dbb4-5291-4f81-8c97-329c7e425bf7",
  "title": "DeathmatchNPC",
  "description": "死斗模式NPC行为树",
  "root": "c940b648-3787-4b00-a8be-f45b881b6032",
  "properties": {},
  "nodes": {
    "8f1a3aee-87bf-40ad-b143-7dc9e7d5ac77": {
      "id": "8f1a3aee-87bf-40ad-b143-7dc9e7d5ac77",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 1176,
        "y": -252
      },
      "children": [
        "0510af90-b630-4336-b6b8-5db69f700baf",
        "08dbdad4-e4e8-4de1-8a20-296e6127acb2"
      ]
    },
    "81444fad-abaa-4a9a-af73-ef95bb1397c2": {
      "id": "81444fad-abaa-4a9a-af73-ef95bb1397c2",
      "name": "Priority",
      "category": "composite",
      "title": "Priority",
      "description": "",
      "properties": {},
      "display": {
        "x": 576,
        "y": 48
      },
      "children": [
        "0b6e8a7d-1265-4cfa-8898-b4fd74a810f2",
        "4e6142f3-6cb6-4cba-8f36-b0c5c423c176"
      ]
    },
    "08dbdad4-e4e8-4de1-8a20-296e6127acb2": {
      "id": "08dbdad4-e4e8-4de1-8a20-296e6127acb2",
      "name": "AttackAction",
      "category": "action",
      "title": "AttackAction",
      "description": "",
      "properties": {},
      "display": {
        "x": 1356,
        "y": -204
      }
    },
    "c940b648-3787-4b00-a8be-f45b881b6032": {
      "id": "c940b648-3787-4b00-a8be-f45b881b6032",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 132,
        "y": 0
      },
      "children": [
        "e9ee3d82-6e5a-4e04-a673-dacaf7c8f57e",
        "81444fad-abaa-4a9a-af73-ef95bb1397c2"
      ]
    },
    "91e8882b-1362-40c9-887c-5df5468cd3e1": {
      "id": "91e8882b-1362-40c9-887c-5df5468cd3e1",
      "name": "HpCheck",
      "category": "condition",
      "title": "HpCheck",
      "description": "",
      "properties": {
        "hpRate": 0
      },
      "display": {
        "x": 468,
        "y": -132
      }
    },
    "361bb8da-9940-4be1-97ff-06802a2ab8ca": {
      "id": "361bb8da-9940-4be1-97ff-06802a2ab8ca",
      "name": "HpCheck",
      "category": "condition",
      "title": "HpCheck",
      "description": "",
      "properties": {
        "hpRate": 30
      },
      "display": {
        "x": 900,
        "y": -300
      }
    },
    "4e6142f3-6cb6-4cba-8f36-b0c5c423c176": {
      "id": "4e6142f3-6cb6-4cba-8f36-b0c5c423c176",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "P2阶段,防守欲望强",
      "properties": {},
      "display": {
        "x": 684,
        "y": 336
      },
      "children": [
        "4685c38b-f5d6-43ef-b895-1f6b647ed6b5",
        "2502ba27-abf8-416f-81b0-8265149ace23"
      ]
    },
    "4685c38b-f5d6-43ef-b895-1f6b647ed6b5": {
      "id": "4685c38b-f5d6-43ef-b895-1f6b647ed6b5",
      "name": "HpCheck",
      "category": "condition",
      "title": "HpCheck",
      "description": "",
      "properties": {
        "hpRate": 0
      },
      "display": {
        "x": 924,
        "y": 228
      }
    },
    "2c6fd581-90e1-4955-86b3-1e87cc08af3e": {
      "id": "2c6fd581-90e1-4955-86b3-1e87cc08af3e",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 1152,
        "y": 312
      },
      "children": [
        "377b6c68-7b27-4caf-8ffd-cdfd2eb20657",
        "11a32c7e-0ea6-4297-87e3-1869822708b9"
      ]
    },
    "42db8fb9-58a6-479d-aeae-cab4053f2936": {
      "id": "42db8fb9-58a6-479d-aeae-cab4053f2936",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 1152,
        "y": 456
      },
      "children": [
        "6bea6710-0dc5-4697-9c78-fd0f105be718",
        "d2b552c9-38f3-4ffb-8d3e-c291f33137c6"
      ]
    },
    "11a32c7e-0ea6-4297-87e3-1869822708b9": {
      "id": "11a32c7e-0ea6-4297-87e3-1869822708b9",
      "name": "AttackAction",
      "category": "action",
      "title": "AttackAction",
      "description": "",
      "properties": {},
      "display": {
        "x": 1356,
        "y": 336
      }
    },
    "660d5893-ae35-4a27-8a3e-6afefa4d26d4": {
      "id": "660d5893-ae35-4a27-8a3e-6afefa4d26d4",
      "name": "Priority",
      "category": "composite",
      "title": "Priority",
      "description": "",
      "properties": {},
      "display": {
        "x": 852,
        "y": -84
      },
      "children": [
        "8f1a3aee-87bf-40ad-b143-7dc9e7d5ac77",
        "330b69c7-dbcb-4cd8-9b17-a17daf7f5d23",
        "42c31676-6903-488c-ad7e-7938f33e5909"
      ]
    },
    "0b6e8a7d-1265-4cfa-8898-b4fd74a810f2": {
      "id": "0b6e8a7d-1265-4cfa-8898-b4fd74a810f2",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 708,
        "y": -216
      },
      "children": [
        "361bb8da-9940-4be1-97ff-06802a2ab8ca",
        "660d5893-ae35-4a27-8a3e-6afefa4d26d4"
      ]
    },
    "2502ba27-abf8-416f-81b0-8265149ace23": {
      "id": "2502ba27-abf8-416f-81b0-8265149ace23",
      "name": "Priority",
      "category": "composite",
      "title": "Priority",
      "description": "",
      "properties": {},
      "display": {
        "x": 840,
        "y": 432
      },
      "children": [
        "2c6fd581-90e1-4955-86b3-1e87cc08af3e",
        "42db8fb9-58a6-479d-aeae-cab4053f2936",
        "c49597a3-82f7-4203-8a71-0637965e684c"
      ]
    },
    "d2b552c9-38f3-4ffb-8d3e-c291f33137c6": {
      "id": "d2b552c9-38f3-4ffb-8d3e-c291f33137c6",
      "name": "MoveAction",
      "category": "action",
      "title": "Flee",
      "description": "感知到视野范围内有敌人后进行逃跑,目标是最近的掩体路点",
      "properties": {},
      "display": {
        "x": 1356,
        "y": 480
      }
    },
    "c49597a3-82f7-4203-8a71-0637965e684c": {
      "id": "c49597a3-82f7-4203-8a71-0637965e684c",
      "name": "Succeeder",
      "category": "action",
      "title": "Succeeder",
      "description": "",
      "properties": {},
      "display": {
        "x": 1212,
        "y": 576
      }
    },
    "fa79a10a-870c-44c7-a29f-f11deee5b9b2": {
      "id": "fa79a10a-870c-44c7-a29f-f11deee5b9b2",
      "name": "MoveAction",
      "category": "action",
      "title": "StopMove",
      "description": "死亡状态下停止移动",
      "properties": {},
      "display": {
        "x": 468,
        "y": -48
      }
    },
    "e9ee3d82-6e5a-4e04-a673-dacaf7c8f57e": {
      "id": "e9ee3d82-6e5a-4e04-a673-dacaf7c8f57e",
      "name": "Priority",
      "category": "composite",
      "title": "Priority",
      "description": "",
      "properties": {},
      "display": {
        "x": 276,
        "y": -84
      },
      "children": [
        "91e8882b-1362-40c9-887c-5df5468cd3e1",
        "fa79a10a-870c-44c7-a29f-f11deee5b9b2"
      ]
    },
    "42c31676-6903-488c-ad7e-7938f33e5909": {
      "id": "42c31676-6903-488c-ad7e-7938f33e5909",
      "name": "MoveAction",
      "category": "action",
      "title": "MoveToStaticTarget",
      "description": "前往静态的目标点",
      "properties": {},
      "display": {
        "x": 1356,
        "y": 24
      }
    },
    "0510af90-b630-4336-b6b8-5db69f700baf": {
      "id": "0510af90-b630-4336-b6b8-5db69f700baf",
      "name": "DisCheck",
      "category": "condition",
      "title": "AttackDisCheck",
      "description": "",
      "properties": {
        "hasView": 1
      },
      "display": {
        "x": 1356,
        "y": -276
      }
    },
    "377b6c68-7b27-4caf-8ffd-cdfd2eb20657": {
      "id": "377b6c68-7b27-4caf-8ffd-cdfd2eb20657",
      "name": "DisCheck",
      "category": "condition",
      "title": "AttackDisCheck",
      "description": "",
      "properties": {
        "hasView": 1
      },
      "display": {
        "x": 1356,
        "y": 252
      }
    },
    "6bea6710-0dc5-4697-9c78-fd0f105be718": {
      "id": "6bea6710-0dc5-4697-9c78-fd0f105be718",
      "name": "DisCheck",
      "category": "condition",
      "title": "PursuitDisCheck",
      "description": "",
      "properties": {
        "hasView": 0
      },
      "display": {
        "x": 1356,
        "y": 396
      }
    },
    "330b69c7-dbcb-4cd8-9b17-a17daf7f5d23": {
      "id": "330b69c7-dbcb-4cd8-9b17-a17daf7f5d23",
      "name": "Sequence",
      "category": "composite",
      "title": "Sequence",
      "description": "",
      "properties": {},
      "display": {
        "x": 1164,
        "y": -84
      },
      "children": [
        "5e853deb-0d23-4077-93e7-65aeced917d3",
        "db006e35-cbaa-4b06-b38c-8303686a361f"
      ]
    },
    "db006e35-cbaa-4b06-b38c-8303686a361f": {
      "id": "db006e35-cbaa-4b06-b38c-8303686a361f",
      "name": "MoveAction",
      "category": "action",
      "title": "MoveForward",
      "description": "感知到视野范围内有敌人后前行",
      "properties": {},
      "display": {
        "x": 1356,
        "y": -60
      }
    },
    "5e853deb-0d23-4077-93e7-65aeced917d3": {
      "id": "5e853deb-0d23-4077-93e7-65aeced917d3",
      "name": "DisCheck",
      "category": "condition",
      "title": "PursuitDisCheck",
      "description": "",
      "properties": {
        "hasView": 0
      },
      "display": {
        "x": 1356,
        "y": -132
      }
    }
  },
  "display": {
    "camera_x": 237,
    "camera_y": 443.5,
    "camera_z": 0.75,
    "x": 0,
    "y": 0
  },
  "custom_nodes": [
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "AttackAction",
      "category": "action",
      "title": null,
      "description": null,
      "properties": {},
      "parent": null
    },
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "HpCheck",
      "category": "condition",
      "title": null,
      "description": null,
      "properties": {},
      "parent": null
    },
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "MoveAction",
      "category": "action",
      "title": null,
      "description": null,
      "properties": {},
      "parent": null
    },
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "GetHoldPoint",
      "category": "condition",
      "title": null,
      "description": "获取非己方占领的据点,获取不到返回失败,否则更新目标的m_targetPoint并返回成功",
      "properties": {},
      "parent": null
    },
    {
      "version": "0.3.0",
      "scope": "node",
      "name": "DisCheck",
      "category": "condition",
      "title": null,
      "description": null,
      "properties": {},
      "parent": null
    }
  ],
  "custom_folders": []
}
]]

--- 初始化
function NpcBehavior:Init()
    self.btJson = BTJson

    ---生命检测节点,接受传入的生命值(无参数默认为0,大于这个生命值百分比返回成功)
    local hpCheck = B3.Class('HpCheck', B3.Condition)
    B3.HpCheck = hpCheck
    function hpCheck:ctor()
        B3.Condition.ctor(self)
        self.name = 'HpCheck'
    end
    function hpCheck:tick(_tick)
        local hpRate = self.properties.hpRate
        hpRate = hpRate or 0
        ---@type NpcEnemyBase
        local npc = _tick.target
        if npc.model.Health > hpRate * 0.01 * npc.model.MaxHealth then
            return B3.SUCCESS
        else
            return B3.FAILURE
        end
    end

    ---NPC的移动节点
    local moveAction = B3.Class('MoveAction', B3.Action)
    B3.MoveAction = moveAction
    function moveAction:ctor()
        B3.Action.ctor(self)
        self.name = 'MoveAction'
    end
    function moveAction:tick(_tick)
        local title = self.title
        ---@type NpcEnemyBase
        local npc = _tick.target
        ---对Title进行判断,以执行具体的移动逻辑
        if title == 'PursueAction' then
            ---追击目标的逻辑
            npc:StartMoveToTargetPlayer()
        elseif title == 'Flee' then
            ---逃跑,目标是最近的掩体后的路点
            npc:StartFlee()
        elseif title == 'ReturnHome' then
            ---回家
            npc:StartReturnHome()
        elseif title == 'MoveToStaticTarget' then
            ---前往静态目标点
            npc:StartMoveStaticTarget()
        elseif title == 'MoveForward' then
            ---前行
            npc:MoveForward()
        elseif title == 'StopMove' then
            ---停止移动
            npc:StopMove()
        end
        if title ~= 'MoveForward' then
            npc:Navigate()
            npc:MoveByNavmesh()
        end
        return B3.SUCCESS
    end

    ---NPC攻击行为节点,选择自己最近的玩家进行攻击
    local attackAction = B3.Class('AttackAction', B3.Action)
    B3.AttackAction = attackAction
    function attackAction:ctor()
        B3.Action.ctor(self)
        self.name = 'AttackAction'
    end
    function attackAction:tick(_tick)
        ---@type NpcEnemyBase
        local npc = _tick.target
        npc:Attack()
        return B3.SUCCESS
    end

    ---检查指定范围内是否有敌人,hasView - 是否看到敌人,distance - 范围
    local disCheck = B3.Class('DisCheck', B3.Condition)
    B3.DisCheck = disCheck
    function disCheck:ctor()
        B3.Condition.ctor(self)
        self.name = 'DisCheck'
    end
    function disCheck:tick(_tick)
        local hasView = self.properties.hasView
        hasView = hasView == nil and false or true
        ---@type NpcEnemyBase
        local npc = _tick.target
        local distance = 0
        if self.title == 'AttackDisCheck' then
            distance = npc.attackDis
        elseif self.title == 'PursuitDisCheck' then
            distance = npc.pursuitDis
        end
        local res = npc:PerceiveEnemy(hasView, distance)
        if res then
            return B3.SUCCESS
        else
            return B3.FAILURE
        end
    end

    ---获取非己方占领的据点
    local getHoldPoint = B3.Class('GetHoldPoint', B3.Condition)
    B3.GetHoldPoint = getHoldPoint
    function getHoldPoint:ctor()
        B3.Condition.ctor(self)
        self.name = 'GetHoldPoint'
    end
    function getHoldPoint:tick(_tick)
        ---@type NpcEnemyBase
        local npc = _tick.target
        local hasPoint = npc:GetHoldPoint()
        if hasPoint then
            ---当前有非己方占领的据点
            --print('当前有非己方占领的据点')
            return B3.SUCCESS
        else
            ---当前所有的据点全部都是己方占领的
            return B3.FAILURE
        end
    end
end

---根据Json数据和传入的游戏模式,创建一个行为树并返回行为树实例
---@return BehaviorTree
function NpcBehavior:CreateBT(_gameMode)
    local behaviorTree = B3.BehaviorTree.new()
    local jsonStr = BTJson[_gameMode]
    if jsonStr then
        behaviorTree:load(jsonStr, {})
    end
    return behaviorTree
end

return NpcBehavior
