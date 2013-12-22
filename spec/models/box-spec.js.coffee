describe 'App.Box', ->
  describedClass = App.Box
  box = null

  it 'is a subclass of App.BaseModel', ->
    expect(describedClass.prototype).to.be.an.instanceOf App.BaseModel

  beforeEach ->
    box = describedClass.create id: 123, host: 'box.example.com', port: 12345

  describe 'box control actions', ->
    beforeEach ->
      sinon.stub box, 'makeRequest'

    describe '#start', ->
      it 'does POST start', ->
        box.start()
        expect(box.makeRequest).to.have.been.calledWith 'start', 'POST'

    describe '#stop', ->
      it 'does POST stop', ->
        box.stop()
        expect(box.makeRequest).to.have.been.calledWith 'stop', 'POST'

    describe '#restart', ->
      it 'does POST restart', ->
        box.restart()
        expect(box.makeRequest).to.have.been.calledWith 'restart', 'POST'

  describe '#forwardedPorts', ->
    forwardedPorts = null

    beforeEach ->
      forwardedPorts = App.ForwardedPorts.forBox(box)

    it 'returns App.ForwardedPorts object for the box', ->
      expect(box.get 'forwardedPorts').to.equal forwardedPorts

  describe '#fileSync', ->
    fileSync = null

    beforeEach ->
      fileSync = App.FileSync.forBox(box)

    it 'returns App.FileSync object for the box', ->
      expect(box.get 'fileSync').to.equal fileSync

  describe 'computed properties', ->
    describe 'sshURI', ->
      it 'returns SSH URI', ->
        expect(box.get 'sshURI').to.equal 'ssh://action@box.example.com:12345'
