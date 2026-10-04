
Respo Form
----

Demo http://repo.respo-mvc.org/form.calcit/ .

### Hooks plugin API

to define form items:

```cirru
ns app.form $ :require $ form.schema :refer (FormItem FormOption FormOptions)

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
      div
        {}
          :style $ {} (:cursor :pointer) (:padding "\"0px 8px")
            :background-color $ hsl 0 0 90
          :on-click $ fn (e d!)
            modify-form! d! $ {}
              :name $ :name item
              :value $ inc $ or value 0
        <> $ or value 0
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

Calcit / `@calcit/procs` 0.27.0, Node.js 24, Yarn 4.18.0.
Only `calcit.cirru` and `deps.cirru` are maintained; retired snapshots are forbidden in CI.

```sh
caps --strict --ci
yarn install --immutable
caps verify --toolchain
calcit calcit.cirru --check-only
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

本次仅交付前端 COS/CDN 配置；Calcit 0.28 的类型迁移仍在独立候选中，
受共享 JS-FFI DOM 合同阻塞。这里保留主线 0.27 及现有全部检查，未以关闭
门禁或使用 alpha/hash 模块替代完整升级，不能据此认定 Calcit 迁移已完成。

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
