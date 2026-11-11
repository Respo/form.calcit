
Respo Form
----

### 使用者影响

CLI 与 `@calcit/procs` 均使用正式 **0.41.0**。升级后需要重新安装依赖并生成 JS。
Alerts **0.14.3**、Reel **0.11.0**、UI **0.15.2**、Respo **0.19.5** 均使用正式标签。

表单仍接受异构字段，选择与清除保留原 Map 和 nil 形状。插件的读取与重置方法
共享表单值类型，重置回调接收具名操作，组件游标采用 Respo 的 `CoordKey`。
Demo 的表单派发绑定具名 `Op`，Reel 控件通过独立的 `Control` 回调派发，两类事件在内部用 union 汇合。Calcit 0.38.0 中 `.get` 与内建 Enum 方法
同名，读取表单请使用 `form.core/form-plugin-get`。HUD、存档键和前端部署路径保持。

### Demo 存档恢复失败

无法解析或不符合store形状时，保留原 `Ignored_invalid_saved_state` HUD，但该会话
不启用60秒定时保存和离页保存，后续编辑也不自动保存，避免默认状态覆盖原文。
修复为有效存档后仍须重新启动，或在无存档状态重新启动，才恢复自动保存；同一失败会话不会因外部修复存档而重新注册保存。没有新增清空/修复按钮。
无存档或恢复成功时保留原60秒周期、离页保存、key和序列化格式。
坏存档保护的历史验收见 [#18](https://github.com/Respo/form.calcit/issues/18)。

### 公开边界

字段名为 Tag，值和自定义 renderer 载荷可异构。renderer 和修改函数的参数顺序及回调合同沿用，
计数器先检查数值再递增。保留完整 strict、原 Node 回归和零 unsafe、dynamic-method、deprecated 门禁。

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

form.core/form-plugin-get form-plugin

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
mode=dev node --test scripts/form-regression.test.mjs
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
