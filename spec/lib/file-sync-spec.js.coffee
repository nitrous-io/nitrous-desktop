describe 'App.FileSync', ->
  describedClass = App.FileSync

  beforeEach ->
    describedClass._cache = {}

  it 'makes "create" method private to enforce the use of #forBox factory method', ->
    expect(describedClass.create).not.to.exist
    expect(describedClass._create()).to.be.an.instanceOf describedClass

  context 'when enabled property is changed', ->
    subject = null

    beforeEach ->
      sinon.stub describedClass.prototype, '_startOrStopWatching'
      subject = describedClass._create box: Em.Object.create(id:123)

    afterEach ->
      describedClass::_startOrStopWatching.restore()

    it 'saves obj to local storage', ->
      subject.set 'enabled', true
      expect(App.localStorage.get 'box:123:fileSync').to.deep.equal { enabled: true }
      subject.set 'enabled', false
      expect(App.localStorage.get 'box:123:fileSync').to.deep.equal { enabled: false }

  describe '.forBox', ->
    beforeEach ->
      sinon.stub describedClass.prototype, '_startOrStopWatching'

    afterEach ->
      describedClass::_startOrStopWatching.restore()

    context 'when it does not exist in the local storage', ->
      it 'creates a new instance of App.FileSync', ->
        mockBox = Em.Object.create id: 9999, name: 'rails-box', host: 'rails-box.example.com', port: 12345
        obj = describedClass.forBox(mockBox)
        expect(obj).to.be.an.instanceOf App.FileSync
        expect(obj.get 'box').to.equal mockBox
        expect(obj.get 'enabled').to.be.false

    context 'when it exists in the local storage', ->
      beforeEach ->
        App.localStorage.set 'box:111:fileSync', { enabled: true }

      it 'loads it', ->
        mockBox = Em.Object.create id: 111, name: 'node-box', host: 'node-box.example.com', port: 22345
        obj = describedClass.forBox(mockBox)
        expect(obj).to.be.an.instanceOf App.FileSync
        expect(obj.get 'box').to.equal mockBox
        expect(obj.get 'enabled').to.be.true

    context 'when it is already loaded', ->
      beforeEach ->
        App.localStorage.set 'box:222:fileSync', { enabled: true }

      it 'loads the cached object', ->
        mockBox = Em.Object.create id: 222, name: 'django-box', host: 'django-box.example.com', port: 32768
        obj = describedClass.forBox(mockBox)
        expect(obj).to.be.an.instanceOf App.FileSync
        expect(obj.get 'box').to.equal mockBox
        expect(obj.get 'enabled').to.be.true
        obj2 = describedClass.forBox(mockBox)
        expect(obj).to.equal obj2
