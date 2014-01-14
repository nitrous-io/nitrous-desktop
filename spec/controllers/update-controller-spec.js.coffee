describe 'App.UpdateController', ->
  describedClass = App.UpdateController
  controller = originalVersion = null

  beforeEach ->
    controller = spec.getController 'update'
    controller.setProperties
      checking: false
      checkFailed: false
      updating: false
      newVersion: null
      newVersionURL: null
      newVersionFileSize: 0
    originalVersion = App.get 'config.appVersion'
    App.set 'config.appVersion', '1.2.3'

  afterEach ->
    App.set 'config.appVersion', originalVersion

  describe '#check', ->
    beforeEach ->
      sinon.stub controller, 'presentUpdateModalDialog'

    afterEach ->
      controller.presentUpdateModalDialog.restore()

    context 'when fetching appcast fails', ->
      beforeEach ->
        server.respondWith 'GET', /\/mac\/appcast\.xml$/, [
          500
          { 'Content-Type': 'text/plain' }
          'Server Error'
        ]

      it 'sets failed to be true, and does not present update dialog', ->
        expect(controller.get 'checking').to.be.false
        controller.check()
        expect(controller.get 'checking').to.be.true
        expect(controller.get 'checkFailed').to.be.false
        server.respond()
        expect(controller.get 'checking').to.be.false
        expect(controller.get 'checkFailed').to.be.true
        expect(controller.get 'newVersion').not.to.exist
        expect(controller.get 'newVersionURL').not.to.exist
        expect(controller.get 'newVersionFileSize').to.equal 0
        expect(controller.presentUpdateModalDialog).not.to.have.been.called

    context 'when fetching appcast succeeds', ->
      context "when the latest app version in the app cast file is lower than the installed app's version", ->
        beforeEach ->
          server.respondWith 'GET', /\/mac\/appcast\.xml$/, [
            200
            { 'Content-Type': 'application/xml' }
            '''
              <?xml version="1.0" encoding="UTF-8"?>
              <rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
                <channel>
                  <item>
                    <enclosure url="https://example.com/1.2.2.zip" sparkle:version="1.2.2" length="26000122" />
                  </item>
                  <item>
                    <enclosure url="https://example.com/1.2.1.zip" sparkle:version="1.2.1" length="26000121" />
                  </item>
                  <item>
                    <enclosure url="https://example.com/1.2.0.zip" sparkle:version="1.2.0" length="26000120" />
                  </item>
                </channel>
              </rss>
            '''
          ]

        it 'does not set new version details', ->
          expect(controller.get 'checking').to.be.false
          controller.check()
          expect(controller.get 'checking').to.be.true
          expect(controller.get 'checkFailed').to.be.false
          server.respond()
          expect(controller.get 'checking').to.be.false
          expect(controller.get 'checkFailed').to.be.false
          expect(controller.get 'newVersion').not.to.exist
          expect(controller.get 'newVersionURL').not.to.exist
          expect(controller.get 'newVersionFileSize').to.equal 0
          expect(controller.presentUpdateModalDialog).not.to.have.been.called

      context "when the latest app version in the app cast file is equal to the installed app's version", ->
        beforeEach ->
          server.respondWith 'GET', /\/mac\/appcast\.xml$/, [
            200
            { 'Content-Type': 'application/xml' }
            '''
              <?xml version="1.0" encoding="UTF-8"?>
              <rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
                <channel>
                  <item>
                    <enclosure url="https://example.com/1.2.3.zip" sparkle:version="1.2.3" length="26000123" />
                  </item>
                  <item>
                    <enclosure url="https://example.com/1.2.2.zip" sparkle:version="1.2.2" length="26000122" />
                  </item>
                  <item>
                    <enclosure url="https://example.com/1.2.1.zip" sparkle:version="1.2.1" length="26000121" />
                  </item>
                </channel>
              </rss>
            '''
          ]

        it 'does not set new version details', ->
          expect(controller.get 'checking').to.be.false
          controller.check()
          expect(controller.get 'checking').to.be.true
          expect(controller.get 'checkFailed').to.be.false
          server.respond()
          expect(controller.get 'checking').to.be.false
          expect(controller.get 'checkFailed').to.be.false
          expect(controller.get 'newVersion').not.to.exist
          expect(controller.get 'newVersionURL').not.to.exist
          expect(controller.get 'newVersionFileSize').to.equal 0
          expect(controller.presentUpdateModalDialog).not.to.have.been.called

      context "when the latest app version in the app cast file is higher than the installed app's version", ->
        beforeEach ->
          server.respondWith 'GET', /\/mac\/appcast\.xml$/, [
            200
            { 'Content-Type': 'application/xml' }
            '''
              <?xml version="1.0" encoding="UTF-8"?>
              <rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
                <channel>
                  <item>
                    <enclosure url="https://example.com/1.2.4.zip" sparkle:version="1.2.4" length="26000124" />
                  </item>
                  <item>
                    <enclosure url="https://example.com/1.2.3.zip" sparkle:version="1.2.3" length="26000123" />
                  </item>
                  <item>
                    <enclosure url="https://example.com/1.2.2.zip" sparkle:version="1.2.2" length="26000122" />
                  </item>
                </channel>
              </rss>
            '''
          ]

        it 'sets new version details and presents update dialog', ->
          expect(controller.get 'checking').to.be.false
          controller.check()
          expect(controller.get 'checking').to.be.true
          expect(controller.get 'checkFailed').to.be.false
          server.respond()
          expect(controller.get 'checking').to.be.false
          expect(controller.get 'checkFailed').to.be.false
          expect(controller.get 'newVersion').to.equal '1.2.4'
          expect(controller.get 'newVersionURL').to.equal 'https://example.com/1.2.4.zip'
          expect(controller.get 'newVersionFileSize').to.equal 26000124
          expect(controller.presentUpdateModalDialog).to.have.been.called

  describe '.compareVersion', ->
    context 'when a > b', ->
      it 'returns 1', ->
        expect(describedClass.compareVersion '1.0.0', '0.9.9').to.equal 1
        expect(describedClass.compareVersion '1.5.0', '1.4.0').to.equal 1
        expect(describedClass.compareVersion '2.0.0', '1.10.0').to.equal 1
        expect(describedClass.compareVersion '1.2.3', '1.2.2').to.equal 1
        expect(describedClass.compareVersion '1.2.1b', '1.2.1').to.equal 1

    context 'when a == b', ->
      it 'returns 0', ->
        expect(describedClass.compareVersion '0.9.9', '0.9.9').to.equal 0
        expect(describedClass.compareVersion '1.4.0', '1.4.0').to.equal 0
        expect(describedClass.compareVersion '1.10.0', '1.10.0').to.equal 0
        expect(describedClass.compareVersion '1.2.2', '1.2.2').to.equal 0
        expect(describedClass.compareVersion '1.2.1', '1.2.1').to.equal 0

    context 'when a < b', ->
      it 'returns -1', ->
        expect(describedClass.compareVersion '0.9.9', '1.0.0').to.equal -1
        expect(describedClass.compareVersion '1.4.0', '1.5.0').to.equal -1
        expect(describedClass.compareVersion '1.10.0', '2.0.0').to.equal -1
        expect(describedClass.compareVersion '1.2.2', '1.2.3').to.equal -1
        expect(describedClass.compareVersion '1.2.1', '1.2.1b').to.equal -1
