<script lang="coffee">
import axios from 'axios'
import dayjs from 'dayjs'

HEADERS =
  status: 'Status'
  receivedAt: 'Received At'
  npi: 'NPI'
  taxId: 'Tax ID'
  name: 'Name'
  providerName: 'Provider Name'
  # email: 'Email'
  # phone: 'Phone'
  # tinInn: 'Tin Inn'
  # notes: 'Notes'
  # fileId: 'File ID'
  # createdAt: 'Created At'
  # updatedAt: 'Updated At'

export default
  name: 'home'
  data: -> return
    records: []
    limit: 20
  watch:
    $route: (to, from) ->
      try
        page = this.page
        {data} = await axios.get 'http://localhost:2000/api/record', { params: {page} }
        this.records = data
      catch error
        if error.response
          console.error error
          {status, data} = error.response
        else
  created: () ->
    if !this.page
      this.$router.push(
        name: 'home'
        query: { page: 1 }
      ).catch(->)
    else
      try
        {data} = await axios.get 'http://localhost:2000/api/record'
        this.records = data
      catch error
        if error.response
          console.error error
          {status, data} = error.response
        else
          console.log error.message
  computed:
    page: -> parseInt(this.$route.query.page)
    prettyHeaders: -> Object.values(HEADERS)
    prettyRecords: ->
      return this.records.map (record) ->
        return Object.assign {}, record,
          receivedAt: dayjs(record.receivedAt).format('YYYY-MM-DD')
          createdAt: dayjs(record.createdAt).format('YYYY-MM-DD')
          updatedAt: dayjs(record.updatedAt).format('YYYY-MM-DD')
  methods:
    statusColor: (status) ->
      console.log status
      return switch
        when status == 'approved' then 'bg-green-100'
        when status == 'rejected' then 'bg-red-100'
        when status == 'pending'  then 'bg-yellow-100'
    prettyName: (providerName) ->
      if providerName.length > 25
        providerName = "#{providerName.slice(0, 25)}..."
      return providerName
    previous: ->
      this.$router.push(
        name: 'home'
        query: { page: this.page-1 }
      ).catch(->)
    next: ->
      this.$router.push(
        name: 'home'
        query: { page: this.page+1 }
      ).catch(->)


</script>

<template>
<div class="mt-6 flex justify-center">
  <div class="px-20">

    <div class="mt-2 flex justify-center">
      <ul class="flex">
        <li class="mx-1 px-3 py-2 bg-gray-200 text-gray-700 hover:bg-gray-700 hover:text-gray-200 rounded-lg">
          <a class="flex items-center font-bold" href="#" >
            <span class="mx-1" @click="previous">
              previous
            </span>
          </a>
        </li>
        <li class="mx-1 px-3 py-2 bg-gray-200 text-gray-700 hover:bg-gray-700 hover:text-gray-200 rounded-lg">
          <a class="flex items-center font-bold" href="#">
            <span class="mx-1" @click="next">Next</span>
          </a>
        </li>
      </ul>
    </div>

    <table class="mt-6 bg-white border table-fixed w-full">
      <thead>
        <tr class="bg-gray-800 text-white">
          <th
            class="top-0 text-left px-3 py-4 uppercase text-sm"
            v-for="header in prettyHeaders"
            :key="header"
          >
            {{header}}
          </th>
        </tr>
      </thead>
      <tbody class="text-gray-700">
        <tr
          class="h-20 text-left hover:bg-gray-200"
          v-for="record in prettyRecords"
          :key="record._id"
        >
          <td
            class="h-20 px-4 py-3 border capitalize"
            :class="statusColor(record.status)"
          >
            {{ record.status }}
          </td>
          <td class="h-20 px-4 py-3 border">
            {{ record.receivedAt }}
          </td>
          <td class="h-20 px-4 py-3 border">
            {{ record.npi }}
          </td>
          <td class="h-20 px-4 py-3 border">
            {{ record.taxId }}
          </td>
          <td class="h-20 px-4 py-3 border">
            {{ record.name }}
          </td>
          <td class="h-20 px-4 py-3 border text-sm">
            {{ prettyName(record.providerName) }}
          </td>
        </tr>
      </tbody>
    </table>

  </div>
</div>
</template>