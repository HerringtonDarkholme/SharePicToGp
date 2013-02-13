# get user info
# user ID, sessionID, circle Info, album info

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
        onload : (resp) ->
            try
                responseText = resp['responseText']
                self.userID = (/plus\.google\.com\/(\d+)/.exec responseText)[1]
                self.sessionID = (/AObgSA.*:\d+/.exec responseText)[0]
            catch e
                console.log 'Error! try signing in?'
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
                console.log 'Error in loading circles'

getAlbum = ->
    self = @
    if @userID.length is 0
        console.log  'Please get userID first!'
        return false
    else
        ajax
            method : "GET"
            url    : albumsURL + self.userID
            onload : (resp) ->
                albums = parseGdata resp['responseText']



getMentionList = ->
    # to Do

User = ->
    @userID = ''
    @sessionID = ''
    @circleInfo = {}
    @albumInfo = []


