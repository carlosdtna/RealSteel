/* ============================================================
   RealSteel Landing Page — JavaScript
   IronCode Studio © 2025
   ============================================================ */

/**
 * Scroll Reveal — anima elementos al entrar en el viewport
 */
function initScrollReveal() {
  const reveals = document.querySelectorAll('.reveal');
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry, i) => {
      if (entry.isIntersecting) {
        setTimeout(() => entry.target.classList.add('visible'), i * 80);
      }
    });
  }, { threshold: 0.1 });
  reveals.forEach(el => observer.observe(el));
}

/**
 * Nav scroll effect — cambia el borde del nav al hacer scroll
 */
function initNavScroll() {
  const nav = document.querySelector('nav');
  window.addEventListener('scroll', () => {
    nav.style.borderBottomColor = window.scrollY > 50
      ? 'rgba(192,57,43,0.2)'
      : 'var(--border)';
  });
}

/**
 * Inicialización al cargar el DOM
 */
document.addEventListener('DOMContentLoaded', () => {
  initScrollReveal();
  initNavScroll();
});