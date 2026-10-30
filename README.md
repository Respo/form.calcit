
Respo Form
----

### 使用者影响

CLI / `@calcit/procs` 配对正式 **0.32.1**，升级后重新安装整张依赖图、生成 JS 并
完整刷新。使用已发布 Alerts **0.11.0-alpha.4**、Reel **0.7.0-alpha.5**、UI **0.9.0**、
Respo **0.17.1**（传递 JS-FFI **0.2.9**）；仍含精确 alpha tag，不宣称整图全部稳定。
本 PR 不发布 Form tag/npm、不移动旧 **0.0.5**，也不合并部署生产。

官方工具转换25处旧类型标注，39个定义schema保持。选择菜单的nil/选中值分支在
修改调用外层，取消/Clear的nil、选中对象结构、字段名及一次派发保持。reset、自定义
renderer、公开异构字段、Enum入口、HUD和部署路径不变，不新增强转、测试脚本或预算。
原完整strict、八项Node回归、文档及unsafe/dynamic-method/deprecated零门禁保留。

Caps strict/toolchain使用真实已发布图，npm等待为一小时，无单包例外。项目没有Git
依赖，移除未使用的通配授权；原npm安装脚本策略保持。
此前0.32.0候选已验收字段输入、选择、自定义计数器、提交和刷新恢复；本次未重跑浏览器。

### Demo 存档恢复失败

无法解析或不符合store形状时，保留原 `Ignored_invalid_saved_state` HUD，但该会话
不启用60秒定时保存和离页保存，后续编辑也不自动保存，避免默认状态覆盖原文。
须恢复有效存档或在无存档状态重新启动才恢复自动保存；没有新增清空/修复按钮。
无存档或恢复成功时保留原60秒周期、离页保存、key和序列化格式。
此前隔离合成坏存档已验收启动、定时保存、离页及刷新后原文保留；本次未重复该验收，
不宣称所有历史存档均兼容，背景见 [#18](https://github.com/Respo/form.calcit/issues/18)。

### 公开边界

字段名为Tag，值和renderer载荷允许异构数据；开放Map仍开放，不为清零伪造类型。
renderer/修改函数参数顺序及真实 `Fn(Dynamic) -> Unit` dispatch合同保持；计数器先
检查数值再递增。CI不读取的旧质量统计文件此前已退役，当前仍保留全部实际门禁及
unsafe=0，不恢复无入口预算。项目没有附带native测试，不宣称native套件通过。

Demo http://repo.respo-mvc.org/form.calcit/ .

### Hooks plugin API

to define form items:

```cirru
ns app.form $ :require
  form.schema :refer $ FormItem FormOption FormOptions
  respo.core :refer $ div <>
  respo-ui.core :refer $ hsl

def form-items $ []
  FormItem (:type :input) (:name :name) (:label |Name)
    :required? $ Option :some true
    :placeholder $ Option :some "|a name"
    :options $ Option :none
    :render $ Option :none
  FormItem (:type :input) (:name :place) (:label |Place)
    :required? $ Option :none
    :placeholder $ Option :some "|a place"
    :options $ Option :none
    :render $ Option :none
  FormItem (:type :select-popup) (:name :kind) (:label |Kind)
    :required? $ Option :none
    :placeholder $ Option :some "|Nothing selected"
    :render $ Option :none
    :options $ Option :some $ []
      FormOption (:value :a) (:title |A)
      FormOption (:value :b) (:title |B)
  FormItem (:type :custom) (:name :custom) (:label |Counter)
    :required? $ Option :none
    :placeholder $ Option :none
    :options $ Option :none
    :render $ Option :some $ fn (value item modify-form! state)
      hint-fn $ Fn Dynamic form.schema/FormItem
        Fn
          Fn Dynamic $ -> Unit
          Map Tag Dynamic
          -> Unit
        Map Tag Dynamic
        -> respo.schema/Element
      div
        {}
          :style $ {} (:cursor :pointer) (:padding "\"0px 8px")
            :background-color $ hsl 0 0 90
          :on-click $ fn (e d!)
            hint-fn $ Fn (Map Tag Dynamic)
              Fn Dynamic $ -> Unit
              -> Unit
            modify-form! d! $ {}
              :name $ :name item
              :value $ let
                  counter $ or value 0
                if (number? counter) (inc counter) (raise |invalid-counter-value)
        <> $ str $ or value 0
```

to use APIs:

```cirru.no-check
use-form (>> states :items) items

;; "returns virtual DOM of form items"

.render form-plugin

;; "returns current form data"

.get form-plugin

;; "reset internal form data, defaults to empty hashmap"

.reset form-plugin d!

.reset form-plugin d! $ Option :some $ {} (:name "|specified name")
```

### Component style API

With buttons inside the component:

```cirru.no-check
comp-form (>> states :form-example) form-items ({})
  fn (form) (println |form form)
  FormOptions $ :on-cancel $ Option :some
    fn () $ println |cancel
```

### Workflow

Current source: formal Calcit / `@calcit/procs` 0.32.1, Node.js 24, Yarn 4.18.0.
Only `calcit.cirru` and `deps.cirru` are maintained; retired snapshots are forbidden in CI.

```sh
caps --strict --ci
yarn install --immutable
caps verify --toolchain
calcit calcit.cirru --check-only --all-defs
calcit fix --workflow strict --verify
calcit calcit.cirru js
yarn vite build
node --test scripts/form-regression.test.mjs
```

CI uploads only frontend `dist` assets to COS, uses an absolute CDN base URL,
and verifies public resources with cos-upload-action v1.2.0. PR asset paths use
`pr/<number>/<run-id>/<attempt>/`; each PR has its own queue, separate from the production queue.
The production prefix and original server rsync source/destination are unchanged.
Public upload verification uses the action's existing `public-base-url`, without
an additional checker. Missing PR credentials do not prove upload succeeded.

Actions 使用与原SHA对应的精确正式tag，接受可移动tag风险。不新增脚本、concurrently
或compiler fix规则。源码只维护calcit.cirru/deps.cirru，旧tag内容保持。

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
