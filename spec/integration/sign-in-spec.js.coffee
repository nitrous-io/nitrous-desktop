describe 'Sign In (/sign-in)', ->
  t = null

  beforeEach ->
    t = visit('/sign-in')

  context 'when no text field is filled', ->
    it 'shows a disabled sign in button', (done) ->
      t.thenCheck done, ->
        expect(find '#sign-in-button').to.be.disabled

    context 'when username field is filled', ->
      beforeEach ->
        t.fillIn('#username-field', 'pete')

      it 'still shows a disabled sign in button', (done) ->
        t.thenCheck done, ->
          expect(find '#sign-in-button').to.be.disabled

      context 'when password field is filled', ->
        beforeEach ->
          t.fillIn('#password-field', 'foobar123')

        it 'enables the sign in button', (done) ->
          t.thenCheck done, ->
            expect(find '#sign-in-button').not.to.be.disabled

        context 'clicking the sign in button', ->
          doAction = ->
            find('#sign-in-button').click()

          context 'when sign in is successful', ->
            beforeEach ->
              server.respondWith 'POST', /\/oauth\/token\.json$/, [
                  200
                  { 'Content-Type': 'application/json; charset=utf-8' }
                  JSON.stringify
                    access_token: 'foobarbazqux'
                    resource_owner_id: 123
                    scope: 'public boxes public_keys push web user'
                    token_type: 'bearer'
                ]

            it 'redirects to main.index route', (done) ->
              t.thenCheck done, ->
                doAction()
                mainIndexRoute = spec.getRoute 'main.index'
                expect(spec.getCurrentRoute()).not.to.equal mainIndexRoute
                server.respond()
                expect(spec.getCurrentRoute()).to.equal mainIndexRoute

            it 'saves oauth token', (done) ->
              t.thenCheck done, ->
                expect(AIO.get 'accessToken').not.to.exist
                doAction()
                server.respond()
                expect(AIO.get 'accessToken.token').to.equal 'foobarbazqux'
                expect(AIO.AccessToken.loadFromStorage().get('token')).to.equal 'foobarbazqux'

          context 'when sign in fails', ->
            signInView = null

            beforeEach ->
              server.respondWith 'POST', /\/oauth\/token\.json$/, [
                  401
                  { 'Content-Type': 'application/json; charset=utf-8' }
                  JSON.stringify
                    error: 'invalid_resource_owner'
                    error_description: 'The provided resource owner credentials are not valid, or resource owner cannot be found'
                ]

              signInView = spec.getViewById('sign-in-view')
              sinon.stub signInView, 'shakeWindow'

            afterEach ->
              signInView.shakeWindow.restore()

            it 'shakes window', (done) ->
              t.thenCheck done, ->
                doAction()
                expect(signInView.shakeWindow).not.to.have.been.called
                server.respond()
                expect(signInView.shakeWindow).to.have.been.called
