<template>
<div id="app" class="box-border">
  <div class="pt-8 flex justify-center">
    <router-link to="/">
      <div class="py-3 px-6 mx-2 rounded-lg text-gray-800 hover:bg-gray-200 hover:font-medium">
        Home
      </div>
    </router-link>
    <router-link to="/upload">
      <div class="py-3 px-6 mx-2 rounded-lg text-gray-800 hover:bg-gray-200 hover:font-medium">
        Upload
      </div>
    </router-link>
  </div>
  <router-view/>
</div>
</template>

<style lang="stylus">
#app
  font-family Avenir, Helvetica, Arial, sans-serif
  -webkit-font-smoothing antialiased
  -moz-osx-font-smoothing grayscale
  text-align center
  height 100vh
</style>

