// The mobile menu toggle, and the highlight of the section the visitor is in.
(function () {
  var toggle = document.getElementById('toggle-menu');
  var menu = document.getElementById('navbar');
  if (toggle && menu) {
    toggle.addEventListener('click', function (e) {
      e.preventDefault();
      var open = menu.classList.toggle('hidden') === false;
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
  }

  // /cs/docs/templates/ belongs to the menu entry /docs/: ignore the language prefix.
  var path = location.pathname.replace(/^\/[a-z]{2}(-[A-Za-z]{2})?(?=\/)/, '') || '/';
  document.querySelectorAll('[data-nav]').forEach(function (a) {
    var link = a.getAttribute('data-nav');
    var here = link === '/' ? path === '/' : path.indexOf(link) === 0;
    if (here) { a.classList.add('is-active'); }
  });
})();
