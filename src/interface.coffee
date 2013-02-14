# interface: connect content scripts, eventpage and user behavior

messageHandler = (message, sender, sendResponse) ->
    if message['todo'] is 'execute'
        console.log  message
        targetUrl = message['target']
        console.log targetUrl
        filename = /[^\/]+\.[^\/]+$/.exec targetUrl
        try
            filename = "'#{filename[0]}'"
        catch e
            console.log "cannot find proper name!"
            return true

        candidates = document.querySelectorAll("img[src$=#{filename}]") #css3 selector
        for cand in candidates
            if cand.src is targetUrl
                target = cand
                break
        cvsB = new canvasBlob(target)
        document.body.appendChild cvsB.renderImage()
        upload = new GpAPI([cvsB])
        upload.setCallbacks
            open : -> console.log 'open session'
            upload : -> console.log  'upload image'
            ready : ->
                console.log  'ready'
                upload.postImage postOption
            post : -> console.log  'try to post'

        postOption =
            comment : 'test'
            mention : []
            disableComment : false
            lockPost : false
            circle : ['72cf18790d1b46b5']
            userID : message['user']['userID']
            sessionID : message['user']['sessionID']

        upload.init()
        sendResponse()
        true

console.log 'start Work!'

chrome.extension.onMessage.addListener messageHandler

window.onunload = ->
    chrome.extension.sendMessage
        unload : true
    console.log 'unloaded'