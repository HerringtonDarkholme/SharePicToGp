# get user info
# user ID, sessionID, circle Info, album info

context = arguments[0] || window

authuser = 0
baseURL = "https://plus.google.com"
shareBoxURL = "#{baseURL}/u/#{authuser}/_/sharebox/dialog"
socialGraphURL = "#{baseURL}/u/#{authuser}/_/socialgraph/lookup/circles/"
mentionListURL = socialGraphURL + "?m=true"
albumsURL = "#{baseURL}/_/photos/albums/"
communityURL = "#{baseURL}/u/#{authuser}/_/communities/getcommunities?rt=j&_reqid=#{+new Date()% 10000000}"
communityDetailURL = communityURL.replace /getcommunities/, 'getcommunity'
#?ozv=es_oz_20130214.08_p5&avw=str%3A1&fsid=1096028256&_reqid=16037304&rt=j
#https://plus.google.com/u/0/_/communities/getcommunities?hl=en&ozv=es_oz_20130214.08_p5&fsid=706407746&_reqid=181296&rt=j
#utility
parseGdata = (text) ->
    text = (text.split ")]}'")[1] #remove trvial security checker
    # equal to responseText = eval(responseText). always avoid using eval
    text = text.replace /\n/g , ''
    while /,,/.test text then text = text.replace /,,/g , ',null,'
    while /\[,/.test text then text = text.replace /\[,/g , '[null,'
    while /,\]/.test text then text = text.replace /,\]/g , ',null]'
    JSON.parse text

getKeys = (obj) -> for key of obj then key

init = (callback)->
    self = @
    ajax
        method : "GET"
        url    : shareBoxURL
        async  : false
        onload : (resp) ->
            try
                responseText = resp['responseText']
                console.log resp.status
                self.userID = (/plus\.google\.com\/(\d+)/.exec responseText)[1]
                self.sessionID = (/AObGSA.*:\d+/.exec responseText)[0]
                callback(self) if callback?
            catch e
                console.log e
                console.log 'Error! try signing in?'
getCircle = (callback, retry= 1)->
    if retry < 0
        console.log  'Unable to Info!'
        return false
    self = @
    ajax
        method : "GET"
        url    : socialGraphURL
        onload : (resp) ->
            try
                circles = parseGdata resp['responseText']
                for c in circles[0][1]
                    self.circleInfo[ c[0][0] ] = c[1][0] #c[1][0]:circle name, c[0] : circle id
                callback(self) if callback?
            catch e
                self.init ->
                    self.getCircle callback, retry-1
                console.log 'Error in loading circles'

getAlbum = (callback, retry= 1)->
    if retry < 0
        console.log  'Unable to Info!'
        return false
    makeAlbumInfo = (list) ->
        if Object.prototype.toString.call(list ) is '[object Array]'
            try
                    albumName    : list[2]
                    albumSummary : list[3]
                    childCount   : list[4]
                    albumID      : list[5]
                    albumsUrl    : list[8]
            catch e
                console.log  'malformed array'
        else
            console.log  'non Array input'


    self = @
    if @userID.length is 0
        console.log  'Please get userID first!'
        self.init ->
            self.getAlbum callback, retry-1
        return false
    else
        ajax
            method : "GET"
            url    : albumsURL + self.userID
            onload : (resp) ->
                try
                    albums = (parseGdata resp['responseText'])[0]
                    # builtin = albums[1] do not store builtin album info
                    createdAlbum = albums[2]
                    for a in createdAlbum then self.albumInfo.push makeAlbumInfo a
                    callback(self) if callback?
                catch e
                    self.init ->
                        self.getAlbum callback, retry-1
                    console.log 'error in launch'

getCommunities = (callback, retry= 1)->
    if retry < 0
        console.log  'Unable to Info!'
        return false
    if @sessionID.length is 0
        console.log  'Please sign in first'
        self = @
        self.init ->
            self.getCommunities callback, retry-1
        return false
    else
        self = @
        ajax
            method : "POST"
            url    : communityURL
            headers :
                "Content-Type" : "application/x-www-form-urlencoded;charset=utf-8"
            data    : 'f.req=' + (encodeURIComponent "[[1]]") + "&at=#{encodeURIComponent self.sessionID}&" #HDmark
            onload  : (resp)->
                try
                    communities = (parseGdata resp['responseText'])[0][1][2]
                    for c in communities
                        community = c[0][0] #Array[6]
                        communityID = community[0]
                        communityName = community[1][0]
                        self.communityInfo[communityID] = communityName
                    callback(self) if callback?
                catch e
                    self.init ->
                        self.getCommunities callback, retry-1
                    console.log "error in launch"

getCommunityDetails = (communityID,callback, retry=1) ->
    if retry < 0
        console.log  'Unable to Info!'
        return false
    if @sessionID.length is 0
        console.log  'Please sign in first'
        self = @
        self.init ->
            self.getCommunityDetails communityID, callback, retry-1
        return false
    else
        self = @
        communityDetails = {}
        ajax
            method : "POST"
            url    : communityDetailURL
            async  : false
            headers :
                "Content-Type" : "application/x-www-form-urlencoded;charset=utf-8"
            data    : 'f.req=' + (encodeURIComponent "[\"#{communityID}\",false]") + "&at=#{encodeURIComponent self.sessionID}&" #HDmark
            onload  : (resp)->
                try
                    categories = (parseGdata resp['responseText'])[0][1][1][2][0]
                    for c in categories
                        categoryID = c[0]
                        categoryName = c[1]
                        communityDetails[categoryID] = categoryName
                catch e
                    self.init ->
                        self.getCommunityDetails communityID, callback, retry-1
                    console.log "error in launch"
        communityDetails


dumps = ->
    userID : @userID
    sessionID : @sessionID
    circleInfo : @circleInfo
    albumInfo : @albumInfo
    communityInfo : @communityInfo

update = (obj)->
    if obj?
        for key in ['userID', 'sessionID', 'circleInfo', 'albumInfo', 'communityInfo']
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
    @communityInfo = {}
    @

userInfo.prototype.init = init
userInfo.prototype.getCircle = getCircle
userInfo.prototype.getAlbum = getAlbum
userInfo.prototype.getCommunities = getCommunities
userInfo.prototype.getCommunityDetails = getCommunityDetails
userInfo.prototype.dumps = dumps
userInfo.prototype.update = update

context.userInfo = userInfo

user = new userInfo()
user.getAlbum()