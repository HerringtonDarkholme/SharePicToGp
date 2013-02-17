# interface: connect content scirpts, eventpage and user behavior
# message Handler : receive the message from bg. and call GI and UB accordingly
# graphicalInterface : create all the html elements and return the context of UB
# userBehavior : receive the context and add Event listener
# MH, GI, UB share one global varible imgList

imgList= [] #global

getStyleValue= (ele, property) ->
    (window.getComputedStyle ele).getPropertyValue property

messageHandler = (message, sender, sendResponse) ->

    graphicalInterface = ()->
        bg = document.createElement 'div'
        bg.id = 'Gpic-background'
        bg.style.width = "#{document.width}px"
        bg.style.height = "#{document.height}px"
        bg.innerHTML = """
            <div id="Gpic-sharebox">
                <header>
                <div id='red'></div>
                <div id='blue'></div>
                <div id='green'></div>
                <div id='yellow'></div>
                </header>
                <section>
                    <textarea name="comment" id="Gpic-comment-area" cols="40" rows="3" placeholder="Share what's new..."></textarea>
                    <div id="Gpic-circle-behavior">
                        <div id="Gpic-selected-circles">
                            <span id="Gpic-add">add circle</span>
                        </div>
                        <div id="Gpic-circles"></div>
                    </div>
                    <div id="Gpic-button-area">
                        <div id="Gpic-send">Send<div class='shadow'></div></div>
                        <div id="Gpic-cancel">Cancel<div class='shadow'></div></div>
                    </div>
                </section>
            </div>
            """

        selectedCircle = bg.querySelector '#Gpic-selected-circles'
        circleSlection =  bg.querySelector '#Gpic-circles'
        if message['lastSelected']?
            for circleID, circleName of message['lastSelected']
                option = document.createElement 'div'
                option.className = 'Gpic-circle-option'
                option.appendChild document.createTextNode circleName
                if circleID in ['1', '3', '4'] # check default circle
                    option.setAttribute 'data-default-circle', circleID
                else
                    option.setAttribute 'data-circle-id', circleID
                selectedCircle.insertBefore option, selectedCircle.firstChild

        document.body.insertBefore bg, document.body.firstChild
        defaultCircle =
            1 : 'Public'
            3 : 'Your Circle'
            4 : 'Extended Circle'
        for circleID, circleName of defaultCircle
            option = document.createElement 'div'
            option.className = 'Gpic-circle-option'
            option.appendChild document.createTextNode circleName
            option.setAttribute 'data-default-circle', circleID
            circleSlection.appendChild option
        for circleID, circleName of message['user']['circleInfo']
            unless circleName == 'Blocked'
                option = document.createElement 'div'
                option.className = 'Gpic-circle-option'
                option.appendChild document.createTextNode circleName
                option.setAttribute 'data-circle-id', circleID
                circleSlection.appendChild option
        bg.querySelector('#Gpic-sharebox')

    userBehavior = (context) ->
        selectedCircles = context.querySelector '#Gpic-selected-circles'
        circleSlection = context.querySelector '#Gpic-circles'
        circleArea = context.querySelector '#Gpic-circle-behavior'
        addSpan = context.querySelector '#Gpic-add'
        sendButton = context.querySelector '#Gpic-send'
        cancelButton = context.querySelector '#Gpic-cancel'
        getSelectedCircleNum = ->
            selectedCircles.querySelectorAll('div').length
        if getSelectedCircleNum()>0
            sendButton.className = 'active'
        showCircleHandler = (event) ->
            event.stopPropagation()
            circleSlection.className = 'active'
            context.style.marginTop = "-#{parseFloat(getStyleValue context, 'height')/2}px"
            circleArea[rmvListener] 'click', showCircleHandler
            document[addListener] 'click', hideCircleHandler
        hideCircleHandler = (event) ->
            event.stopPropagation()
            circleSlection.className = ''
            context.style.marginTop = "-#{parseFloat(getStyleValue context, 'height')/2}px"
            document[rmvListener] 'click', hideCircleHandler
            circleArea[addListener] 'click', showCircleHandler
        addCircleHandler = (event) ->
            event.stopPropagation()
            self = this
            selected = self.cloneNode(true)
            ###
            deleteCircleButton = document.createElement 'span'
            deleteCircleButton.innerText = 'x'
            deleteCircleButton.className = 'Gpic-delete-circle'
            ###
            #deleteCircleButton[addListener] 'click', ->
            selected[addListener] 'click', (event)->
                event.stopPropagation()
                selectedCircles.removeChild selected #remove circle
                unless getSelectedCircleNum()>0
                    sendButton.className = ''
                self[addListener] 'click', addCircleHandler
            #selected.appendChild deleteCircleButton
            selectedCircles.insertBefore selected, addSpan
            sendButton.className = 'active'
            self[rmvListener] 'click', addCircleHandler
        removeCircleHandler = (event) ->
            event.stopPropagation()
            if (this.getAttribute 'data-default-circle')?
                q = "data-default-circle=\"#{this.getAttribute 'data-default-circle'}\""
            else if (this.getAttribute 'data-circle-id')?
                q = "data-circle-id=\"#{this.getAttribute 'data-circle-id'}\""
            console.log q
            couterpart = circleSlection.querySelector "[#{q}]"
            console.log couterpart
            couterpart[addListener] 'click', addCircleHandler
            selectedCircles.removeChild this
            unless getSelectedCircleNum()>0
                sendButton.className = ''

        circleArea[addListener] 'click', showCircleHandler
        for e in context.querySelectorAll '#Gpic-circles .Gpic-circle-option'
            if message['lastSelected']?
                eid = (e.getAttribute 'data-circle-id') || (e.getAttribute 'data-default-circle')
                unless eid of message['lastSelected']
                    e[addListener] 'click', addCircleHandler
            else
                e[addListener] 'click', addCircleHandler
        for e in selectedCircles.querySelectorAll '.Gpic-circle-option'
            e[addListener] 'click', removeCircleHandler

        for cvsB in imgList
            if cvsB.imageSrc() is message['target']
                postOption = {}
                mention = []
                circle = []
                resp = {}
                upload = new GpAPI([cvsB])
                upload.setCallbacks
                    open : -> console.log 'open session'
                    upload : -> console.log  'upload image'
                    ready : ->
                        console.log  'ready'
                        upload.postImage postOption
                    post : ->
                        console.log  'post success'
                        notice = document.getElementById 'Gpic-notice'
                        notice.innerText = 'Image Posted!'
                        delay = setTimeout ->
                            document.body.removeChild notice
                            clearTimeout delay
                        , 2869
                        sendResponse
                            selectedCircles : resp


                sendButton[addListener] 'click', ->
                    if sendButton.className is 'active'
                        commentArea = context.querySelector '#Gpic-comment-area'
                        for option in selectedCircles.querySelectorAll 'div'
                            if (option.getAttribute 'data-default-circle')?
                                mention.push parseInt option.getAttribute 'data-default-circle'
                                resp[option.getAttribute('data-default-circle')] = option.innerText

                            else if (option.getAttribute 'data-circle-id')?
                                circle.push option.getAttribute 'data-circle-id'
                                resp[option.getAttribute 'data-circle-id'] = option.innerText
                        postOption =
                            comment : commentArea.value
                            mention : mention
                            disableComment : false
                            lockPost : false
                            circle : circle
                            userID : message['user']['userID']
                            sessionID : message['user']['sessionID']
                        upload.init()
                        document.body.removeChild document.getElementById 'Gpic-background'
                        notice = document.createElement 'div'
                        notice.id = 'Gpic-notice'
                        notice.innerHTML = 'uploading...'
                        document.body.appendChild notice
                        document[rmvListener] 'click', hideCircleHandler

                cancelButton[addListener] 'click' , ->
                    document.body.removeChild document.getElementById 'Gpic-background'
                    sendResponse()


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

        imgList.push new canvasBlob(target)
        context = graphicalInterface()
        userBehavior(context)
        true

console.log 'start Work!'

chrome.extension.onMessage.addListener messageHandler

window.onunload = ->
    chrome.extension.sendMessage
        unload : true
    console.log 'unloaded'