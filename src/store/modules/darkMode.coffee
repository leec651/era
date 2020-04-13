import dayjs   from 'dayjs'
import {isNil} from 'lodash'

export default
  namespaced: true
  state:
    darkMode: true
    toggleAt: Date.now()
  getters:
    prettyToggleAt: (state, rootState) ->
      return dayjs(state.toggleAt).format('hh:mm:ss a')
    audit: (state, getters) ->
      return "at #{getters.prettyToggleAt}"
  mutations:
    'toggle': (state, payload) ->
      state.darkMode = if isNil(payload?.darkMode) then !state.darkMode else payload.darkMode
      state.toggleAt = Date.now()
