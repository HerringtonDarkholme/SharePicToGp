# get user info
# user ID, sessionID, circle Info, album info

context = arguments[0] || window

authuser = 0
baseURL = "https://plus.google.com"
shareBoxURL = "#{baseURL}/u/#{authuser}/_/sharebox/dialog"
socialGraphURL = "#{baseURL}/u/#{authuser}/_/socialgraph/lookup/circles/"
mentionListURL = socialGraphURL + "?m=true"
albumsURL = "#{baseURL}_/photos/albums/"

#utility
parseGdata = (text) ->
    text = (text.split ")]}'")[1] #remove trvial security checker
    # equal to responseText = eval(responseText). always avoid using eval
    text = text.replace /\n/g , ''
    while /,,/.test text then text = text.replace /,,/g , ',null,'
    while /\[,/.test text then text = text.replace /\[,/g , '[null,'
    while /,\]/.test text then text = text.replace /,\]/g , ',null]'
    JSON.parse text

init = ->
    self = @
    ajax
        method : "GET"
        url    : shareBoxURL
        async  : false
        onload : (resp) ->
            #try
                responseText = resp['responseText']
                console.log resp.status
                self.userID = (/plus\.google\.com\/(\d+)/.exec responseText)[1]
                self.sessionID = (/AObGSA.*:\d+/.exec responseText)[0]
            #catch e
            #    console.log e
            #    console.log 'Error! try signing in?'
getCircle = ->
    self = @
    ajax
        method : "GET"
        url    : socialGraphURL
        onload : (resp) ->
            try
                circles = parseGdata resp['responseText']
                for c in circles[0][1]
                    self.circleInfo[ c[1][0] ] = c[0] #c[1][0]:circle name, c[0] : circle id
            catch e
                console.log e
                console.log 'Error in loading circles'

getAlbum = ->
    makeAlbumInfo = (list) ->
        if Object.prototype.toString.call( someVar ) is '[object Array]'
            try
                    albumName    : list[2]
                    albumSummary : list[3]
                    childCount   : list[4]
                    albumID      : list[5]
                    albumsUrl    : list[8]
            catch e
                console.log  'malformed array'
                return false
        else
            console.log  'non Array input'
            false


    self = @
    if @userID.length is 0
        console.log  'Please get userID first!'
        return false
    else
        ajax
            method : "GET"
            url    : albumsURL + self.userID
            onload : (resp) ->
                albums = (parseGdata resp['responseText'])[0]
                # builtin = albums[1] do not store builtin album info
                createdAlbum = albums[2]
                for a in createdAlbum then self.albumInfo.push makeAlbumInfo a

dumps = ->
    userID : @userID
    sessionID : @sessionID
    circleInfo : @circleInfo
    albumInfo : @albumInfo

update = (obj)->
    if obj?
        for key in ['userID', 'sessionID', 'circleInfo', 'albumInfo']
            @[key] = obj[key] if obj[key]?
    else
        console.log 'no info provided!'
        return false

getMentionList = ->
    # to Do

userInfo = ->
    @userID = ''
    @sessionID = ''
    @circleInfo = {}
    @albumInfo = []
    @

userInfo.prototype.init = init
userInfo.prototype.getCircle = getCircle
userInfo.prototype.getAlbum = getAlbum
userInfo.prototype.dumps = dumps
userInfo.prototype.update = update

context.userInfo = userInfo