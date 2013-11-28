localStorage = window.localStorage

describe 'App.localStorage', ->
  describe '.set', ->
    originalNamespace = null

    beforeEach ->
      originalNamespace = App.localStorage.namespace
      App.localStorage.namespace = 'app-localstorage-spec'

    afterEach ->
      App.localStorage.namespace = originalNamespace

    context 'when the given value is not null', ->
      it 'stores a json representation of a given object in local storage, with namespaced key', ->
        obj = { foo: "bar" }
        App.localStorage.set 'localStorageTest', obj
        expect(localStorage.getItem "app-localstorage-spec:localStorageTest").to.equal JSON.stringify(obj)

    context 'when the given value is null', ->
      it 'removes the object from local storage', ->
        App.localStorage.set 'localStorageTest', { foo: "bar" }
        App.localStorage.set 'localStorageTest', null
        expect(localStorage.getItem "app-localstorage-spec:localStorageTest").not.to.exist

    context 'when the given value is undefined', ->
      it 'removes the object from local storage', ->
        App.localStorage.set 'localStorageTest', { foo: "bar" }
        App.localStorage.set 'localStorageTest', undefined
        expect(localStorage.getItem "app-localstorage-spec:localStorageTest").not.to.exist

  describe '.get', ->
    it 'fetches an item previously stored with ".set"', ->
      App.localStorage.set 'foo', ['foo', 'bar']
      App.localStorage.set 'bar', 123
      App.localStorage.set 'baz', true

      expect(App.localStorage.get 'foo').to.deep.equal ['foo', 'bar']
      expect(App.localStorage.get 'bar').to.equal 123
      expect(App.localStorage.get 'baz').to.be.true

  describe '.clear', ->
    originalNamespace = null

    beforeEach ->
      originalNamespace = App.localStorage.namespace

    afterEach ->
      App.localStorage.namespace = originalNamespace

    it 'clears all items in the namespace', ->
      App.localStorage.set 'foo', '123'
      App.localStorage.set 'bar', '456'
      App.localStorage.namespace = 'app-local-storage-spec'
      App.localStorage.set 'baz', '777'
      App.localStorage.set 'qux', '888'
      expect(App.localStorage.get 'foo').not.to.exist
      expect(App.localStorage.get 'bar').not.to.exist
      expect(App.localStorage.get 'baz').to.equal '777'
      expect(App.localStorage.get 'qux').to.equal '888'
      App.localStorage.clear()
      expect(App.localStorage.get 'baz').not.to.exist
      expect(App.localStorage.get 'qux').not.to.exist
      App.localStorage.namespace = originalNamespace
      expect(App.localStorage.get 'foo').to.equal '123'
      expect(App.localStorage.get 'bar').to.equal '456'
      expect(App.localStorage.get 'baz').not.to.exist
      expect(App.localStorage.get 'qux').not.to.exist
