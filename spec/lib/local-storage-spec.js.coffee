localStorage = window.localStorage

describe 'AIO.localStorage', ->
  describe '.set', ->
    originalNamespace = null

    beforeEach ->
      originalNamespace = AIO.localStorage.namespace
      AIO.localStorage.namespace = 'aio-localstorage-spec'

    afterEach ->
      AIO.localStorage.namespace = originalNamespace

    context 'when the given value is not null', ->
      it 'stores a json representation of a given object in local storage, with namespaced key', ->
        obj = { foo: "bar" }
        AIO.localStorage.set 'localStorageTest', obj
        expect(localStorage.getItem "aio-localstorage-spec:localStorageTest").to.equal JSON.stringify(obj)

    context 'when the given value is null', ->
      it 'removes the object from local storage', ->
        AIO.localStorage.set 'localStorageTest', { foo: "bar" }
        AIO.localStorage.set 'localStorageTest', null
        expect(localStorage.getItem "aio-localstorage-spec:localStorageTest").not.to.exist

    context 'when the given value is undefined', ->
      it 'removes the object from local storage', ->
        AIO.localStorage.set 'localStorageTest', { foo: "bar" }
        AIO.localStorage.set 'localStorageTest', undefined
        expect(localStorage.getItem "aio-localstorage-spec:localStorageTest").not.to.exist

  describe '.get', ->
    it 'fetches an item previously stored with ".set"', ->
      AIO.localStorage.set 'foo', ['foo', 'bar']
      AIO.localStorage.set 'bar', 123
      AIO.localStorage.set 'baz', true

      expect(AIO.localStorage.get 'foo').to.deep.equal ['foo', 'bar']
      expect(AIO.localStorage.get 'bar').to.equal 123
      expect(AIO.localStorage.get 'baz').to.be.true

  describe '.clear', ->
    originalNamespace = null

    beforeEach ->
      originalNamespace = AIO.localStorage.namespace

    afterEach ->
      AIO.localStorage.namespace = originalNamespace

    it 'clears all items in the namespace', ->
      AIO.localStorage.set 'foo', '123'
      AIO.localStorage.set 'bar', '456'
      AIO.localStorage.namespace = 'aio-local-storage-spec'
      AIO.localStorage.set 'baz', '777'
      AIO.localStorage.set 'qux', '888'
      expect(AIO.localStorage.get 'foo').not.to.exist
      expect(AIO.localStorage.get 'bar').not.to.exist
      expect(AIO.localStorage.get 'baz').to.equal '777'
      expect(AIO.localStorage.get 'qux').to.equal '888'
      AIO.localStorage.clear()
      expect(AIO.localStorage.get 'baz').not.to.exist
      expect(AIO.localStorage.get 'qux').not.to.exist
      AIO.localStorage.namespace = originalNamespace
      expect(AIO.localStorage.get 'foo').to.equal '123'
      expect(AIO.localStorage.get 'bar').to.equal '456'
      expect(AIO.localStorage.get 'baz').not.to.exist
      expect(AIO.localStorage.get 'qux').not.to.exist
