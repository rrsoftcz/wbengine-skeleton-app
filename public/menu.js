const menu = document.getElementById('navbar');
const menuToggle = document.getElementById('toggle-menu');

menuToggle.addEventListener('click', (e) => {
  e.preventDefault();
  if (isHidden(menu)===false) {
    menu.style.display = 'none';
  } else  {
    menu.style.display = 'flex';
  }
});

function isHidden(el) {
  var style = window.getComputedStyle(el);
  return (style.display === 'none')
}