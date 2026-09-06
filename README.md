
Respo Form
----

Demo http://repo.respo-mvc.org/form.calcit/ .

### Hooks plugin API

to define form items:

```cirru
ns app.form $ :require
  form.schema :refer $ FormItem FormOption FormOptions

def form-items $ []
  %{} FormItem (:type :input) (:name :name) (:label |Name) (:required? (%some true)) (:placeholder (%some "|a name")) (:options (%none)) (:render (%none))
  %{} FormItem (:type :input) (:name :place) (:label |Place) (:required? (%none)) (:placeholder (%some "|a place")) (:options (%none)) (:render (%none))
  %{} FormItem (:type :select-popup) (:name :kind) (:label |Kind) (:required? (%none)) (:placeholder (%some "|Nothing selected")) (:render (%none))
    :options $ %some $ []
      %{} FormOption (:value :a) (:title |A)
      %{} FormOption (:value :b) (:title |B)
  %{} FormItem (:type :custom) (:name :custom) (:label |Counter) (:required? (%none)) (:placeholder (%none)) (:options (%none))
    :render $ %some $ fn (value item modify-form! state)
      div
        {}
          :style $ {} (:cursor :pointer)
            :padding "\"0px 8px"
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
.reset form-plugin d! $ {} (:name "|specified name")
```

### Component style API

With buttons inside the component:

```cirru.no-check
comp-form (>> states :form-example) form-items ({})
  fn (form)
    println |form form
  %{} FormOptions
    :on-cancel $ %some $ fn () (println |cancel)
```

### Workflow

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
