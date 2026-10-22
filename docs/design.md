# 系统设计与开发路线

## 一、系统定位

面向**单管理员、单 GPU 工作站、串行任务**的本地「3DGS 重建管理与 Web 可视化系统」。输入：相机/手机/无人机采集的中小型静态场景重叠影像；输出：可浏览器查看的三维场景表示，附任务与模型版本管理、实验记录。不涉及公网开放训练、多用户调度、动态场景、精确测量。

## 二、整体架构（B/S）

```
┌──────────── 浏览器前端 ────────────┐
│ ① 重建场景查看器（Three.js 3DGS） │  ← 核心可视化
│ ② 管理界面（任务/模型/发布管理）    │  ← 轻量管理
└────────────────┬──────────────────┘
                 │ REST/WebSocket
┌────────────────┴──────────────────┐
│          后端（Python/FastAPI）      │
│  任务编排（调 COLMAP/ns-train 脚本） │
│  日志采集 · 指标存储 · 版本/发布控制 │
└────────────────┬──────────────────┘
        ┌────────┴────────┐
   SQLite 元数据      文件系统模型库
  (项目/任务/模型/      (checkpoint/ply/
    发布/指标)          影像/日志)
```

## 三、技术选型（建议）

| 层 | 选型 | 理由 |
|---|---|---|
| 3DGS 浏览器渲染 | Three.js + gaussian-splats-3d | 加载 nerfstudio 导出的 .ply，成熟、可旋转缩放 |
| 模型格式 | ns-export gaussian-splat 导出 .ply | nerfstudio 原生支持 |
| 后端 | Python FastAPI | 与重建工具链同语言，便于调用 |
| 元数据 | SQLite | 单机够用、零配置 |
| 前端构建 | Vite + TS | 现有 Node v24/npm 11 可用 |

## 四、数据模型（SQLite）

- **project**：项目（id, 名称, 路径, 创建时间）
- **dataset**：数据集（id, project_id, 影像目录, 张数, 元数据路径）
- **task**：任务（id, dataset_id, 类型[colmap|train|eval], 参数, 状态, 日志路径, 时间）
- **model**：模型版本（id, task_id, checkpoint路径, ply路径, 档位, 迭代数, 指标json, 创建时间）
- **release**：发布记录（id, model_id, 是否对外, ply路径, 发布时间）

## 五、功能模块与开发里程碑

### 里程碑 1：模型导出 + 独立 Web 查看器（已完成 2026-09-08）
- [x] ns-export gaussian-splat 导出正式模型 .ply → `outputs\export_run2\splat.ply`（250,973 高斯点，59.4MB）
- [x] Vite 初始化前端 `webviewer/`，接入 gaussian-splats-3d 0.4.7
- [x] 浏览器加载 .ply，旋转/缩放查看；`antialiased:true` 解决 gsplat 抗锯齿伪影（玻璃碴子）
- 技术要点：查看器需 `crossOriginIsolated`（vite 加 COOP/COEP 头）；nerfstudio 导出为 z-up
- 验收达成：输入 .ply → 浏览器显示可交互 3D 场景
- 遗留：初始朝向/相机位置待按场景调优；59MB ply 较大，后续可转 .ksplat 优化体积与性能

### 里程碑 2：后端任务编排与元数据（SQLite）
> 说明：本节为**设计/计划**（尚未实现，仅里程碑1 已落地）。最低验收线已缩窄，避免承诺过宽。

#### 里程碑 2 · 最低验收线（缩窄后的范围）
1. 登记数据集（指定影像目录，扫描张数入库）
2. 启动训练任务（拉子进程跑已验证的 ns-train 脚本）
3. 查看任务状态与日志
4. 记录训练参数、模型路径、评测指标到 SQLite

> **次要功能（可后补，不阻塞本里程碑）**：COLMAP 自动任务、发布控制、完整模型版本管理、实时指标对比页面。当前不要求自动完成「数据集→COLMAP→训练→导出」全链。

#### 里程碑 2 · 详细设计（供 CodeX 落地）

**代码布局（新建 `server/` 目录，与 `webviewer/`、`scripts/` 并列）**

```
server/
├─ main.py            # FastAPI 应用入口，挂载路由与静态服务
├─ config.py          # 路径、ns_cu128 环境、CUDA 常量
├─ db.py              # SQLite 连接、建表、初始化
├─ schemas.py         # Pydantic 请求/响应模型
├─ runner.py          # 任务执行器：调已验证的 ns-train 子进程
├─ routers/
│   ├─ projects.py    # 项目 CRUD
│   ├─ datasets.py    # 数据集登记 + 影像列表
│   ├─ tasks.py       # 任务创建/状态/日志
│   ├─ models.py      # 模型版本与指标登记
│   └─ releases.py    # 发布记录（次要）
└─ data/db.sqlite3    # 元数据库（生成）
```

**SQLite 表结构**

| 表 | 字段（类型） | 说明 |
|---|---|---|
| **project** | id(PK), name, description, created_at | 重建项目 |
| **dataset** | id(PK), project_id(FK), name, image_dir, image_count, source_note, metadata_csv, created_at | 一组影像 |
| **task** | id(PK), dataset_id(FK), kind, method, params_json, status, log_path, output_dir, start_at, end_at, created_at | kind ∈ colmap/train/eval（本轮先支持 train） |
| **model** | id(PK), task_id(FK), tier, name, iterations, checkpoint_path, ply_path, metrics_json, model_size_bytes, created_at | tier ∈ fast/standard/high |
| **release** | id(PK), model_id(FK), published(bool), ply_path, viewer_url, released_at | 发布记录（次要） |

- `task.params_json`：保存训练参数快照（迭代数、种子、档位等），保证可复现
- `model.metrics_json`：存 ns-eval 输出（psnr/ssim/lpips/fps 等）
- 表均为轻量；用 `foreign_keys=ON`

**后端 API（REST，前缀 /api）——按最低验收线分级**

| 方法/路径 | 作用 | 优先级 |
|---|---|---|
| POST/GET `/projects` | 建/列项目 | 低 |
| POST `/projects/{id}/datasets` | 登记数据集 | 高 |
| GET `/datasets/{id}/images` | 列影像 | 中 |
| POST `/tasks` | 创建训练任务 | 高 |
| GET `/tasks/{id}` · `/tasks/{id}/log` | 任务状态 · 日志 | 高 |
| POST `/models` · GET `/models` | 训练后登记模型与指标 | 高 |
| POST/GET `/releases` | 发布 | 低（次要） |

**任务执行器（runner.py）实现要点（关键）**
- **不能依赖交互式 `conda activate`**：FastAPI 的 Python 子进程需用非交互方式构造训练环境，任选其一：
  1. 直接调用 ns_cu128 环境内可执行文件绝对路径（`...\ns_cu128\Scripts\ns-train.exe`）；
  2. 由 `cmd.exe /c` 先执行 `VsDevCmd.bat`（cl 19.33）再执行训练命令；
  3. 在 Python 中显式构造并传入环境变量（CUDA_HOME=v12.8、PATH 前缀、`TORCH_CUDA_ARCH_LIST=8.9`、`PYTHONUTF8=1`）；
  4. **最稳妥**：统一调用本项目已验证的 `scripts\run_train_cu128.bat`，把训练参数作为脚本输入。
- 环境若不完整，会触发 gsplat 缓存 key 不匹配（无谓重编译）或 GBK 报错——与命令行手动运行同因。
- 日志实时写入 `log_path`；`status` 随进程：queued→running→done/failed。
- **「训练成功后自动调 `ns-export gaussian-splat` 并登记 model/release」为计划行为，未经验证**，实现时先人工跑通 export 再接入，勿默认可用。

**里程碑 2 验收**
- 通过 API 能把「登记数据集 → 发起 train 任务 → 查状态/日志 → 训练参数/模型路径/指标入库」走通。
- 回填本项目已有运行 2 为一条 model 记录（含 checkpoint、ply、metrics_json）。
- 本项验收**不含**「后端自动跑 COLMAP / 自动 export」——属次要功能。

### 里程碑 3：管理界面整合
- [ ] 数据选择 → 启动任务 → 进度/日志展示 → 模型列表/指标
- [ ] 发布入口与查看（次要）
- 页面以查看器 + 轻量管理为主，不做复杂权限/审批

### 里程碑 4：收尾
- [ ] 异常流程、浏览器兼容、演示测试
- [ ] 与实验记录/论文实验章节对接
- [ ] 明确「已实现」与「计划实现」边界后再写论文

## 六、范围约束（不实现）
公网开放训练、多用户 GPU 调度、动态场景、网格编辑、精确测量、3DGS 核心算法改动、自研光栅化器（用已验证查看组件）。
