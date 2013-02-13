clickHandler = (info, tab) ->
    unless tab in localStorage['Gpic']['tabs']
        chrome.tabs.executeScript tab, { file : []}

chrome.runtime.onInstalled ->
    chrome.contextMenus.create
        type    : "normal"
        id      : "Gpic"
        title   : "Share to G+"
        context : ["image"]
        onclick : clickHandler
        documentUrlPatterns : ["\u003Call_urls\u003E"]

    localStorage['Gpic'] =
        users : []
        tabs  : []
