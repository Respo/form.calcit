
Respo Form
----

Demo http://repo.respo-mvc.org/form.calcit/ .

### Hooks plugin API

to define form items:

```cirru
def form-items $ []
  {} (:type :input)
    :label "\"Name"
    :name :name
    :required? true
    :placeholder "\"a name"
  {} (:type :input)
    :label "\"Place"
    :name :place
    :placeholder "\"a place"
  {} (:type :select-popup)
    :name :kind
    :label "\"Kind"
    :placeholder "\"Nothing selected"
    :options $ []
      {} (:value :a)
        :title "\"A"
      {} (:value :b)
        :title "\"B"
  {} (:type :custom)
    :name :custom
    :label "\"Counter"
    :render $ fn (value item modify-form! state)
      div
        {}
          :style $ {} (:cursor :pointer)
            :padding "\"0px 8px"
            :background-color $ hsl 0 0 90
          :on-click $ fn (e d!)
            modify-form! d! $ {}
                :name item
                inc value
        <> $ or value 0
```

to use APIs:

```cirru
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

```cirru
comp-form (>> states :form-example) form-items ({})
  fn (form)
    println "\"form" form
  {} $ :on-cancel
    fn () $ println "\"cancel"
```

### Workflow

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
