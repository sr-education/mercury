# a static region will not accept any new data not in the layout

class @Mercury.Regions.Static extends Mercury.Region
  @supported: document.getElementById
  @supportedText: "IE 7+, Chrome 10+, Firefox 4+, Safari 5+, Opera 8+"

  type = 'static'

  constructor: (@element, @window, @options = {}) ->
    @type = 'static'
    super


  build: ->
    @element.css({minHeight: 20}) if @element.css('minHeight') == '0px'


  bindEvents: ->
    super

    @element.on 'mousemove', (event) =>
      return if @previewing || Mercury.region != @
      snippet = jQuery(event.target).closest('.mercury-snippet')
      if snippet.length
        @snippet = snippet
        Mercury.trigger('hide:toolbar', {type: 'snippet', immediately: true})
        Mercury.trigger('show:staticToolbar', {type: 'snippet', snippet: @snippet})

    @element.on 'mouseout', =>
      return if @previewing
      Mercury.trigger('hide:toolbar', {type: 'snippet', immediately: true})
      Mercury.trigger('hide:staticToolbar', {type: 'snippet', immediately: false})

    Mercury.on 'unfocus:regions', (event) =>
      return if @previewing
      if Mercury.region == @
        @element.removeClass('focus')
        @element.sortable('destroy')
        Mercury.trigger('region:blurred', {region: @})

    Mercury.on 'focus:window', (event) =>
      return if @previewing
      if Mercury.region == @
        @element.removeClass('focus')
        @element.sortable('destroy')
        Mercury.trigger('region:blurred', {region: @})

    @element.on 'mouseup', =>
      return if @previewing
      @focus()
      Mercury.trigger('region:focused', {region: @})

    @element.on 'dragover', (event) =>
      return if @previewing
      event.preventDefault()
      #event.originalEvent.dataTransfer.dropEffect = 'copy'

    @element.on 'drop', (event) =>
      return if @previewing || ! Mercury.snippet
      @focus()
      event.preventDefault()
      #Mercury.Snippet.displayOptionsFor(Mercury.snippet)

    jQuery(@document).on 'keydown', (event) =>
      return if @previewing || Mercury.region != @
      switch event.keyCode
        when 90 # undo / redo
          return unless event.metaKey
          event.preventDefault()
          if event.shiftKey then @execCommand('redo') else @execCommand('undo')

    jQuery(@document).on 'keyup', =>
      return if @previewing || Mercury.region != @
      Mercury.changes = true


  focus: ->
    Mercury.region = @
    @element.addClass('focus')


  togglePreview: ->
    if !@previewing
      @element.sortable('destroy')
      @element.removeClass('focus')
    super


  execCommand: (action, options = {}) ->
    super
    handler.call(@, options) if handler = Mercury.Regions.Static.actions[action]


  # Actions
  @actions: {

    undo: -> @content(@history.undo())

    redo: -> @content(@history.redo())

    insertSnippet: (options) ->
      snippet = options.value
      if (existing = @element.find("[data-snippet=#{snippet.identity}]")).length
        existing.replaceWith(snippet.getHTML(@document, => @pushHistory()))
      else
        @element.append(snippet.getHTML(@document, => @pushHistory()))

    editSnippet: ->
      return unless @snippet
      snippet = Mercury.Snippet.find(@snippet.data('snippet'))
      snippet.displayOptions()

    removeSnippet: ->
      #@snippet.remove() if @snippet
      #Mercury.trigger('hide:toolbar', {type: 'snippet', immediately: true})

  }
