# interface: connect content scripts, eventpage and user behavior
# message Handler : receive the message from bg. and call GI and UB accordingly
# graphicalInterface : create all the html elements and return the context of UB
# userBehavior : receive the context and add Event listener
# MH, GI, UB share one global varible imgList

imgList #global

messageHandler = (message, sender, sendResponse) ->

    graphicalInterface = ()->
        bg = document.createElement 'div'
        bg.id = 'Gpic-background'
        bg.style.width = "#{document.width}px"
        bg.style.height = "#{document.height}px"
        bg.innerHTML = """
            <div id="Gpic-sharebox">
                <header></header>
                <section>
                    <textarea name="comment" id="Gpic-comment-area" cols="30" rows="10" placeholder="Share what's new..."></textarea>
                    <div id="Gpic-circle-behavior">
                        <div id="Gpic-selected-circles">
                            <span>add circle</span>
                        </div>
                        <div id="Gpic-cricles"></div>
                    </div>
                    <div id="Gpic-button-area">
                        <button id="Gpic-send">Send</button>
                        <button id="Gpic-cancel">Cancel</button>
                    </div>
                </section>
            </div>
            """

        selectedCircle = bg.querySelector '#Gpic-selected-circles'
        circleSlection =  bg.querySelector '#Gpic-cricles'
        if message['lastSelected']?
            for circleName, circleID of message['lastSelected']
                option = document.createElement 'div'
                option.class = 'Gpic-cirlce-option'
                option.appendChild document.createTextNode circleName
                if typeof circleID is "number"
                    option.setAttribute 'data-default-circle', circleID
                else
                    option.setAttribute 'data-cricle-id', circleID
                selectedCircle.appendChild optioncir

        document.body.insertBefore bg, document.body.firstChild
        defaultCircle =
            'public' : 1
            'your circle' : 3
            'extended circle' : 4
        for circleName, circleID of defaultCircle
            option = document.createElement 'div'
            option.class = 'Gpic-cirlce-option'
            option.appendChild document.createTextNode circleName
            option.setAttribute 'data-default-circle', circleID
            circleSlection.appendChild option
        for circleName, circleID of message['user']['circleInfo']
            option = document.createElement 'div'
            option['class'] = 'cirlce-option'
            option.appendChild document.createTextNode circleName
            option.setAttribute 'data-cricle-id', circleID
            circleSlection.appendChild option
        bg.querySelector('#Gpic-sharebox')

    userBehavior = (context) ->
        selectedCircles = context.querySelector '#Gpic-selected-circles'
        circleSlection = context.querySelector '#Gpic-cricles'
        circleArea = context.querySelector '#Gpic-circle-behavior'
        sendButton = context.querySelector '#Gpic-send'
        cancelButton = context.querySelector '#Gpic-#cancel'
        getSelectedCircleNum = ->
            selectedCircles.childNodes.length-1
        if getSelectedCircleNum()>0
            sendButton.class = 'active'
        showCircleHandler = (event) ->
            circleSlection.class = 'active'
            circleArea[rmvListener] 'click', showCircleHandler
            document[addListener] 'click', hideCircleHandler
        hideCircleHandler = (event) ->
            circleSlection.class = ''
            document[rmvListener] 'click', hideCircleHandler
            circleArea[addListener] 'click', hideCircleHandler
        addCircleHandler = (event) ->
            self = this
            selected = self.cloneNode()
            deleteCircleButton = document.createElement 'span'
            deleteCircleButton.class = 'Gpic-delete-circle'
            deleteCircleButton[addListener] 'click', ->
                selectedCircles.removeChild this #remove circle
                unless getSelectedCircleNum()>0
                    sendButton['class'] = ''
                self[addListener] 'click', addCircle
            selectedCircles.appendChild selected
            sendButton.class = 'active'
            self[rmvListener] 'click', addCircle

        circleArea[addListener] 'click', showCircleHandler
        (context.querySelectorAll '#Gpic-circles .Gpic-cirlce-option').forEach (e,i) ->
            e[addListener] 'click', addCircle

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
                        delay = setTimeout ->
                            notice.innerText = 'Image Posted!'
                            clearTimeout delay
                        , 2869
                        sendResponse
                            selectedCircles : resp


                sendButton[addListener] 'click', ->
                    if sendButton['class'] is 'active'
                        commentArea = context.querySelector '#Gpic-comment-area'
                        for option in (context.getElementById 'Gpic-selected-circles')['childNodes']
                            if (option.getAttribute 'data-default-circle')?
                                mention.push parseInt option.getAttribute 'data-default-circle'
                                resp[option.innerText] = parseInt option.getAttribute 'data-default-circle'
                            else if (option.getAttribute 'data-cricle-id')?
                                circle.push option.getAttribute 'data-cricle-id'
                                resp[option.innerText] = option.getAttribute 'data-cricle-id'
                        postOption =
                            comment : commentArea.value
                            mention : mention
                            disableComment : false
                            lockPost : false
                            circle : circle
                            userID : message['user']['userID']
                            sessionID : message['user']['sessionID']
                        upload.init()
                        document.body.removeChild document.getElementById 'GPic-background'
                        notice = document.createElement 'div'
                        notice.id = 'Gpic-notice'
                        notice.innerHTML = 'uploading...'
                        document.appendChild notice
                        document[rmvListener] 'click', hideCircleHandler

                cancelButton[addListener] 'click' , ->
                    document.body.removeChild bg
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