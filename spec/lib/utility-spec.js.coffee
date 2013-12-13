os = require 'os'
childProcess = require 'child_process'

describe 'App.utility', ->
  subject = App.utility

  describe '.isWindowsXP', ->
    context 'when os.type() == Darwin', ->
      beforeEach ->
        sinon.stub(os, 'type').returns 'Darwin'

      afterEach ->
        os.type.restore()

      it 'returns false', ->
        expect(subject.isWindowsXP()).to.be.false

    context 'when os.type() == Linux', ->
      beforeEach ->
        sinon.stub(os, 'type').returns 'Linux'

      afterEach ->
        os.type.restore()

      it 'returns false', ->
        expect(subject.isWindowsXP()).to.be.false

    context 'when os.type() == Windows_NT', ->
      beforeEach ->
        sinon.stub(os, 'type').returns 'Windows_NT'

      afterEach ->
        os.type.restore()

      context 'when os.release() >= 6.0', ->
        beforeEach ->
          sinon.stub(os, 'release').returns '6.0.6000'

        afterEach ->
          os.release.restore()

        it 'returns false', ->
          expect(subject.isWindowsXP()).to.be.false

      context 'when os.release() is 5.1.x', ->
        beforeEach ->
          sinon.stub(os, 'release').returns '5.1.2600'

        afterEach ->
          os.release.restore()

        it 'returns true', ->
          expect(subject.isWindowsXP()).to.be.true

      context 'when os.release() is 5.2.x', ->
        beforeEach ->
          sinon.stub(os, 'release').returns '5.2.3790'

        afterEach ->
          os.release.restore()

        it 'returns true', ->
          expect(subject.isWindowsXP()).to.be.true

  describe '.findHomeFolder', ->
    context 'when process.env.HOME is defined (mac, linux)', ->

      beforeEach ->
        process.env.ORIGINAL_HOME = process.env.HOME
        process.env.HOME = '/Users/example'

      afterEach ->
        process.env.HOME = process.env.ORIGINAL_HOME

      it 'returns process.env.HOME', (done) ->
        subject.findHomeFolder (path) ->
          expect(path).to.equal '/Users/example'
          done()

    context 'when process.env.HOME is not defined, but process.env.USERPROFILE is defined (windows)', ->
      beforeEach ->
        process.env.ORIGINAL_HOME = process.env.HOME
        delete process.env.HOME
        process.env.ORIGINAL_USERPROFILE = process.env.USERPROFILE
        process.env.USERPROFILE = 'C:\\Users\\example'

      afterEach ->
        process.env.HOME = process.env.ORIGINAL_HOME
        process.env.USERPROFILE = process.env.ORIGINAL_USERPROFILE

      context 'when OS is not Windows XP', ->
        beforeEach ->
          sinon.stub(subject, 'isWindowsXP').returns false

        afterEach ->
          subject.isWindowsXP.restore()

        it 'returns process.env.USERPROFILE', (done) ->
          subject.findHomeFolder (path) ->
            expect(path).to.equal 'C:\\Users\\example'
            done()

      context 'when OS is Windows XP', ->
        beforeEach ->
          sinon.stub(subject, 'isWindowsXP').returns true
          sinon.stub(childProcess, 'execFile').withArgs(
            'reg.exe',
            ['QUERY', 'HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders', '/v', 'Personal']
          ).yields null, '''
            \r
            ! REG.EXE VERSION 3.0\r
            \r
            HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\r
                Personal\tREG_SZ\tC:\\Documents and Settings\\Administrator\\My Documents\r
            \r
          ''', null

        afterEach ->
          subject.isWindowsXP.restore()
          childProcess.execFile.restore()

        it 'finds and returns My Documents folder', (done) ->
          subject.findHomeFolder (path) ->
            expect(path).to.equal 'C:\\Documents and Settings\\Administrator\\My Documents'
            done()
