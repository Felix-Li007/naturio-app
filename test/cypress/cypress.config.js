const { defineConfig } = require('cypress');

module.exports = defineConfig({
    e2e: {
        baseUrl: 'http://localhost:3000',
        specPattern: 'test/cypress/e2e/**/*.cy.{js,ts}',
        supportFile: false,
        viewportWidth: 1280,
        viewportHeight: 720,
    },
});
