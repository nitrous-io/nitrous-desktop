localStorage = window.localStorage

describe 'AIO.localStorage', ->
  beforeEach ->
    localStorage.clear()

  afterEach ->
    localStorage.clear()

  describe '.set', ->
    context 'when the given value is not null', ->
      it 'stores a json representation of a given object in local storage, with namespaced key', ->
        obj = { foo: "bar" }
        AIO.localStorage.set 'localStorageTest', obj
        expect(localStorage.getItem 'aio:localStorageTest').to.equal JSON.stringify(obj)

    context 'when the given value is null', ->
      it 'removes the object from local storage', ->
        AIO.localStorage.set 'localStorageTest', { foo: "bar" }
        expect(localStorage.length).to.equal 1
        AIO.localStorage.set 'localStorageTest', null
        expect(localStorage.length).to.equal 0

    context 'when the given value is undefined', ->
      it 'removes the object from local storage', ->
        AIO.localStorage.set 'localStorageTest', { foo: "bar" }
        expect(localStorage.length).to.equal 1
        AIO.localStorage.set 'localStorageTest', undefined
        expect(localStorage.length).to.equal 0

  describe '.get', ->
    it 'fetches an item previously stored with ".set"', ->
      AIO.localStorage.set 'foo', ['foo', 'bar']
      AIO.localStorage.set 'bar', 123
      AIO.localStorage.set 'baz', true

      expect(AIO.localStorage.get 'foo').to.deep.equal ['foo', 'bar']
      expect(AIO.localStorage.get 'bar').to.equal 123
      expect(AIO.localStorage.get 'baz').to.be.true
