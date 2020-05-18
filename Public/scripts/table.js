
$( document ).ready(function() {

    console.log("asdfasdfasdf")
   var e = document.querySelectorAll("[data-list]"),
      t = document.querySelectorAll("[data-sort]");

   function f(e, t, a) {
      var o = [].slice.call(e).filter(function (e) {
         return e.checked
      });
      t && (o.length ? t.classList.add("show") : t.classList.remove("show"), a.innerHTML = o.length)
   }
   "undefined" != typeof List && e && [].forEach.call(e, function (e) {
      var t, a, o, l, n, r, c, s, i, d, u;
      a = (t = e).querySelector(".list-alert"), o = t.querySelector(".list-alert-count"), l = t.querySelector(".list-alert .close"), n = t.querySelectorAll(".list-checkbox"), r = t.querySelector(".list-checkbox-all"), c = t.querySelector(".list-pagination-prev"), s = t.querySelector(".list-pagination-next"), i = t.dataset.list && JSON.parse(t.dataset.list), d = Object.assign({
         listClass: "list",
         searchClass: "list-search",
         sortClass: "list-sort"
      }, i), u = new List(t, d), s && s.addEventListener("click", function (e) {
         e.preventDefault();
         var t = u.i + u.page;
         t <= u.size() && u.show(t, u.page)
      }), c && c.addEventListener("click", function (e) {
         e.preventDefault();
         var t = u.i - u.page;
         0 < t && u.show(t, u.page)
      }), n && [].forEach.call(n, function (e) {
         e.addEventListener("change", function () {
            f(n, a, o), r && (r.checked = !1)
         })
      }), r && r.addEventListener("change", function () {
         [].forEach.call(n, function (e) {
            e.checked = r.checked
         }), f(n, a, o)
      }), l && l.addEventListener("click", function (e) {
         e.preventDefault(), r && (r.checked = !1), [].forEach.call(n, function (e) {
            e.checked = !1
         }), f(n, a, o)
      })
   }), "undefined" != typeof List && t && [].forEach.call(t, function (e) {
      e.addEventListener("click", function (e) {
         e.preventDefault()
      })
   })
});
