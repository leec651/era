<script lang="coffee">
axios = require 'axios'
export default
  name: "upload"
  data: ->
    file: ''
  methods:
    handleFileUpload: () ->
      this.file = this.$refs.file.files[0]
    submitFile: () ->
      console.log 'submitting'
      formData = new FormData()
      formData.append 'eraDelta', this.file
      # TODO handle error
      {status, data} = await axios.post 'http://localhost:2000/api/file', formData,
        headers:
          'Content-Type': 'multipart/form-data'
      console.log status, data
</script>

<template lang="pug">
  div.upload
    div.mt-24.flex.items-center.justify-center
      label.w-64.px-4.py-12.flex.flex-col.items-center.bg-blue-white.text-blue-700.rounded-lg.shadow-lg.tracking-wide.uppercase.border.border-blue-700.cursor-pointer(
        class="hover:text-white hover:bg-blue-500"
      )
        span.mt-2.text-base.leading-normal Select a file
        input.hidden(
          type='file'
          ref="file"
          v-on:change="handleFileUpload()"
        )
    div.mt-1.text-sm(v-if="file") Uploading {{ this.file.name }}
    button.mt-4.bg-blue-500.text-white.font-bold.py-2.px-4.rounded(
      :disabled="!this.file"
      :class="{'cursor-not-allowed': !this.file, 'opacity-50': !this.file, 'hover:bg-blue-700': 1}"
      @click="submitFile"
    ) Submit
</template>