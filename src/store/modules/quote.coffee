import {random, isEmpty} from 'lodash'
import axios             from 'axios'

export default
  namespaced: true
  state:
    quote: {a: 1}
    categories: []
  mutations:
    'setQuote': (state, payload) ->
      state.quote = payload.quote
    'setCategory': (state, payload) ->
      state.categories = payload.categories
  actions:
    'getCategory': ({commit, state, rootState}) ->
      try
        {data} = await axios.get('http://localhost:3000/category')
        commit
          type: 'setCategory'
          categories: Object.keys data.categories
      catch error
        console.error error
        commit
          type: 'setCategory'
          categories: []
    'getQuote': ({dispatch, state, commit}, payload) ->
      try
        if isEmpty(state.categories)
          await dispatch('getCategory')
        category = payload?.category || state.categories[random(state.categories.length-1)]
        {data} = await axios.get 'http://localhost:3000/quote', { params: {category} }
        commit
          type: 'setQuote'
          quote: data.quotes[0]
      catch error
        console.error error
        commit
          type: setQuote
          quote: {}
