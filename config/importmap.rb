# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "opal/application", to: "opal/application.js", preload: true
pin "stacktrace-js", to: "https://ga.jspm.io/npm:stacktrace-js@2.0.2/stacktrace.js"
pin "error-stack-parser", to: "https://ga.jspm.io/npm:error-stack-parser@2.1.4/error-stack-parser.js"
pin "source-map/lib/source-map-consumer", to: "https://ga.jspm.io/npm:source-map@0.5.6/lib/source-map-consumer.js"
pin "stack-generator", to: "https://ga.jspm.io/npm:stack-generator@2.0.10/stack-generator.js"
pin "stackframe", to: "https://ga.jspm.io/npm:stackframe@1.3.4/stackframe.js"
pin "stacktrace-gps", to: "https://ga.jspm.io/npm:stacktrace-gps@3.1.2/stacktrace-gps.js"
