##############################################
#|
#| Share Pics to Google +
#|
#| 3. google+ api
#| this part will need several xhrs and corresponding objects
#|
#|
###############################################

baseURL = "https://plus.google.com"
authuser = 0  # for future switch
sparRequestLength = 45 # new protocol will add new info
imageInfoLength = 48 # seems more stable
albumInfoLength = 48 # the same as image?
spar34Length = 6 # steadily increase
SPAR_34_MULTI = [ 250, 38, 35, 1, 0]
SPAR_34_SINGLE =  [249, 18, 1, 0]
IMGOBJ_MULTI = "27847199"
IMGOBJ_SINGLE = "27639957"
IMGOBJ_PIC_ARRAY_SIZE = 14

# first open session
# url : /_/resumable?authuser=0 |1|2
# Form Data needs filename, size
# respones include upload url, upload id
openSession = (index, batchid)->
    fileName = @.imgList[index].fileName
    fileSize = @.imgList[index].fileSize
    album = @.album
    # album = { 'albumName':'String', 'albumID': 'Int', 'childCount': 'Int' }
    sessionRequestFiled = (obj) ->
        # just return the array of object. couple list comprehension and omnipresent expression
        for name, content of obj
            "inlined" :
                "name" : name
                "content" : content
                "contentType" : "text/plain"
    fields = [
        "external" :
            "name"      : "file"
            "filename"  : fileName
            "put"       : {}
            "size"      : fileSize
    ]
    if album? and album['albumID'] and album['childCount']
        a =
            "disable_asbe_notification" :   "true"
            "use_upload_size_pref"      :   "true"
            "title"                     :   fileName
            "addtime"                   :   new Date().getTime().toString()
            "batchid"                   :   batchid #new Date().getTime().toString() # in multiphoto upload, this will be a pertinent handling. batch id should be the same
            "album_id"                  :   album['albumID']
            "album_abs_position"        :   album['childCount'].toString()
            "client"                    :   "es-add-standalone-album"
    else
        a =
            "batchid"                   :   batchid#new Date().getTime().toString()
            "client"                    :   "sharebox"
            "disable_asbe_notification" :   "true"
            "streamid"                  :   "updates"
            "use_upload_size_pref"      :   "true"
            "album_abs_position"        :   index
    requestData =
        "protocolVersion" : "0.8"
        "fields"          : fields.concat sessionRequestFiled a

    ajax {
        method  : "POST"
        url     : baseURL + "/_/upload/photos/resumable?authuser=" + authuser
        headers :
            "Content-Type" : "application/x-www-form-urlencoded;charset=utf-8"
            "x-guploader-client-info" : "mechanism=scotty xhr resumable; clientVersion=42171334"
        onload  : (resp) ->
            obj = JSON.parse resp["responseText"]
            try
                uploadURL = obj.sessionStatus.externalFieldTransfers[0].putInfo.url
                @.uploadImage uploadURL
            catch e
                console.log 'openSession error'
        }

#upload photo
# url : upload url from the result of open session
# query data: refer to upload url
# data : blob
# response :
#   customerSpecificInfo: album id, photo Id, width,height,
#    url (photo), photoPageUrl, albumPageUrl, timeStamp

uploadImage = (uploadURL) ->
    ajax {
        method : "POST"
        url    : uploadURL
        data   : @.blob if @.blob?
        onload : (resp) ->
            obj = JSON.parse resp
            if obj["errorMessage"]?
                console.log obj["errorMessage"]["additionalInfo"]["uploader_service.GoogleRupioAdditionalInfo"]["requestRejectedInfo"]["reasonDescription"]
            else
                # event hanlder should go here
                @.customerInfo.push obj["sessionStatus"]["additionalInfo"]["uploader_service.GoogleRupioAdditionalInfo"]["completionInfo"]["customerSpecificInfo"]
    }

#post image
#form data needs customerSpecificInfo
postImage = ->
    newNullArray = (length) -> for i in [0...length] then null

    imgObjPics = (isAlbum, isMulti) => for info in @.customerInfo
        #this should point to GplusAPI object. this method is called in imgObj Creating
        title = info["title"]
        url = info["url"]
        width = info["width"]
        height = info["height"]
        photoPageUrl = info["photoPageUrl"]
        albumID = info["albumid"]
        photoID = info["photoid"]

        image = newNullArray IMGOBJ_PIC_ARRAY_SIZE
        temp = newNullArray 9
        temp[0] = url #middle size
        temp[1] = width
        temp[2] = height
        temp[7] = height
        temp[8] = [1, url]
        if isAlbum then temp[8][0] = 0
        else if isMulti
            temp[3] = 1
            temp[4] = 1

        image[0] = [
            photoPageUrl
            title
            ""
            url #s96-c
            null
            temp
            null
            width.toString()
            height.toString()
            width
            height
            null
            'picasaweb.google.com'
        ]
        image[1] = userID
        image[3] = photoID
        image[6] = url
        image[7] = photoPageUrl if isAlbum or isMulti
        image[9] = photoPageUrl
        image[11] = "albumid=" + albumID + "&photoid=" + photoID
        image[12] = 1
        image[13] = []
        image

    imgs = for info in @.customerInfo
        title = info["title"]
        url = info["url"]
        width = info["width"]
        height = info["height"]
        photoPageUrl = info["photoPageUrl"]
        albumID = info["albumid"]
        photoID = info["photoid"]

        image = newNullArray imageInfoLength
        image[3] = ''
        image[5] = [null, url, width, height] #original size
        image[9] = []
        image[21] = title
        image[24] = [null, photoPageUrl, null, "image/jpeg", "image"] #consider give a mimetpye
        image[41] = []
        image[41][0] = [null, url, width, height] # thumbnail size
        image[47] = []
        image[47][0] = [null, "picasa", "http://google.com/profiles/media/provider", ""]
        image[47][1] = [albumID, photoID, photoPageUrl] # buffer, to be formated

    spar = newNullArray sparRequestLength
    spar[0] = "comment" #HDmark
    spar[1] = "oz:#{userID}.#{new Date().getTime().toString(16)}.0" #HDmark
    spar[3] = if @.album? then @.album['albumID'] else @.customerInfo[0]['albumid']
    spar[9] = true
    #spar[10] = for m in mention then [null, m]
    spar[14] = spar[36] = []
    spar[11] = spar[16] = false
    spar[19] = self.userID
    #spar[27] = disableComments
    #spar[28] = lockPost
    spar[34] = newNullArray spar34Length
    #spar[37] = circle
    spar[44] = "!A0JoSBi6oOwwzERUO9imjc2DBAIAAAB-UgAAABwqAP1nVYvUCx8059loatzv7aZeAiPps50y5LimHfezr9OWN2cq90I9k1zEJAJ1quTRw8e7mvDUSEWnKqXZciNy4nDBMuViQEzNgguv8yB3G-hf18gkl-Thr-abucgItO2180dQzVV1gEiWxHWUwC3fCQQMTNEWNKdYSzB4F4paHu0KMYa3hKHpVn6JyE724tgMLVc87cVjGx2e7mqpZKATQSagfITx3QrZpA1q2H3x3dFM-ggERNkKcl9ArcHKHAG92Njty6orBkGSMIeMVlpx1jtGANOk2LDKgwsu4i5LGDAjrAjeubthS6ZMvigJ2ZQ0-oNsmoGk2tquBYGP8FRX"

    if @.album? and @.album['albumName']?
        albumUrl = "https://plus.google.com/photos/" + UserID + "/albums/" + @.album['albumID']
        albumInfo = newNullArray albumInfoLength
        albumInfo[3] = @.album['albumName']
        albumInfo[9] = []
        albumInfo[24] = [null, albumUrl, null, "text/html", "document"]
        albumInfo[41] = []
        albumInfo[47] = []
        albumInfo[47][0] = [null, "picasa", "http://google.com/profiles/media/provider", ""]
        albumInfo[47][1] = [null, "0", "http://google.com/profiles/media/additional_metadata", "album_summary_type"]

        for image in imgs
            buffer = image[47][1] #it is deep copy
            image[47][1] = [null, buffer[2], "http://google.com/profiles/media/container", ""]
            image[47][2] = [null, "albumid=#{buffer[0]}&photoid=#{buffer[1]}", "http://google.com/profiles/media/onepick_media_id", ""]

        spar[6] = JSON.stringify albumInfo.concat imgs
        spar[16] = spar[32] = true
        spar[29] = false
        spar[34][0] = SPAR_34_MULTI

        imgObj = {}
        tempArray = newNullArray 11
        tempArray[0] = albumUrl
        tempArray[1] = @album['albumName']
        tempArray[3] = imgObjPics(true)
        tempArray[4] = userID
        tempArray[5] = @album['albumID']
        tempArray[8] = 0
        tempArray[10] = "photos/" + UserID + "/albums/" + @.album['albumID']
        imgObj[IMGOBJ_MULTI] = tempArray

    else
        for image in imgs
            image[41][1] = image[41][0] # copy thumbnail
            buffer = image[47][1] #it is deep copy
            image[47][1] = [null, "albumid=#{buffer[0]}&photoid=#{buffer[1]}", "http://google.com/profiles/media/onepick_media_id", ""]
        spar[6] = JSON.stringify imgs
        #spar[12] = false
        spar[29] = true

        if imgs.length > 1
            spar[34][0] = SPAR_34_MULTI

            imgObj = {}
            tempArray = newNullArray 9
            tempArray[3] = imgObjPics(false, true)
            tempArray[4] = userID
            tempArray[8] = 0
            imgObj[IMGOBJ_MULTI] = tempArray

        else
            spar[34][0] = SPAR_34_SINGLE
            imgObj = {}
            imgObj[IMGOBJ_SINGLE] = imgObjPics[0]

    spar[34][spar34Length -1] = imgObj

    spam = if @album? then 24 else 20
    reqid = +new Date()% 10000000
    ajax {
        method  : 'POST'
        url     : "#{baseURL}/_/sharebox/post/?spam=#{spam}&rt=j&_reqid=#{reqid}"
        headers :
            "Content-Type" : "application/x-www-form-urlencoded;charset=utf-8"
        data    : 'f.req=' + (encodeURIComponent JSON.stringify spar )+ "&at=#{sessionID}" #HDmark
    }


#
GpAPI = (canvasBlob, album = null) ->
    unless canvasBlob?
        console.log 'no Pics!'
        return false
    @.fileName = canvasBlob.imageName()
    @.fileDate = canvasBlob.toBlob()
    @.fileSize = fileDate.size
    @.customerInfo
    return @

