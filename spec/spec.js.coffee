#= require_self
#= require jquery/jquery-2.0.3
#= require mocha/mocha-1.13.0
#= require chai/chai-1.8.0
#= require sinon/sinon-1.7.3
#= require sinon-chai/sinon-chai-2.4.0
#= require spec_helper
#= require_tree .

window.nodeRequire = window.require
window.nodeGlobal = window.global
window.nodeProcess = window.process
window.require = undefined
window.global = undefined
window.process = undefined
