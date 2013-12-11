describe 'App.Box', ->
  describedClass = App.Box
  box = null

  it 'is a subclass of App.BaseModel', ->
    expect(describedClass.prototype).to.be.an.instanceOf App.BaseModel

  beforeEach ->
    box = describedClass.create id: 123

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
      forwardedPorts = App.ForwardedPorts.forBoxId(123)

    it 'returns ForwardedPorts object for the box', ->
      expect(box.get 'forwardedPorts').to.equal forwardedPorts
