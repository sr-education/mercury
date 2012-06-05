class @Mercury.Snippet

  @all: []

  @displayOptionsFor: (name) ->
    Mercury.modal Mercury.config.snippets.optionsUrl.replace(':name', name), {
      title: 'Snippet Options'
      handler: 'insertSnippet'
      snippetName: name
    }
    Mercury.snippet = null


  @create: (name, options) ->
    if @all.length > 0
      identity = "snippet_0"
      for snippet, i in @all
        identity = "snippet_#{i+1}" if snippet.identity == identity
    else
      identity = "snippet_#{@all.length}"
    
    instance = new Mercury.Snippet(name, identity, options)
    @all.push(instance)
    return instance


  @find: (identity) ->
    for snippet in @all
      return snippet if snippet.identity == identity
    return null


  @load: (snippets) ->
    for own identity, details of snippets
      instance = new Mercury.Snippet(details.name, identity, details.options)
      @all.push(instance)


  constructor: (@name, @identity, options = {}) ->
    @version = 0
    @data = ''
    @history = new Mercury.HistoryBuffer()
    @setOptions(options)


  getHTML: (context, callback = null) ->
    element = jQuery('<div>', {
      class: "mercury-snippet #{@name}-snippet"
      contenteditable: "false"
      'data-snippet': @identity
      'data-version': @version
    }, context)
    element.html("[#{@identity}]")
    @loadPreview(element, callback)
    return element

  getStaticHTML: (element, callback = null) ->
    element.html("[#{@identity}]")
    @loadPreview(element, callback, true)
    return element

  getText: (callback) ->
    return "[--#{@identity}--]"


  loadPreview: (element, callback = null, layoutSnippet = false) ->
    sendData = @options
    if layoutSnippet
      sendData = jQuery.extend({}, @options, {layoutSnippet: true})
    jQuery.ajax Mercury.config.snippets.previewUrl.replace(':name', @name), {
      headers: Mercury.ajaxHeaders()
      type: Mercury.config.snippets.method
      data: sendData
      success: (data) =>
        if data.element
          new_elem = jQuery(data.element)
          attrs = {}
          jQuery.each( element[0].attributes, (index,attr) ->
            attrs[attr.name]=attr.value )
          element.replaceWith(new_elem.attr(attrs))
          @data = data.elementHtml
          new_elem.html(data.elementHtml)
          element = new_elem
        else
          @data = data
          element.html(data)
        callback() if callback
      error: =>
        Mercury.notify('Error loading the preview for the \"%s\" snippet.', @name)
    }


  displayOptions: ->
    Mercury.snippet = @
    Mercury.modal Mercury.config.snippets.optionsUrl.replace(':name', @name), {
      title: 'Snippet Options',
      handler: 'insertSnippet',
      loadType: Mercury.config.snippets.method,
      loadData: @options
    }

  displayStaticOptions: ->
    Mercury.snippet = @
    Mercury.modal Mercury.config.snippets.optionsUrl.replace(':name', @name), {
      title: 'Snippet Options',
      handler: 'insertSnippet',
      loadType: Mercury.config.snippets.method,
      loadData: jQuery.extend({}, @options, {layoutSnippet: true})
    }


  setOptions: (@options) ->
    delete(@options['authenticity_token'])
    delete(@options['utf8'])
    @version += 1
    @history.push(@options)


  setVersion: (version = null) ->
    version = parseInt(version)
    if version && @history.stack[version - 1]
      @version = version - 1
      @options = @history.stack[@version]
      return true
    return false


  serialize: ->
    return {
      name: @name
      options: @options
    }
