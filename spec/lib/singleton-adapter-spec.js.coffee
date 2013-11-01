describe 'AIO.SingletonAdapter', ->
  describedClass = AIO.SingletonAdapter
  subject = null

  beforeEach ->
    subject = describedClass.create()

  it 'is a subclass of AIO.OAuthRESTAdapter', ->
    expect(subject).to.be.instanceOf AIO.OAuthRESTAdapter

  describe '#buildURL', ->
    it 'returns a url with no id regardless of whether id is given', ->
      expect(subject.buildURL(url: 'https://www.example.com/boxes')).to.equal 'https://www.example.com/boxes.json'
      expect(subject.buildURL(url: 'https://www.example.com/boxes', null)).to.equal 'https://www.example.com/boxes.json'
      expect(subject.buildURL(url: 'https://www.example.com/boxes', 1)).to.equal 'https://www.example.com/boxes.json'
