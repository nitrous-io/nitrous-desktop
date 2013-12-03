describe 'App.MainController', ->
  mainController = null

  beforeEach ->
    mainController = spec.getController 'main'

  describe '#connectToShover', ->
    beforeEach ->
      AIO.authToken.authTokenServerURI = null
      AIO.authToken.requestHeaders = null

      accessToken = App.AccessToken.create(accessToken: 'foobarbazqux', scope: App.AccessToken.scope, resource_owner_id: 123)
      App.set 'accessToken', accessToken

      AIO.ShoverSocket() # load class
      sinon.stub AIO.ShoverSocket.prototype, 'connect'
      mainController.connectToShover()

    afterEach ->
      AIO.ShoverSocket::connect.restore()

    it 'sets authTokenServerURI and requestHeaders properties of AIO.authToken', ->
      expect(AIO.authToken.authTokenServerURI).to.equal App.get('config.apiURI')
      expect(AIO.authToken.requestHeaders).to.deep.equal { Authorization: 'Bearer foobarbazqux' }

    it 'connects to shover', ->
      expect(mainController.get('shoverSocket').connect).to.have.been.called

    describe 'shover socket event handlers', ->
      socket = null

      beforeEach ->
        socket = new EventEmitter2()
        mainController.get('shoverSocket').setupHandlers(socket)

      context 'aio:box_updated', ->
        beforeEach ->
          App.Box.load [{ id: 1, name: 'my-rails-box', state: 'running', memory: 256 }]
          socket.emit 'aio:box_updated', box: { id: 1, name: 'my-rails-box', state: 'stopping', memory: 512 }

        it 'updates the box object', ->
          box = App.Box.find(1)
          expect(box.get 'state').to.equal 'stopping'
          expect(box.get 'memory').to.equal 512
