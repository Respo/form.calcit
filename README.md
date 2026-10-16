
Respo Form
----

### 0.0.5 迁移候选：使用者需要注意

候选配对正式 Calcit / `@calcit/procs` 0.30.0、Alerts 0.10.54、Reel 0.6.38、
UI 0.7.40、Respo 0.16.120；消费者需协调相同的精确正式版本，不使用 alpha/hash。
尚未发版，PR CI、审查及原 main 部署完成前，不把本地检查当作生产验收。

字段名仍为 Tag，值和自定义 renderer 载荷仍允许异构数据；原空值、reset、选择菜单
与 Clear 语义保持。renderer/修改函数保留参数顺序，dispatch 回调收紧为
`Fn(Dynamic) -> Unit`，不再用裸 Fn 或伪断言代替真实调用合同。示例计数器先检查
数值再递增，并显式转换显示文本，未引入新的业务默认值。

当前 Ref/watch、公开 Option 和原生 match 取代旧入口；开放 action 在入口构造具名 Op。
原 8 项 Node 回归保留全部断言，仅将树遍历适配为 Respo 公共 ChildPair 接口。
项目无附带 native 测试，不宣称 native 套件通过。仍有开放 schema Dynamic，
不能宣称静态闭合；旧 quality 数量命令退役后，CI 使用当前 strict、全量定义和
原业务测试门禁，旧 `config/calcit-quality.cirru` 暂留审阅且没有扩容。

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
              :: 'Fn $ {} (:args $ [] 'Dynamic) (:return 'Unit)
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
                :: 'Fn $ {} (:args $ [] 'Dynamic) (:return 'Unit)
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

.reset form-plugin d! $ Option :some $ {} $ :name "|specified name"
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

Calcit / `@calcit/procs` 0.30.0, Node.js 24, Yarn 4.18.0.
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

此前仅交付 COS/CDN 的主线仍为 0.27；旧 0.28 工作树保持原样，本候选独立迁移到
0.30.0。重复/退役检查合并为当前入口，不新增脚本、concurrently 或 compiler fix 规则。

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
