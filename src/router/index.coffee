import Vue       from 'vue'
import VueRouter from 'vue-router'
import Home      from '@/pages/Home.vue'


Vue.use(VueRouter)

routes = [
    path: '/'
    name: 'home'
    alias: '/h'
    component: Home
    children: [
      path: 'child'
      props: true
      name: 'child'
      component: () -> import('@/pages/Upload.vue')
    ]
  ,
    path: '/upload'
    name: 'upload'
    component: () -> import('@/pages/Upload.vue')
  ,
    path: '/a'
    redirect: '/about'
]

router = new VueRouter({
  mode: 'history'
  base: process.env.BASE_URL
  routes
})

export default router
