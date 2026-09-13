
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |form
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'form.main/main!) (:mode :native)
      :reload-fn 'form.main/reload!
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |lilac/ |memof/ |respo-ui.calcit/ |respo-markdown.calcit/ |reel.calcit/ |alerts.calcit/
      :type-slots $ {}
  :files $ {}
    'form.comp.container $ %{} 'FileEntry
      :defs $ {}
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (reel)
            let
                store $ assert-type (read-field reel :store) (:: 'Map 'Tag 'Dynamic)
                states $ assert-type (read-field store :states) (:: 'Map 'Tag 'Dynamic)
              div
                {} $ :style $ merge ui/global ui/row
                comp-form (>> states :form-example) form-items ({})
                  fn (form) (println |form form)
                  %{} FormOptions $ :on-cancel $ %some
                    fn () $ println |cancel
                when dev? $ comp-reel (>> states :reel) reel $ {}
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic
        'form-items $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def form-items
            []
              %{} FormItem (:type :input) (:name :name) (:label |Name)
                :required? $ %some true
                :placeholder $ %some "|a name"
                :options $ %none
                :render $ %none
              %{} FormItem (:type :input) (:name :place) (:label |Place)
                :required? $ %none
                :placeholder $ %some "|a place"
                :options $ %none
                :render $ %none
              %{} FormItem (:type :select-popup) (:name :kind) (:label |Kind)
                :required? $ %none
                :placeholder $ %some "|Nothing selected"
                :render $ %none
                :options $ %some $ []
                  %{} FormOption (:value :a) (:title |A)
                  %{} FormOption (:value :b) (:title |B)
              %{} FormItem (:type :custom) (:name :custom) (:label |Counter)
                :required? $ %none
                :placeholder $ %none
                :options $ %none
                :render $ %some $ fn (value item modify-form! state)
                  let
                      typed-item $ assert-type item 'form.schema/FormItem
                    div
                      {}
                        :style $ {} (:cursor :pointer) (:padding "|0px 8px")
                          :background-color $ hsl 0 0 90
                        :on-click $ fn (e d!)
                          modify-form! d! $ {}
                            :name $ :name typed-item
                            :value $ inc $ or value 0
                      <> $ or value 0
          :examples $ []
          :schema $ :: 'List 'form.schema/FormItem
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns form.comp.container
          :require (respo-ui.core :as ui)
            respo-ui.core :refer $ hsl
            respo.core :refer $ defcomp defeffect <> >> div button textarea span input
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-reel
            respo-md.comp.md :refer $ comp-md
            form.config :refer $ dev?
            form.core :refer $ comp-form
            form.schema :refer $ FormItem FormOption FormOptions
            reel.schema :refer $ read-field
    'form.config $ %{} 'FileEntry
      :defs $ {}
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ option:unwrap-or (get-env |mode) |release
          :examples $ []
          :schema $ :: 'Dynamic
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site
            {} $ :storage-key |workflow
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns form.config
    'form.core $ %{} 'FileEntry
      :defs $ {}
        '%form-plugin $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn %form-plugin (state rendered cursor)
            %:: (impl-traits FormPlugin0 FormPluginImpl) :form state rendered cursor
          :examples $ []
          :schema $ :: 'Dynamic
        'FormPlugin0 $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum FormPlugin0
            :form (:: 'Map 'Tag 'Dynamic) 'Dynamic 'List
          :examples $ []
          :schema $ :: 'EnumDef
        'FormPluginImpl $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defimpl FormPluginImpl FormPluginTrait (.get form-plugin-get)
            .render form-plugin-render
            .reset form-plugin-reset
          :examples $ []
          :schema $ :: 'Impl
        'FormPluginTrait $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait FormPluginTrait (.get :fn) (.render :fn) (.reset :fn)
          :examples $ []
          :schema $ :: 'Trait
        'comp-form $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-form (states items form0 on-change options)
            let
                typed-states $ decode-map-as states form.schema/FormStates
                state $ option:unwrap-or (:data typed-states) form0
                form-plugin $ use-form (>> states :items) items
                on-cancel $ option:unwrap-or (:on-cancel options)
                  fn () &unit
              div ({})
                form-plugin-render form-plugin
                div
                  {} $ :style ui/row-center
                  button $ {} (:style ui/button) (:inner-text |Cancel)
                    :on-click $ fn (e d!)
                      do
                        form-plugin-reset form-plugin d!
                        on-cancel
                  =< 8 nil
                  button $ {} (:style ui/button) (:inner-text |Submit)
                    :on-click $ fn (e d!)
                      on-change $ form-plugin-get form-plugin
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Map
              :: 'List 'form.schema/FormItem
              :: 'Map 'Tag 'Dynamic
              , 'Fn 'form.schema/FormOptions
        'css-close-icon $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstyle css-close-icon
            {}
              |$0 $ {} (:opacity 0.3) (:cursor :pointer)
              |$0:hover $ {} $ :opacity 1
          :examples $ []
          :schema $ :: 'Dynamic
        'form-plugin-get $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn form-plugin-get (self)
            match self
              (:form state rendered cursor) state
              _ $ raise |Invalid-form-plugin
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'form.core/FormPlugin0
            :return $ :: 'Map 'Tag 'Dynamic
        'form-plugin-render $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn form-plugin-render (self)
            match self
              (:form state rendered cursor) rendered
              _ $ raise |Invalid-form-plugin
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'form.core/FormPlugin0
        'form-plugin-reset $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn form-plugin-reset (self d! data)
            match self
              (:form state rendered cursor)
                d! $ :: :states cursor $ option:unwrap-or data ({})
              _ $ raise |Invalid-form-plugin
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'form.core/FormPlugin0 'Fn $ :: 'Option (:: 'Map 'Tag 'Dynamic)
        'render-custom $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-custom (state item modify-form!)
            let
                value $ if-let
                  v $ get state $ :name item
                  , v nil
                render $ option:unwrap-or (:render item)
                  fn (value item modify-form! state)
                    div ({})
                      <> |Missing-custom-renderer
              render value item modify-form! state
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'form.schema/FormItem 'Fn
        'render-input $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-input (value item modify-form!)
            input $ {} (:style ui/input)
              :placeholder $ option:unwrap-or (:placeholder item) |
              :value value
              :on-input $ fn (e d!)
                modify-form! d! $ {}
                  :name $ :name item
                  :value e
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'form.schema/FormItem 'Fn
        'render-label $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-label (item)
            div
              {} $ :style $ {} (:width 100)
              <> $ :label item
              if
                option:unwrap-or (:required? item) false
                <> |* $ {}
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'form.schema/FormItem
        'render-select-popup $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-select-popup (states cursor value item modify-form!)
            let
                options $ ->
                  option:unwrap-or (:options item) ([])
                  map $ fn (option)
                    let
                        typed-option $ assert-type option 'form.schema/FormOption
                      {}
                        :value $ :value typed-option
                        :display $ :title typed-option
                placeholder $ option:unwrap-or (:placeholder item) "|To select..."
                selected $ value .and-then $ fn (raw)
                  if (nil? raw) (%none)
                    %some $ decode-map-as raw SelectedOption
                select-plugin $ use-modal-menu (>> states :select)
                  {} (:title |Select) (:items options)
                    :on-result $ fn (result d!)
                      modify-form! d! $ {}
                        :name $ :name item
                        :value result
              div ({})
                div
                  {}
                    :style $ {} (:line-height |28px) (:padding "|0 8px")
                      :background-color $ hsl 0 0 94
                      :border-radius |3px
                      :cursor :pointer
                      :display :inline-block
                      :min-width 80
                    :on-click $ fn (e d!) (.show select-plugin d!)
                  if-let (raw-selected selected)
                    let
                        selected-item $ assert-type raw-selected 'form.schema/SelectedOption
                      div
                        {} $ :style ui/row
                        <> $ :display selected-item
                        =< 8 nil
                        span $ {} (:inner-text "|⨉") (:class-name css-close-icon)
                          :on-click $ fn (e d!)
                            modify-form! d! $ {}
                              :name $ :name item
                              :value nil
                    <> placeholder $ {}
                      :color $ hsl 0 0 80
                      :font-family ui/font-fancy
                      :font-style :italic
                .render select-plugin
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Map 'List (:: 'Option 'Dynamic) 'form.schema/FormItem 'Fn
        'use-form $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn use-form (states form-items)
            let
                typed-states $ decode-map-as states form.schema/FormStates
                cursor $ :cursor typed-states
                state $ option:unwrap-or (:data typed-states) ({})
                modify-form! $ fn (d! pairs)
                  let
                      new-form $ merge state pairs
                    d! $ :: :states cursor new-form
                rendered $ list-> ({})
                  map-indexed form-items $ fn (idx raw-item)
                    let
                        item $ assert-type raw-item 'form.schema/FormItem
                        item-value $ get state $ :name item
                      [] idx $ div
                        {} $ :style $ merge ui/row
                          {} $ :padding |8px
                        render-label item
                        case-default (:type item)
                          <> $ str "|Unknown type " $ :type item
                          :input $ render-input
                            if-let (value item-value) value nil
                            , item modify-form!
                          :select-popup $ render-select-popup states cursor item-value item modify-form!
                          :custom $ render-custom state item modify-form!
              %form-plugin state rendered cursor
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns form.core
          :require
            respo.core :refer $ defcomp >> list-> <> div button textarea span input
            respo-ui.core :as ui
            respo-ui.core :refer $ hsl
            respo.comp.space :refer $ =<
            respo-alerts.core :refer $ use-modal-menu
            respo.css :refer $ defstyle
            form.schema :refer $ FormItem FormOption FormOptions FormStates SelectedOption
    'form.main $ %{} 'FileEntry
      :defs $ {}
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *reel
            -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
          :examples $ []
          :schema $ :: 'Dynamic
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when config/dev? $ match op
              (:states _ _) &unit
              _ $ println |Dispatch: op
            reset! *reel $ reel-updater updater @*reel op
          :examples $ []
          :schema $ :: 'Dynamic
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            println "|Running mode:" $ if config/dev? |dev |release
            if config/dev? $ load-console-formatter!
            render-app!
            add-watch *reel :changes $ fn (reel prev) (render-app!)
            listen-devtools! |k dispatch!
            js/window.addEventListener |beforeunload $ fn (event) (persist-storage!)
            flipped js/setInterval 60000 persist-storage!
            ; let
              (raw (js/localStorage.getItem (:storage-key config/site)))
              when (some? raw)
                dispatch! :hydrate-storage $ parse-cirru-edn raw
            println "|App started."
          :examples $ []
          :schema $ :: 'Dynamic
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def mount-target
            js/document.querySelector |.app
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'JsObject)
            :args $ []
            :features $ #{} :js-ffi
        'persist-storage! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-storage! () (js/console.log |persist)
            js/localStorage.setItem (:storage-key config/site)
              format-cirru-edn $ :store @*reel
          :examples $ []
          :schema $ :: 'Dynamic
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            if (nil? build-errors)
              do (remove-watch *reel :changes) (clear-cache!)
                add-watch *reel :changes $ fn (reel prev) (render-app!)
                reset! *reel $ refresh-reel @*reel schema/store updater
                hud! |ok~ |Ok
              hud! |error build-errors
          :examples $ []
          :schema $ :: 'Dynamic
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render! mount-target (comp-container @*reel) dispatch!
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns form.main
          :require
            respo.core :refer $ render! clear-cache!
            form.comp.container :refer $ comp-container
            form.updater :refer $ updater
            form.schema :as schema
            reel.util :refer $ listen-devtools!
            reel.core :refer $ reel-updater refresh-reel
            reel.schema :as reel-schema
            form.config :as config
            |./calcit.build-errors :default build-errors
            |bottom-tip :default hud!
    'form.schema $ %{} 'FileEntry
      :defs $ {}
        'FormItem $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct FormItem (:type 'Tag) (:name 'Tag) (:label 'String)
            :required? $ :: 'Option 'Bool
            :placeholder $ :: 'Option 'String
            :options $ :: 'Option $ :: 'List 'form.schema/FormOption
            :render $ :: 'Option $ :: 'Fn
              {}
                :args $ [] 'Dynamic 'form.schema/FormItem 'Fn $ :: 'Map 'Tag 'Dynamic
                :return 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'FormOption $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct FormOption (:value 'Tag) (:title 'String)
          :examples $ []
          :schema $ :: 'StructDef
        'FormOptions $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct FormOptions
            :on-cancel $ :: 'Option $ :: 'Fn
              {}
                :args $ []
                :return 'Unit
          :examples $ []
          :schema $ :: 'StructDef
        'FormStates $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct FormStates (:cursor 'List)
            :data $ :: 'Option $ :: 'Map 'Tag 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'SelectedOption $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct SelectedOption (:value 'Tag) (:display 'String)
          :examples $ []
          :schema $ :: 'StructDef
        'store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def store
            {} $ :states $ {}
              :cursor $ []
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns form.schema
    'form.updater $ %{} 'FileEntry
      :defs $ {} $ 'updater
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-id op-time)
            match op
              (:states cursor data) (update-states store cursor data)
              (:hydrate-storage data) data
              _ $ do (println "|unknown op:" op) store
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns form.updater
          :require $ respo.cursor :refer $ update-states
