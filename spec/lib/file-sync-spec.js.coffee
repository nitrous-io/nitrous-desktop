describe 'App.FileSync', ->
  describedClass = App.FileSync

  beforeEach ->
    describedClass._cache = {}

  it 'makes "create" method private to enforce the use of #forBoxId factory method', ->
    expect(describedClass.create).not.to.exist
    expect(describedClass._create()).to.be.an.instanceOf describedClass

  describe '#save', ->
    subject = null

    beforeEach ->
      sinon.stub describedClass.prototype, 'enabledDidChange'
      subject = describedClass._create(boxId: 123)

    it 'saves obj to local storage', ->
      subject.set 'enabled', true
      subject.save()
      expect(App.localStorage.get 'box:123:fileSync').to.deep.equal { enabled: true }
      subject.set 'enabled', false
      subject.save()
      expect(App.localStorage.get 'box:123:fileSync').to.deep.equal { enabled: false }

  describe '.forBoxId', ->
    context 'when it does not exist in the local storage', ->
      it 'creates a new instance of App.FileSync', ->
        obj = describedClass.forBoxId(9999)
        expect(obj).to.be.an.instanceOf App.FileSync
        expect(obj.get 'boxId').to.equal 9999
        expect(obj.get 'enabled').to.be.false

    context 'when it exists in the local storage', ->
      beforeEach ->
        App.localStorage.set 'box:111:fileSync', { enabled: true }

      it 'loads it', ->
        obj = describedClass.forBoxId(111)
        expect(obj).to.be.an.instanceOf App.FileSync
        expect(obj.get 'boxId').to.equal 111
        expect(obj.get 'enabled').to.be.true

    context 'when it is already loaded', ->
      beforeEach ->
        App.localStorage.set 'box:222:fileSync', { enabled: true }

      it 'loads the cached object', ->
        obj = describedClass.forBoxId(222)
        expect(obj).to.be.an.instanceOf App.FileSync
        expect(obj.get 'boxId').to.equal 222
        expect(obj.get 'enabled').to.be.true
        obj2 = describedClass.forBoxId(222)
        expect(obj).to.equal obj2
