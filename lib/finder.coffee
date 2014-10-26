_ = require 'underscore-plus'
{$, $$, SelectListView} = require 'atom'

module.exports =
class CommandPaletteView extends SelectListView
  @activate: ->
    new CommandPaletteView

  keyBindings: null

  initialize: ->
    super
    @addClass('command-toolbar-palette overlay from-top')

  getFilterKey: ->
    'displayName'

  attach: (@callback) ->
    @storeFocusedElement()

    if @previouslyFocusedElement[0] and @previouslyFocusedElement[0] isnt document.body
      @eventElement = @previouslyFocusedElement
    else
      @eventElement = atom.workspaceView
    @keyBindings = atom.keymap.findKeyBindings(target: @eventElement[0])

    if atom.commands?
      commands = atom.commands.findCommands(target: @eventElement[0])
    else
      commands = []
      for eventName, eventDescription of _.extend($(window).events(), @eventElement.events())
        commands.push({name: eventName, displayName: eventDescription, jQuery: true}) if eventDescription

    commands = _.sortBy(commands, 'displayName')
    @setItems(commands)

    atom.workspaceView.append(this)
    @focusFilterEditor()

  viewForItem: ({name, displayName}) ->
    keyBindings = @keyBindings
    $$ ->
      @li class: 'event', 'data-event-name': name, =>
        @div class: 'pull-right', =>
          for binding in keyBindings when binding.command is name
            @kbd _.humanizeKeystroke(binding.keystrokes), class: 'key-binding'
        @span displayName, title: name

  confirmed: ({name}) ->
    @cancel()
    @callback name
    
