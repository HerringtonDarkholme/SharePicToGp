##############################################
#|
#| Share Pics to Google +
#|
#| 2. ajax utility
#|
#|
#|
###############################################
context = arguments[0] || window
w = window

addListener = if w.addEventListener? then  'addEventListener' else 'attachEvent'
rmvListener = if w.removeEventListener? then 'removeEventListener' else 'detachEvent'

xhr_compatible = ->
    if w.XMLHttpRequest?
        return new XMLHttpRequest()
    else
        try
            return new ActiveXObject('Msxml2.XMLHTTP.6.0')
        catch e
        try
            return new ActiveXObject('Msxml2.XMLHTTP.3.0')
        catch e
        try
            return new ActiveXObject('Microsoft.XMLHTTP')
        catch e
            throw new Error("Your browser is in great SECURITY DANGER! Please Install Chrome for better SECURITY and PERFORMANCE")


ajax = ( options ) ->
    # @param (Object) options   :   an object for configuring xhr. its accepted keys are listed below
    # @key url (String)         :   mandatory
    # @key method (String)      :   default to 'GET' if data is null
    # @key data (Any_type)      :   xhr.send(data)
    # @key async (Boolean)      :   must be true if multipart attribute is true
    # @key onload (function)    :   the handler binded to onload if onload is supported.
    #                                   Otherwise it is executed in onReadyStateChange
    # @key onerror (function)   :   similar to onload
    # @key onprogress(func)     :   similar to onload
    # @key headers (object)      :   plain Object with key-value pairs intended to set. this method logs error instead throw
    # @key before (function)    :   function executed before xhr send. e.g. overrideMimeType
    # @key spec  (object)       :   keys shall be status codes and value shall be

    if not options? and not options['url']
        console.log "no proper arguments!"
        return false
    url = options['url']
    data = if options['data']? then options['data'] else null
    method = if options['method']? then options['method'] else (unless data? then 'GET' else 'POST')
    async = if options['async']? then options['async'] else true

    xhr = xhr_compatible()
    xhr.open( method, url, async)

    if options['headers']?
        console.log  'header'
        for header, value of options['headers']
            console.log "#{header} : #{value}"

            try
                xhr.setRequestHeader header, value
            catch e
                console.log "cannot set #{header} to #{value}"
                return false

    if options['before']?
        try
            options['before'](xhr)
        catch e
            console.log 'error at execute beforeSend'
            return false

    for prog in ['onload', 'onerror', 'onprogress']
        if options[prog]?
            xhr[prog] = (->
                active = prog
                (progressEvent) ->
                    options[active] xhr, progressEvent)() #use IIFE to evaluate prog

    xhr.onreadystatechanges = ->

        if xhr.readyState is 4 and ( 200 <= xhr.status < 300 or xhr.status is 304 )
            try
                options['onload'](xhr) if options['onload']?
            catch e
                console.log "onload handler error"
                return false

        if xhr.readyState is 4 and xhr.status >= 400
            try
                options['error'](xhr) if options['error']?
            catch e
                console.log "error handler error"
                return false

        console.log 'progress cannot be mocked by xhr'

        if options['spec']?
            if ''+xhr.status in options['spec']
                try
                    options['spec'](xhr)
                catch e
                    console.log 'spec error'
                    return false
    xhr.send(data)

context.ajax = ajax

# unit test

###
test =
    url     : 'http://www.baidu.com' #no relative path
    #method  : 'GET'
    before  : -> console.log 'before'
    headers :
        'content-type' : 'application/x-www-form-urlencoded;charset=UTF-8' #set data to form data
    onload  : -> console.log 'success'
    onerror : -> console.log 'error'
    onprogress : -> console.log 'working'
    data    :  'take it boy'

ajax test
###