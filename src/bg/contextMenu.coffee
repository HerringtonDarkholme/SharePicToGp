###
experimental : add more functionality to background
other scripts should push

callList = [ caller...]

caller =
    condition : Boolean function (info, tab)
    insert : {css : filename, js: filename}
    send : function

###
context = arguments[0] || window

context.callers = []

clickHandler = (info, tab) ->
    storedUsers = JSON.parse localStorage['GpicUsers']
    storedTabs = JSON.parse localStorage['GpicTabs']
    lastSelected = JSON.parse localStorage['GpicLastSelected']
    currentUser = null

    updateLastSelected = (resp) ->
        if resp? and resp['selectedCircles']?
            lastSelected[0] = resp['selectedCircles']
            localStorage['GpicLastSelected'] = JSON.stringify lastSelected

    sendExecute = ->
        chrome.tabs.sendMessage tab.id, {
            status : 'injection success'
            todo   : 'execute'
            target : info.srcUrl
            user   : currentUser
            lastSelected : lastSelected[0]
        }, ->
            updateLastSelected()
            for caller in callers
                if caller['condition']? and caller['condition']()
                    caller['send']() if caller['send']?

    insertFile = ->
        insertExternal = ->
            for caller in callers
                if caller['condition']? and caller['condition']()
                    if caller['file']?
                        file = caller['file']
                        if file['css']?
                            chrome.tabs.insertCSS tab.id, {file : file['css']}, ->
                                chrome.tabs.executeScript tab.id, {file: file['js']}, sendExecute if file['js']?
                        else
                            chrome.tabs.executeScript tab.id, {file: file['js']}, sendExecute if file['js']?

        chrome.tabs.insertCSS tab.id, {file : 'Gpic.css'}, ->
            console.log 'insertedCSS!'
            chrome.tabs.executeScript tab.id, {file : 'test.js'},  insertExternal
                # to do : exclude g+ it self
        storedTabs.push tab.id
        localStorage['GpicTabs'] = JSON.stringify storedTabs



    if storedUsers.length is 0
        user = new userInfo()
        user.init ->
            user.getCircle ->
                storedUsers.push user.dumps()
                localStorage['GpicUsers'] = JSON.stringify storedUsers
                currentUser = storedUsers[0] # to do : multi user
                unless tab.id in storedTabs
                    insertFile()
                else
                    currentUser = storedUsers[0]
                    sendExecute()

    else
        currentUser = storedUsers[0]
        unless tab.id in storedTabs
            insertFile()
        else
            currentUser = storedUsers[0]
            sendExecute()


chrome.contextMenus.onClicked.addListener clickHandler

chrome.extension.onMessage.addListener (message , sender, sendResponse)->
    console.log 'accpet message!'
    if message? and message['unload']
        console.log 'one Tab unloaded'
        storedTabs = JSON.parse localStorage['GpicTabs']
        if sender.tab.id in storedTabs then storedTabs.pop sender.tab.id
        localStorage['GpicTabs'] = JSON.stringify storedTabs

chrome.runtime.onInstalled.addListener ->
    chrome.contextMenus.create
        type    : "normal"
        id      : "Gpic"
        title   : "Share to G+"
        contexts : ["image"]
        #onclick : clickHandler
        documentUrlPatterns : ["\u003Call_urls\u003E"]

    localStorage['GpicUsers'] = JSON.stringify []
    localStorage['GpicTabs'] = JSON.stringify []
    localStorage['GpicLastSelected'] = JSON.stringify []
