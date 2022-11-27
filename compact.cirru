
{} (:package |form)
  :configs $ {} (:init-fn |form.main/main!) (:reload-fn |form.main/reload!) (:version |0.0.1)
    :modules $ [] |respo.calcit/ |lilac/ |memof/ |respo-ui.calcit/ |respo-markdown.calcit/ |reel.calcit/ |alerts.calcit/
  :entries $ {}
  :files $ {}
    |form.comp.container $ {}
      :defs $ {}
        |comp-container $ quote
          defcomp comp-container (reel)
            let
                store $ :store reel
                states $ :states store
                cursor $ or (:cursor states)
                    "\"\""
                    "\"\""
                    "\"\""
                    "\"\""
                state $ or (:data states)
                  {} $ :content "\""
              div
                {} $ :style (merge ui/global ui/row)
                comp-form (>> states :form-example) items ({})
                  fn (form) (println "\"form" form)
                  {} $ :on-cancel
                    fn () $ println "\"cancel"
                when dev? $ comp-reel (>> states :reel) reel ({})
        |items $ quote
          def items $ []
            {} (:type :input) (:label "\"Name") (:name :name) (:required? true) (:placeholder "\"a name")
            {} (:type :input) (:label "\"Place") (:name :place) (:placeholder "\"a name")
            {} (:type :select-popup) (:name :kind) (:label "\"Kind") (:placeholder "\"Nothing selected")
              :options $ []
                {} (:value :a) (:title "\"A")
                {} (:value :b) (:title "\"B")
            {} (:type :custom) (:name :custom) (:label "\"Counter")
              :render $ fn (value item modify-form! state)
                div
                  {}
                    :style $ {} (:cursor :pointer) (:padding "\"0px 8px")
                      :background-color $ hsl 0 0 90
                    :on-click $ fn (e d!)
                      modify-form! d! $ {}
                          :name item
                          inc value
                  <> $ or value 0
      :ns $ quote
        ns form.comp.container $ :require (respo-ui.core :as ui)
          respo-ui.core :refer $ hsl
          respo.core :refer $ defcomp defeffect <> >> div button textarea span input
          respo.comp.space :refer $ =<
          reel.comp.reel :refer $ comp-reel
          respo-md.comp.md :refer $ comp-md
          form.config :refer $ dev?
          form.core :refer $ comp-form
    |form.config $ {}
      :defs $ {}
        |dev? $ quote
          def dev? $ = "\"dev" (get-env "\"mode" "\"release")
        |site $ quote
          def site $ {} (:storage-key "\"workflow")
      :ns $ quote (ns form.config)
    |form.core $ {}
      :defs $ {}
        |%form-record $ quote (defrecord %form-record :fields :reset!)
        |comp-form $ quote
          defcomp comp-form (states items form0 on-change options)
            let
                cursor $ :cursor states
                state $ or (:data states) form0
                form-plugin $ use-form states items
              div ({}) (:fields form-plugin)
                div
                  {} $ :style ui/row-center
                  button $ {} (:style ui/button) (:inner-text "\"Cancel")
                    :on-click $ fn (e d!)
                        :on-cancel options
                  =< 8 nil
                  button $ {} (:style ui/button) (:inner-text "\"Submit")
                    :on-click $ fn (e d!) (on-change state)
        |css-close-icon $ quote
          defstyle css-close-icon $ {}
            "\"$0" $ {} (:opacity 0.3) (:cursor :pointer)
            "\"$0:hover" $ {} (:opacity 1)
        |render-custom $ quote
          defn render-custom (state item modify-form!)
            let
                render $ :render item
                value $ get state (:name item)
              render value item modify-form! state
        |render-input $ quote
          defn render-input (value item modify-form!)
            input $ {} (:style ui/input)
              :placeholder $ :placeholder item
              :value value
              :on-input $ fn (e d!)
                modify-form! d! $ {}
                    :name item
                    :value e
        |render-label $ quote
          defn render-label (item)
            div
              {} $ :style
                {} $ :width 100
              <> $ :label item
              if (:required? item)
                <> "\"*" $ {}
        |render-select-popup $ quote
          defn render-select-popup (states cursor value item modify-form!)
            let
                options $ -> (:options item)
                  map $ fn (option)
                    {}
                      :value $ :value option
                      :display $ :title option
                select-plugin $ use-modal-menu (>> states :select)
                  {} (:title "\"Select") (:items options)
                    :on-result $ fn (result d!)
                      modify-form! d! $ {}
                          :name item
                          , result
              div ({})
                div
                  {}
                    :style $ {} (:line-height "\"28px") (:padding "\"0 8px")
                      :background-color $ hsl 0 0 94
                      :border-radius "\"3px"
                      :cursor :pointer
                      :display :inline-block
                    :on-click $ fn (e d!) (.show select-plugin d!)
                  if (some? value)
                    div
                      {} $ :style ui/row
                      <> $ :display value
                      =< 8 nil
                      span $ {} (:inner-text "\"⨉") (:class-name css-close-icon)
                        :on-click $ fn (e d!)
                          modify-form! d! $ {}
                              :name item
                              , nil
                    <> "\"-" $ {}
                      :color $ hsl 0 0 80
                      :font-family ui/font-fancy
                .render select-plugin
        |use-form $ quote
          defn use-form (states form-items)
            let
                cursor $ :cursor states
                state $ either (:data states) ({})
                modify-form! $ fn (d! pairs)
                  let
                      new-form $ merge state pairs
                    d! cursor new-form
              %{} %form-record
                :fields $ list-> ({})
                  -> form-items $ map-indexed
                    fn (idx item)
                      [] idx $ div
                        {} $ :style
                          merge ui/row $ {} (:padding 8)
                        render-label item
                        case-default (:type item)
                          <> $ str "\"Unknown type " (:type item)
                          :input $ render-input
                            get state $ :name item
                            , item modify-form!
                          :select-popup $ render-select-popup states cursor
                            get state $ :name item
                            , item modify-form!
                          :custom $ render-custom state item modify-form!
                :reset! $ fn (data d!)
                  d! cursor $ {}
      :ns $ quote
        ns form.core $ :require
          respo.core :refer $ defcomp >> list-> <> div button textarea span input
          respo-ui.core :as ui
          respo-ui.core :refer $ hsl
          respo.comp.space :refer $ =<
          respo-alerts.core :refer $ use-modal-menu
          respo.css :refer $ defstyle
    |form.main $ {}
      :defs $ {}
        |*reel $ quote
          defatom *reel $ -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
        |dispatch! $ quote
          defn dispatch! (op op-data)
            when
              and config/dev? $ not= op :states
              println "\"Dispatch:" op
            reset! *reel $ reel-updater updater @*reel op op-data
        |main! $ quote
          defn main! ()
            println "\"Running mode:" $ if config/dev? "\"dev" "\"release"
            if config/dev? $ load-console-formatter!
            render-app!
            add-watch *reel :changes $ fn (reel prev) (render-app!)
            listen-devtools! |k dispatch!
            js/window.addEventListener |beforeunload $ fn (event) (persist-storage!)
            flipped js/setInterval 60000 persist-storage!
            ; let
                raw $ js/localStorage.getItem (:storage-key config/site)
              when (some? raw)
                dispatch! :hydrate-storage $ parse-cirru-edn raw
            println "|App started."
        |mount-target $ quote
          def mount-target $ .!querySelector js/document |.app
        |persist-storage! $ quote
          defn persist-storage! () (js/console.log "\"persist")
            js/localStorage.setItem (:storage-key config/site)
              format-cirru-edn $ :store @*reel
        |reload! $ quote
          defn reload! () $ if (nil? build-errors)
            do (remove-watch *reel :changes) (clear-cache!)
              add-watch *reel :changes $ fn (reel prev) (render-app!)
              reset! *reel $ refresh-reel @*reel schema/store updater
              hud! "\"ok~" "\"Ok"
            hud! "\"error" build-errors
        |render-app! $ quote
          defn render-app! () $ render! mount-target (comp-container @*reel) dispatch!
      :ns $ quote
        ns form.main $ :require
          respo.core :refer $ render! clear-cache!
          form.comp.container :refer $ comp-container
          form.updater :refer $ updater
          form.schema :as schema
          reel.util :refer $ listen-devtools!
          reel.core :refer $ reel-updater refresh-reel
          reel.schema :as reel-schema
          form.config :as config
          "\"./calcit.build-errors" :default build-errors
          "\"bottom-tip" :default hud!
    |form.schema $ {}
      :defs $ {}
        |store $ quote
          def store $ {}
            :states $ {}
              :cursor $ []
      :ns $ quote (ns form.schema)
    |form.updater $ {}
      :defs $ {}
        |updater $ quote
          defn updater (store op data op-id op-time)
            case-default op
              do (println "\"unknown op:" op) store
              :states $ update-states store data
              :hydrate-storage data
      :ns $ quote
        ns form.updater $ :require
          respo.cursor :refer $ update-states
