const { defineConfig } = require('cypress');

module.exports = defineConfig({
    e2e: {
        baseUrl: 'http://localhost:3000',
        specPattern: 'test/cypress/e2e/**/*.cy.{js,ts}',
        screenshotsFolder: "test/cypress/screenshots",
        videosFolder: "test/cypress/videos",
        supportFile: false,
        viewportWidth: 1600,
        viewportHeight: 900,
    },
});
