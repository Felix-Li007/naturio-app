// Feature 5.5
describe('Authentication - Sign Up and Login', () => {
    describe('Sign Up - Happy Path', () => {
        it('New user registration should be successful (Happy Path)', () => {
            cy.visit('/register')
            // Check page title
            cy.contains('Create Account').should('be.visible')

            // Fill out the form
            const uniqueUsername = `testuser_${Date.now()}`
            const testEmail = `test_${Date.now()}@example.com`
            const testPassword = 'TestPassword123!'

            cy.get('input[id*="username"]').type(uniqueUsername)
            cy.get('input[type="email"]').type(testEmail)
            cy.get('input[id*="password"]').first().type(testPassword)
            cy.get('input[id*="password_confirmation"]').type(testPassword)

            cy.get('input[value="Create Account"][type="submit"]').click()

            //Verify successful registration
            cy.url().should('not.include', '/register')
            cy.contains('Create Account').should('not.exist')
            cy.get('[role="alert"]').should('contain', 'successfully')
        })
    })

    describe('Sign Up - Unhappy Paths', () => {
        const uniqueUsername = `testuser_${Date.now()}`
        const testEmail = `test_${Date.now()}@example.com`
        const testPassword = 'TestPassword123!'
        beforeEach(() => {
            cy.visit('/register')
            cy.get('input[id*="username"]').type(uniqueUsername)
            cy.get('input[type="email"]').type(testEmail)
            cy.get('input[id*="password"]').first().type(testPassword)
            cy.get('input[id*="password_confirmation"]').type(testPassword)

            cy.get('input[value="Create Account"][type="submit"]').click()
            cy.clearCookies()

        })
        it('The username already exists should display an error (Unhappy Path)', () => {

            cy.visit('/register')
            // Use an existing username
            cy.get('input[id*="username"]').type(uniqueUsername)
            cy.get('input[type="email"]').type(`test_${Date.now()}@example.com`)
            cy.get('input[id*="password"]').first().type('Password123!')
            cy.get('input[id*="password_confirmation"]').type('Password123!')
            cy.get('input[value="Create Account"][type="submit"]').click()

            // An error message should be displayed
            cy.contains('div.alert.alert-danger', 'taken', { timeout: 10000 }).should('be.visible').and('contain', 'taken')
            cy.get('input[id*="username"]').should('have.class', 'is-invalid')
        })

        it('Password mismatch should display an error (Unhappy Path)', () => {
            cy.visit('/register')
            cy.get('input[id*="username"]').type(`newuser_${Date.now()}`)
            cy.get('input[type="email"]').type(`test_${Date.now()}@example.com`)
            cy.get('input[id*="password"]').first().type('Password123!')
            cy.get('input[id*="password_confirmation"]').type('DifferentPassword!')
            cy.get('input[value="Create Account"][type="submit"]').click()
            cy.get('[class="alert alert-danger"]', { timeout: 10000 }).should('be.visible').and('contain', 'doesn\'t match')

        })

        it('The email address is already in use and an error (Unhappy Path) should be displayed.', () => {
            // Use an existing email
            cy.visit('/register')
            cy.get('input[id*="username"]').type(`newuser_${Date.now()}`)
            cy.get('input[type="email"]').type(testEmail)
            cy.get('input[id*="password"]').first().type('Password123!')
            cy.get('input[id*="password_confirmation"]').type('Password123!')

            cy.get('input[value="Create Account"][type="submit"]').click()

            // It should show that the email address is already in use
            cy.get('[class="alert alert-danger"]', { timeout: 10000 }).should('be.visible').and('contain', 'taken')
            cy.get('input[type="email"]').should('have.class', 'is-invalid')
        })

        it('Missing required fields should display an error (Unhappy Path)', () => {
            cy.visit('/register')
            // Just fill in the username, nothing else
            cy.get('input[id*="username"]').type('testuser')

            // Try submitting an empty form
            cy.get('input[value="Create Account"][type="submit"]').click()

            // It should be on the registration page
            cy.url().should('include', '/register')
        })
    })


    describe('Login - Happy Path', () => {
        it('Should successfully log in with valid credentials (Happy Path)', () => {
            // First register a user
            const testUsername = `testuser_${Date.now()}`
            const testEmail = `test_${Date.now()}@example.com`
            const testPassword = 'TestPassword123!'

            //register
            cy.visit('/register')
            cy.get('input[id*="username"]').type(testUsername)
            cy.get('input[type="email"]').type(testEmail)
            cy.get('input[id*="password"]').first().type(testPassword)
            cy.get('input[id*="password_confirmation"]').type(testPassword)
            cy.get('input[value="Create Account"][type="submit"]').click()

            // Sign out
            cy.contains('Logout').click({ force: true }).then(() => {
                cy.visit('/')
            })

            //Log in
            cy.visit('/login')
            cy.contains('Welcome Back').should('be.visible')

            cy.get('input[type="email"]').type(testEmail)
            cy.get('input[type="password"]').type(testPassword)
            cy.get('input[value="Sign In"][type="submit"]').click()

            // Verify successful login
            cy.url().should('not.include', '/login')

            // Username should be displayed
            cy.get('div[class*="dropdown"]').within(() => {
                cy.contains(testUsername).should('be.visible')
            })
        })
    })

    describe('Login - Unhappy Paths', () => {
        beforeEach(() => {
            cy.visit('/login')
        });

        it('The wrong mailbox should show an error (Unhappy Path)', () => {
            cy.get('input[type="email"]').type('nonexistent@example.com')
            cy.get('input[type="password"]').type('anypassword')
            cy.get('input[value="Sign In"][type="submit"]').click()

            // An error message should be displayed
            cy.get('[class="alert alert-danger"]').should('be.visible').and('contain', 'Invalid')
        })

        it('Wrong password should show error (Unhappy Path)', () => {
            // Use existing user email but wrong password
            cy.get('input[type="email"]').type('test@example.com')
            cy.get('input[type="password"]').type('wrongpassword')
            cy.get('input[value="Sign In"][type="submit"]').click()


            // An invalid credentials error should be displayed
            cy.get('[class="alert alert-danger"]', { timeout: 10000 }).should('be.visible').and('contain', 'Invalid')
        })

        it('Empty forms should show validation errors (Unhappy Path)', () => {
            // Submit directly without filling in any content
            cy.get('input[value="Sign In"][type="submit"]').click()

            cy.url().should('include', '/login')
        })

        it('An incorrectly formatted email should display an error (Unhappy Path)', () => {
            cy.get('input[type="email"]').type('notanemail')
            cy.get('input[type="password"]').type('password')
            cy.get('input[value="Sign In"][type="submit"]').click()

            cy.url().should('include', '/login')
        })
    })
})
