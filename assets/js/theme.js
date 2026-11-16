/* Theme preference is optional; the content and navigation work without JS. */
(function () {
  "use strict";
  var root = document.documentElement;
  var preference = "system";
  var choices = ["system", "light", "dark"];
  var system = window.matchMedia("(prefers-color-scheme: dark)");
  try {
    var stored = window.localStorage.getItem("theme");
    if (choices.indexOf(stored) !== -1) preference = stored;
  } catch (error) {
    // Private browsing or policy may make storage unavailable.
  }
  function apply() {
    var actual = preference === "system" ? (system.matches ? "dark" : "light") : preference;
    root.setAttribute("data-theme", actual);
    var button = document.getElementById("theme-toggle");
    if (button) {
      var next = choices[(choices.indexOf(preference) + 1) % choices.length];
      button.hidden = false;
      button.textContent = "Theme: " + preference;
      button.setAttribute("aria-label", "Theme: " + preference + ". Switch to " + next + " theme");
    }
  }
  apply();
  document.addEventListener("DOMContentLoaded", function () {
    var button = document.getElementById("theme-toggle");
    if (!button) return;
    apply();
    button.addEventListener("click", function () {
      preference = choices[(choices.indexOf(preference) + 1) % choices.length];
      try { window.localStorage.setItem("theme", preference); } catch (error) { /* Optional. */ }
      apply();
    });
  });
  if (system.addEventListener) system.addEventListener("change", apply);
}());
