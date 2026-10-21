(() => {
  let rendered = false;
  const message = document.getElementById('startup-message');
  const retry = document.getElementById('startup-retry');
  function showFailure() {
    if (rendered) return;
    document.getElementById('startup').hidden = false;
    message.textContent = "Le chargement n'a pas abouti. Verifiez votre connexion puis reessayez.";
    retry.hidden = false;
  }
  const timeout = setTimeout(showFailure, 45000);
  retry.addEventListener('click', () => window.location.reload());
  window.addEventListener('flutter-first-frame', () => {
    rendered = true;
    clearTimeout(timeout);
    document.getElementById('startup')?.remove();
  }, { once: true });
  window.addEventListener('error', showFailure);
  window.addEventListener('unhandledrejection', showFailure);
})();
