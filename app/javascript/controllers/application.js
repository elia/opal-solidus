import { Application } from "@hotwired/stimulus"
import { Controller } from '@hotwired/stimulus'
import StackTrace from 'stacktrace-js'

const application = Application.start()

// Configure Stimulus development experience
application.debug = true
window.Stimulus = application
window.Stimulus.Controller = Controller

// Stimulus.handleError = null
Stimulus.handleError = (error, message, detail) => {
  StackTrace.fromError(error)
    .then((stack) => {
      stack = stack.filter((s) => s.fileName && !s.fileName.match(/\.min[-\.]/))
      stack.forEach((s) => {
        if (s.fileName.match(/\.rb$/)) {
          const url = new URL(location.href)
          url.pathname = `/assets/opal/${s.fileName}`
          s.fileName = url.toString()
        }
      })
      console.error(
        `Stimulus error: ${message}`,
        detail,
        `\n\n${error}\n\n${stack.join('\n')}\n\n`,
      )
    })
    .catch((_e) => {
      throw error
    })
}

export { application }
