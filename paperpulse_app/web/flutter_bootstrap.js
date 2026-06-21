{{flutter_js}}
{{flutter_build_config}}

(async function () {
  const loading = document.getElementById('loading');

  await _flutter.loader.load({
    onEntrypointLoaded: async function (engineInitializer) {
      const appRunner = await engineInitializer.initializeEngine();

      // Fade out the loading screen just before the first Flutter frame
      if (loading) {
        loading.classList.add('hidden');
        // Remove from layout after transition so Flutter canvas sits flush
        setTimeout(() => loading.remove(), 450);
      }

      await appRunner.runApp();
    },
  });
})();
