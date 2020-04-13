import Vue         from 'vue'
import Vuex        from 'vuex'
import {snakeCase} from 'lodash'

import darkMode    from './modules/darkMode'
import quote       from './modules/quote'


Vue.use(Vuex)

modules = { darkMode, quote }
store = new Vuex.Store({
  modules
  strict: true
})

# populate actions & mutations for export
store.constant = {}
for _, module of modules
  if module.mutations
    for constant in Object.keys(module.mutations)
      store.constant[snakeCase(constant).toUpperCase()] = constant
  if module.actions
    for constant in Object.keys(module.actions)
      store.constant[snakeCase(constant).toUpperCase()] = constant

export default store
