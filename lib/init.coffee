VirtualenvView = require './virtualenv-view'
VirtualenvListView = require './virtualenv-list-view'
VirtualenvManger = require './virtualenv-manager'
MakeDialog = require './virtualenv-dialog'

module.exports =
  manager: new VirtualenvManger()

  configDefaults:
    workonHome: 'autodetect'

  activate: (state) ->

    cmd = 'select-virtualenv:'
    @manager.on 'options', (options) ->
      items = ({label: i.name, command: cmd + i.name} for i in options)
      items = [{type: 'separator'}].concat(items)
      atom.menu.add [
        {
          label: 'Packages'
          submenu: [
            {
              label: 'Virtualenv'
              submenu: items
            }
          ]
        }
      ]

    atom.packages.once 'activated', =>
      atom.workspaceView.command 'virtualenv:make', =>
        (new MakeDialog(@manager)).attach()

      atom.workspaceView.command 'virtualenv:select', =>
        @manager.emit('selector:show')

      atom.workspaceView.command 'virtualenv:deactivate', =>
        @manager.deactivate()

      statusBar = atom.workspaceView.statusBar
      if statusBar?
        @virtualenv = new VirtualenvView(statusBar, @manager)
        statusBar.prependLeft(@virtualenv)

      @manager.on 'selector:show', =>
        view = new VirtualenvListView(@manager)
        view.attach()
