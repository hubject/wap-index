
var vm = new Vue({
    el: '#vue_html',
    data: {
        pageName: ''
    },
    mounted() {
        let url = window.location.pathname
        this.pageName = url.substring(url.lastIndexOf('/') + 1, url.length);
        console.log(this.pageName, 'loc')
    },
    methods: {
    }
})