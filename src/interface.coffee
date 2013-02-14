# interface: connect content scripts, eventpage and user behavior




messageHandler = (message, sender, sendResponse) ->
    if message['todo'] is 'execute'

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
        #document.body.appendChild cvsB.renderImage()
        upload = new GpAPI([cvsB])
        upload.setCallbacks
            open : -> console.log 'open session'
            upload : -> console.log  'upload image'
            ready : ->
                console.log  'ready'
                upload.postImage postOption
            post : -> console.log  'try to post'

        postOption = {}
        graphicalInterface = ->
            d = document
            crtEle = 'createElement'
            bg = d[crtEle] 'div'
            bg.id = 'GPic-Background'
            bg.style.width = "#{document.width}px"
            bg.style.height = "#{document.height}px"
            bg.style.backgroundColor = "rgba(255,255,255,0.8)"
            bg.style.position = "fixed"
            bg.style.top = "0"
            bg.style.zIndex = "999"

            sharebox = d[crtEle] 'div'
            sharebox.id = 'GPic-Sharebox'
            sharebox.style.position = 'fixed'
            sharebox.style.top = '50%'
            sharebox.style.left = '50%'
            sharebox.style.margin = '-5em'

            commentArea = d[crtEle] 'textarea'
            commentArea.placeholder = 'add comment'

            circleSlection = d[crtEle] 'select'
            for circleName, circleID of message['user']['circleInfo']
                option = d[crtEle] 'option'
                option.appendChild d['createTextNode'] circleName
                option.value = circleID
                circleSlection.add option

            sendButton = d[crtEle] 'button'
            cancelButton = d[crtEle] 'button'
            sendButton.id = 'Gpic-send'
            cancelButton.id = 'Gpic-cancel'
            sendButton.appendChild document.createTextNode 'send'
            cancelButton.appendChild document.createTextNode 'cancel'

            sharebox.appendChild commentArea
            sharebox.appendChild circleSlection
            sharebox.appendChild sendButton
            sharebox.appendChild cancelButton
            bg.appendChild sharebox
            document.body.appendChild bg

            sendButton[addListener] 'click', ->
                postOption =
                    comment : commentArea.value
                    mention : []
                    disableComment : false
                    lockPost : false
                    circle : [ circleSlection.options[circleSlection.selectedIndex].value ]
                    userID : message['user']['userID']
                    sessionID : message['user']['sessionID']
                upload.init()
                document.body.removeChild bg
                sendResponse()
            cancelButton[addListener] 'click' , ->
                document.body.removeChild bg
                sendResponse()

        graphicalInterface()
        true

console.log 'start Work!'

chrome.extension.onMessage.addListener messageHandler

window.onunload = ->
    chrome.extension.sendMessage
        unload : true
    console.log 'unloaded'