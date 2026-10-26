
Respo Form
----

### Demo 存档恢复失败时的行为

如果 Demo 的原存档无法解析或不符合 store 形状，页面仍显示原来的
`Ignored_invalid_saved_state` HUD，但本次会话不再启用 60 秒定时保存和离页保存，
避免默认状态覆盖原始存档。该会话中的后续编辑也不会自动保存；需要先恢复有效
存档，或在无存档状态下重新启动，才恢复原自动保存。没有新增清空/修复按钮。

无存档或恢复成功时仍使用原 60 秒周期与离页保存，不改变 key、序列化格式、
表单公开 API、reset/Clear 语义或已合并的 Map 方法迁移。不发布新的模块版本。
正式 Calcit 0.30.1 的完整 strict、232 个定义检查及原 8 项 Node 测试通过；
全新回环来源的合成坏存档经过实际启动、超过 60 秒等待、离页和刷新后仍保留
原文。该验收不读取真实存档，也不代表所有历史存档均兼容。问题背景见
[#18](https://github.com/Respo/form.calcit/issues/18)。

### 本轮 Map 方法写法迁移：使用者影响

两处样式合并改用 Map 的 `.merge`，保留相同的参数顺序和右侧覆盖语义；
表单字段、reset/Clear、自定义 renderer、派发与存档合同不变，消费者无需适配。
工具链继续配对正式 Calcit / `@calcit/procs` `0.30.1`，本轮不改依赖或发布版本。
开放 Map 类型仍然开放，不把方法写法迁移当作 Dynamic 债务清零。
隔离官方 Linux CI 在修改前后执行原完整 strict、全量定义、原八项 Node 回归、
文档、构建和 unsafe/dynamic-method/deprecated 零门禁，并比较全部生成模块字节。
最终 PR CI 与预览状态以对应运行结果为准，不代表已合并、发版或部署生产。

### 当前源码：使用者需要注意

本轮源码配对正式 Calcit / `@calcit/procs` `0.30.1`，并使用一致的
正式依赖图：Alerts `0.10.57`、Reel `0.6.41`、UI `0.8.0`、Respo `0.16.124`，
传递依赖统一到 Router `0.8.37` 与 JS-FFI `0.2.5`。不使用 alpha、main 或 hash
模块依赖；消费者升级时应协调同一组正式版本，不能仅替换根工具链。
源码、公开 API、异构字段、reset/Clear 语义、原 8 项回归和部署路径不变；
不新增验证脚本、强转或改写规则，不放宽类型预算，不合并、不发版。
已确认旧 quality 基线不被现有 CI、脚本或 strict 读取，故从当前树退役；原数据
仍可从 `0.0.5` tag/Git 历史恢复。原实际门禁不减少，并用当前 `weak-types`
直接落实 `unsafe=0` 硬门禁。27 项既有动态/空值边界保留，不把删除未使用的
统计文件当作类型债务清零。

正式图通过 Linux CI 验收，不使用本地旧 CLI 编译正式依赖图，不将单平台验收
当作完整跨平台兼容保证。旧 `0.0.5` tag 保持原内容；模块版本字段仍为 `0.0.5`，
不把它冒充新的已发布升级。历史版本的迁移影响见下文。

### 0.0.5：历史升级影响

本版本配对正式 Calcit / `@calcit/procs` 0.30.0、Alerts 0.10.54、Reel 0.6.38、
UI 0.7.40、Respo 0.16.120；消费者需协调相同的精确正式版本，不使用 alpha/hash。
此前公开 tag 只有 0.0.1，0.0.2–0.0.4 未发布 tag；从 0.0.1 升级还包含多年主线的
累计 API 变化，需按本页和当前公开 schema 迁移，不能假定无需修改调用方。
本轮迁移已通过 PR #13、精确 main CI 及原部署验收；Git tag/Release 发布状态
以仓库 Releases 为准，不以版本字段或本地检查推断正式产物已经发布。

字段名仍为 Tag，值和自定义 renderer 载荷仍允许异构数据；原空值、reset、选择菜单
与 Clear 语义保持。renderer/修改函数保留参数顺序，dispatch 回调收紧为
`Fn(Dynamic) -> Unit`，不再用裸 Fn 或伪断言代替真实调用合同。示例计数器先检查
数值再递增，并显式转换显示文本，未引入新的业务默认值。

当前 Ref/watch、公开 Option 和原生 match 取代旧入口；开放 action 在入口构造具名 Op。
原 8 项 Node 回归保留全部断言，仅将树遍历适配为 Respo 公共 ChildPair 接口。
项目无附带 native 测试，不宣称 native 套件通过。仍有开放 schema Dynamic，
不能宣称静态闭合；旧 quality 数量命令退役后，CI 使用当前 strict、全量定义和
原业务测试门禁。旧 `config/calcit-quality.cirru` 在 0.0.5 当时暂留审阅；
本轮确认没有执行入口引用后将其退役；保留全部实际门禁，并落实 `unsafe=0`，
没有扩容预算。

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
      hint-fn $ {}
        :args $ [] 'Dynamic 'form.schema/FormItem
          :: 'Fn $ {} (:return 'Unit)
            :args $ []
              :: 'Fn $ {}
                :args $ [] 'Dynamic
                :return 'Unit
              :: 'Map 'Tag 'Dynamic
          :: 'Map 'Tag 'Dynamic
        :return 'respo.schema/Element
      div
        {}
          :style $ {} (:cursor :pointer) (:padding "\"0px 8px")
            :background-color $ hsl 0 0 90
          :on-click $ fn (e d!)
            hint-fn $ {}
              :args $ [] (:: 'Map 'Tag 'Dynamic)
                :: 'Fn $ {}
                  :args $ [] 'Dynamic
                  :return 'Unit
              :return 'Unit
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

Current source: formal Calcit / `@calcit/procs` 0.30.1, Node.js 24, Yarn 4.18.0.
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

此前仅交付 COS/CDN 的主线为 0.27；0.0.5 完成了 0.30.0 迁移，本轮在其基础上
配对升级。旧工作树及未提交改动保持原样，不新增脚本、concurrently 或 compiler fix 规则。

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
