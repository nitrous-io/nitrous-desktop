describe 'App.ForwardedPorts', ->
  describedClass = App.ForwardedPorts

  beforeEach ->
    describedClass._cache = {}

  it 'is an array proxy', ->
    expect(describedClass.prototype).to.be.an.instanceOf Em.ArrayProxy

  it 'makes "create" method private to enforce the use of #forBox factory method', ->
    expect(describedClass.create).not.to.exist
    expect(describedClass._create()).to.be.an.instanceOf describedClass

  it 'is sorted', ->
    subject = describedClass._create box: Em.Object.create(id: 123)
    subject.pushObject(port1 = App.ForwardedPort.create port: 2222)
    subject.pushObject(port2 = App.ForwardedPort.create port: 1234)
    subject.pushObject(port3 = App.ForwardedPort.create port: 4858)
    subject.pushObject(port4 = App.ForwardedPort.create port: 15211)
    subject.pushObject(port5 = App.ForwardedPort.create port: 3214)
    window.subject = subject
    expect(subject.get 'length').to.equal 5
    expect(subject.get('arrangedContent').map (p) -> p.get 'port').to.deep.equal [1234, 2222, 3214, 4858, 15211]

  context 'when list of ports added changes', ->
    it 'saves the list to local storage', ->
      subject = describedClass._create box: Em.Object.create(id: 123)
      subject.pushObject(App.ForwardedPort.create port: 3000)
      subject.pushObject(App.ForwardedPort.create port: 3500)
      expect(App.localStorage.get('box:123:forwardedPorts').ports).to.deep.equal [3000, 3500]
      subject.pushObject(App.ForwardedPort.create port: 4000)
      subject.pushObject(App.ForwardedPort.create port: 5000)
      expect(App.localStorage.get('box:123:forwardedPorts').ports).to.deep.equal [3000, 3500, 4000, 5000]

  context 'when enabled property is changed', ->
    it 'saves the value to local storage', ->
      subject = describedClass._create box: Em.Object.create(id:123)
      subject.set 'enabled', true
      expect(App.localStorage.get('box:123:forwardedPorts').enabled).to.be.true
      subject.set 'enabled', false
      expect(App.localStorage.get('box:123:forwardedPorts').enabled).to.be.false

  describe '.forBox', ->
    context 'when it does not exist in the local storage', ->
      it 'creates a new instance of App.ForwardedPorts', ->
        mockBox = Em.Object.create id: 9999
        obj = describedClass.forBox(mockBox)
        expect(obj).to.be.an.instanceOf App.ForwardedPorts
        expect(obj.get 'box').to.equal mockBox
        expect(obj.get 'content').to.deep.equal []

    context 'when it exists in the local storage', ->
      beforeEach ->
        App.localStorage.set 'box:111:forwardedPorts', { ports: [3100, 3200, 4000], enabled: true }

      it 'loads it', ->
        mockBox = Em.Object.create id: 111
        obj = describedClass.forBox(mockBox)
        expect(obj).to.be.an.instanceOf App.ForwardedPorts
        expect(obj.get 'box').to.equal mockBox
        expect(obj.get 'enabled').to.be.true
        expect(obj.get 'length').to.equal 3
        expect(obj.get 'content.0').to.be.an.instanceOf App.ForwardedPort
        expect(obj.get 'content.1').to.be.an.instanceOf App.ForwardedPort
        expect(obj.get 'content.2').to.be.an.instanceOf App.ForwardedPort
        expect(obj.get 'content.0.port').to.equal 3100
        expect(obj.get 'content.1.port').to.equal 3200
        expect(obj.get 'content.2.port').to.equal 4000

    context 'when it is already loaded', ->
      beforeEach ->
        App.localStorage.set 'box:222:forwardedPorts', { ports: [3000, 3200, 4300], enabled: false }

      it 'loads the cached object', ->
        mockBox = Em.Object.create id: 222
        obj = describedClass.forBox(mockBox)
        expect(obj).to.be.an.instanceOf App.ForwardedPorts
        expect(obj.get 'box').to.equal mockBox
        expect(obj.get 'enabled').to.be.false
        expect(obj.get 'length').to.equal 3
        expect(obj.get 'content.0').to.be.an.instanceOf App.ForwardedPort
        expect(obj.get 'content.1').to.be.an.instanceOf App.ForwardedPort
        expect(obj.get 'content.2').to.be.an.instanceOf App.ForwardedPort
        expect(obj.get 'content.0.port').to.equal 3000
        expect(obj.get 'content.1.port').to.equal 3200
        expect(obj.get 'content.2.port').to.equal 4300
        obj2 = describedClass.forBox(mockBox)
        expect(obj).to.equal obj2
