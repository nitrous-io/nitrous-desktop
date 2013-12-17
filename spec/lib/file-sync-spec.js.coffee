describe 'App.FileSync', ->
  describedClass = App.FileSync

  beforeEach ->
    describedClass._cache = {}

  it 'makes "create" method private to enforce the use of #forBox factory method', ->
    expect(describedClass.create).not.to.exist
    expect(describedClass._create()).to.be.an.instanceOf describedClass

  describe '#save', ->
    subject = null

    beforeEach ->
      sinon.stub describedClass.prototype, 'enabledDidChange'
      subject = describedClass._create(boxId: 123)

    afterEach ->
      describedClass::enabledDidChange.restore()

    it 'saves obj to local storage', ->
      subject.set 'enabled', true
      subject.save()
      expect(App.localStorage.get 'box:123:fileSync').to.deep.equal { enabled: true }
      subject.set 'enabled', false
      subject.save()
      expect(App.localStorage.get 'box:123:fileSync').to.deep.equal { enabled: false }

  describe '.forBox', ->
    beforeEach ->
      sinon.stub describedClass.prototype, 'enabledDidChange'

    afterEach ->
      describedClass::enabledDidChange.restore()

    context 'when it does not exist in the local storage', ->
      it 'creates a new instance of App.FileSync', ->
        obj = describedClass.forBox(Em.Object.create id: 9999, name: 'rails-box', host: 'rails-box.example.com', port: 12345)
        expect(obj).to.be.an.instanceOf App.FileSync
        expect(obj.get 'boxId').to.equal 9999
        expect(obj.get 'boxName').to.equal 'rails-box'
        expect(obj.get 'syncURI').to.equal 'ssh://action@rails-box.example.com:12345/workspace'
        expect(obj.get 'enabled').to.be.false

    context 'when it exists in the local storage', ->
      beforeEach ->
        App.localStorage.set 'box:111:fileSync', { enabled: true }

      it 'loads it', ->
        obj = describedClass.forBox(Em.Object.create id: 111, name: 'node-box', host: 'node-box.example.com', port: 22345)
        expect(obj).to.be.an.instanceOf App.FileSync
        expect(obj.get 'boxId').to.equal 111
        expect(obj.get 'boxName').to.equal 'node-box'
        expect(obj.get 'syncURI').to.equal 'ssh://action@node-box.example.com:22345/workspace'
        expect(obj.get 'enabled').to.be.true

    context 'when it is already loaded', ->
      beforeEach ->
        App.localStorage.set 'box:222:fileSync', { enabled: true }

      it 'loads the cached object', ->
        obj = describedClass.forBox(Em.Object.create id: 222, name: 'django-box', host: 'django-box.example.com', port: 32768)
        expect(obj).to.be.an.instanceOf App.FileSync
        expect(obj.get 'boxId').to.equal 222
        expect(obj.get 'boxName').to.equal 'django-box'
        expect(obj.get 'syncURI').to.equal 'ssh://action@django-box.example.com:32768/workspace'
        expect(obj.get 'enabled').to.be.true
        obj2 = describedClass.forBox(Em.Object.create id: 222, name: 'django-box')
        expect(obj).to.equal obj2
