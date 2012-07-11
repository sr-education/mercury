# a static region will not accept any new data not in the layout

class @Mercury.Regions.Static extends Mercury.Region
  @supported: document.getElementById
  @supportedText: "IE 7+, Chrome 10+, Firefox 4+, Safari 5+, Opera 8+"
  type = 'static'
  type: -> type

  constructor: (@element, @window, @options = {}) ->
    super


  build: ->
    @element.css({minHeight: 20}) if @element.css('minHeight') == '0px'


  bindEvents: ->
    Mercury.on 'mode', (event, options) => @togglePreview() if options.mode == 'preview'

    Mercury.on 'focus:frame', =>
      return if @previewing
      @focus()

    Mercury.on 'action', (event, options) =>
      return if @previewing #|| Mercury.region != @
      @execCommand(options.action, options) if options.action

    @element.on 'mouseenter', (event) =>
      #@focus()
      return if @previewing #|| Mercury.region != @
      # Mercury.trigger('region:focused', {region: @})
      snippet = jQuery(event.target).closest('[data-snippet]')
      if snippet.length
        @snippet = snippet
        Mercury.trigger('show:staticToolbar', {type: 'snippet', snippet: @snippet}) if @snippet.data('snippet')

    @element.on 'mouseleave', (event) =>
      return if @previewing #|| Mercury.region != @
      Mercury.trigger('hide:staticToolbar', {type: 'snippet', immediately: false})
      

  togglePreview: ->
    if !@previewing
      @element.sortable('destroy')
      @element.removeClass('focus')
    super


  focus: ->
    Mercury.region = @
    @element.addClass('focus')


  execCommand: (action, options = {}) ->
    super
    handler.call(@, options) if handler = Mercury.Regions.Static.actions[action]


  # Actions
  @actions: {

    undo: -> @content(@history.undo())

    redo: -> @content(@history.redo())

    insertSnippet: (options) ->
      snippet = options.value
      snippet.getStaticHTML(@element, => @pushHistory())

    editSnippet: ->
      return unless @snippet
      snippet = Mercury.Snippet.find(@snippet.data('snippet'))
      snippet.displayStaticOptions()

    removeSnippet: ->
      #@snippet.remove() if @snippet
      #Mercury.trigger('hide:toolbar', {type: 'snippet', immediately: true})

  }
