###
execScripts = (tab, scripts, callback, cbs) ->
    try
        if cbs?
            for scr in scripts[...]
                if cbs[scr]?
                    chrome.tabs.execScripts tab, {file : scr}, cbs[scr]
                else
                    chrome.tabs.execScripts tab, {file : scr}
        else
            for scr in scripts[...]
                chrome.tabs.execScripts tab, {file : scr}
        if callback? then chrome.tabs.execScripts tab, {file : scripts[scripts.length-1]}, callback
        else then p
        return true
    catch e
        console.log 'execScripts error'
        return false
###
clickHandler = (info, tab) ->
    storedUsers = JSON.parse localStorage['GpicUsers']
    storedTabs = JSON.parse localStorage['GpicTabs']

    if storedUsers.length is 0
        user = new userInfo()
        user.init ->
            user.getCircle ->
                storedUsers.push user.dumps()
                localStorage['GpicUsers'] = JSON.stringify storedUsers
                currentUser = storedUsers[0] # to do : multi user
                unless tab.id in storedTabs
                    #scripts = ['extInterface.js', 'xhr.js', 'canvasBlob.js', 'gplus_api,js']
                    #callbas =
                    #    'extInterface.js' : -> #show layout here
                    #    ''
                    chrome.tabs.executeScript tab.id, {file : 'test.js'}, ->
                        # to do : exclude g+ it self
                        chrome.tabs.sendMessage tab.id, {
                            status : 'injection success'
                            todo   : 'execute'
                            target : info.srcUrl
                            user   : currentUser
                        }
                    storedTabs.push tab.id
                    localStorage['GpicTabs'] = JSON.stringify storedTabs
                else
                    currentUser = storedUsers[0]
                    chrome.tabs.sendMessage tab.id, {
                        todo   : 'execute'
                        target : info.srcUrl
                        user   : currentUser
                    }
    else
        currentUser = storedUsers[0]
        unless tab.id in storedTabs
            #scripts = ['extInterface.js', 'xhr.js', 'canvasBlob.js', 'gplus_api,js']
            #callbas =
            #    'extInterface.js' : -> #show layout here
            #    ''
            chrome.tabs.executeScript tab.id, {file : 'test.js'}, ->
                # to do : exclude g+ it self
                chrome.tabs.sendMessage tab.id, {
                    status : 'injection success'
                    todo   : 'execute'
                    target : info.srcUrl
                    user   : currentUser
                }
            storedTabs.push tab.id
            localStorage['GpicTabs'] = JSON.stringify storedTabs
        else
            currentUser = storedUsers[0]
            chrome.tabs.sendMessage tab.id, {
                todo   : 'execute'
                target : info.srcUrl
                user   : currentUser
            }


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
