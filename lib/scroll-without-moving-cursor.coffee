ScrollWithoutMovingCursorView = require './scroll-without-moving-cursor-view'
{CompositeDisposable} = require 'atom'

module.exports = ScrollWithoutMovingCursor =
  scrollWithoutMovingCursorView: null
  modalPanel: null
  subscriptions: null
  editorElement: () -> atom.views.getView(atom.workspace.getActiveTextEditor())

  activate: (state) ->
    @scrollWithoutMovingCursorView = new ScrollWithoutMovingCursorView(state.scrollWithoutMovingCursorViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @scrollWithoutMovingCursorView.getElement(), visible: false)

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
    @editorElement.destroy()

  serialize: ->
    scrollWithoutMovingCursorViewState: @scrollWithoutMovingCursorView.serialize()

  toggle: ->
    console.log 'ScrollWithoutMovingCursor was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
  scrollDownLines: ->
    @scroll(Math.max(0,@calculateNormalScrollPixels()))
  scrollUpLines: ->
    @scroll(Math.min(0,-@calculateNormalScrollPixels()))
  scrollDownPage: ->
    @scroll(Math.max(0,@calculatePageScrollPixels()))
  scrollUpPage: ->
    @scroll(Math.min(0,-@calculatePageScrollPixels()))

  calculateNormalScrollPixels: ->
    scrollType = atom.config.get('scroll-without-moving-cursor.normalScroll.scrollType')
    scrollStep = atom.config.get('scroll-without-moving-cursor.normalScroll.scrollStep')
    if scrollType == 'pixel'
      return scrollStep
    else if scrollType == 'line'
      lineHeight = atom.config.get('editor.lineHeight')
      fontSize = atom.config.get('editor.fontSize')
      return (lineHeight * fontSize) * scrollStep
  calculatePageScrollPixels: ->
    marginType   = atom.config.get('scroll-without-moving-cursor.pageScroll.marginType')
    scrollMargin = atom.config.get('scroll-without-moving-cursor.pageScroll.scrollMargin')
    if marginType == 'pixel'
      return @editorElement.getHeight() - scrollMargin
    else if marginType == 'line'
      lineHeight = atom.config.get('editor.lineHeight')
      fontSize = atom.config.get('editor.fontSize')
      return @editorElement.getHeight() - (lineHeight * fontSize) * scrollMargin

  scroll: (pixels) ->
    newScrollTop = @editorElement.getScrollTop() + pixels
    @editorElement.setScrollTop(newScrollTop)



  config:
    normalScroll:
      type: 'object'
      description: 'How far should the scroll go at each step?'
      properties:
        scrollType:
          title: 'Scroll step type'
          description: 'What does a step represent?'
          type: 'string'
          default: 'line'
          enum: ['line', 'pixel']
        scrollStep:
          title: 'Scroll step'
          type: 'number'
          default: 3
          minimum: 1
    pageScroll:
      type: 'object'
      description: 'When using page up/down, how much margin should there be?'
      properties:
        scrollMargin:
          title: 'Page scroll margin'
          description: 'How much less than a whole page should be
                        scrolled at once when page scroll is used?'
          type: 'number'
          default: 5
          minimum: 0
        marginType:
          title: 'Margin type'
          description: 'What does a margin represent?'
          type: 'string'
          default: 'line'
          enum: ['line', 'pixel']
