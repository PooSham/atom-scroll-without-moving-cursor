ScrollWithoutMovingCursorView = require './scroll-without-moving-cursor-view'
{CompositeDisposable} = require 'atom'

module.exports = ScrollWithoutMovingCursor =
  scrollWithoutMovingCursorView: null
  modalPanel: null
  subscriptions: null
  editorElement: null

  activate: (state) ->
    @scrollWithoutMovingCursorView = new ScrollWithoutMovingCursorView(state.scrollWithoutMovingCursorViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @scrollWithoutMovingCursorView.getElement(), visible: false)
    @editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'scroll-without-moving-cursor:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'editor:scroll-up-without-moving-cursor': => @scrollUpLines()
    @subscriptions.add atom.commands.add 'atom-workspace', 'editor:scroll-down-without-moving-cursor': => @scrollDownLines()
    @subscriptions.add atom.commands.add 'atom-workspace', 'editor:page-up-without-moving-cursor': => @scrollUpPage()
    @subscriptions.add atom.commands.add 'atom-workspace', 'editor:page-down-without-moving-cursor': => @scrollDownPage()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @scrollWithoutMovingCursorView.destroy()

  serialize: ->
    scrollWithoutMovingCursorViewState: @scrollWithoutMovingCursorView.serialize()

  toggle: ->
    console.log 'ScrollWithoutMovingCursor was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
  scrollDownLines: ->
    @scroll(atom.config.get('editor.fontSize'))
  scrollUpLines: ->
    @scroll(-atom.config.get('editor.fontSize'))
  scrollDownPage: ->
    @scroll(@editorElement.getHeight())
  scrollUpPage: ->
    @scroll(-@editorElement.getHeight())

  scroll: (pixels) ->
    newScrollTop = @editorElement.getScrollTop() + pixels
    @editorElement.setScrollTop(newScrollTop)
