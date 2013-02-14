##############################################
#|
#| Share Pics to Google +
#|
#| 1. convert img to canvas
#|
#|
#|
###############################################


# Canvas extension
context = arguments[0] || window
w = window
canvasPrototype = w.HTMLCanvasElement and w.HTMLCanvasElement.prototype

# two way to create blobl, through BlobBuilder and through BlobConstructor
hasBlob = ->
    try
        return w.Blob and Boolean(new Blob)
    catch e
        return false

BlobBuilder = w.BlobBuilder or w.WebKitBlobBuilder or w.MozBlobBuilder or w.MSBlobBuilder

hasArrayBuffer = ->
    # mandatory, check for whether new Uint Array exist
    try
        return w.ArrayBuffer and w.Uint8Array
    catch e
        return false

hasArrayBufferViweSupport = ->
    try
        return hasArrayBuffer() and hasBlob() and new Blob(new Uint8Array(100)).size is 100;
    catch e
        return false


canvasBlob = (imgEle) ->
    if not imgEle? and imgEle.tagName != 'IMG'
        console.log('TypeError: Need a image object')
        return false
    if !!canvasPrototype and (hasBlob() or !!BlobBuilder) and hasArrayBuffer()

        width = imgEle.width
        height = imgEle.height
        that = this
        canvas = document.createElement('canvas')
        canvas.width = width
        canvas.height = height
        context = canvas.getContext('2d')
        context.drawImage(imgEle, 0, 0)

        this.imageName = ->
            try
                return /[^\/]+\.[^\/]+$/.exec(imgEle.src)[0]
            catch e
                console.log 'invalid name'
                return 'error'

        this.renderImage = (targetW=width, targetH=height, alpha = 0.25, beta = 4) ->
            # return a img element. w, h is the target width and height, respectively
            # alpha and beta are coefficients that prevent the img from being distorted
            # w / width * H/h will be compared with alpha and beta.
            # alpha: it clips the img vertically, increasing with clipping threshold.
            # beta: it clips the img horizontally, decreasing with clipping threshold.
            renderedImg = document.createElement('img')
            renderedImg.src = canvas.toDataURL()
            clip = (img, w, h) -> img.style = "clip: rect(0px, #{w}px, #{h}px, 0px);"

            if targetH > height # handle the most frequent situation first
                ratio = targetW / width * height / targetH
                if ratio < alpha
                    if targetW > width
                        renderedImg.width = targetW
                        clip renderedImg, targetW, targetH

                    else
                        clip renderedImg, width, targetH

                else if ratio < 1 then renderedImg.height = targetH
                else if ratio < beta then renderedImg.width = targetW
                else
                    renderedImg.height = targetH
                    clip renderedImg, targetW, targetH
            else
                if width > targetW
                    if targetW / width * height / targetH < beta then renderedImg.width = targetW
                    else clip renderedImg, targetW, height

            return renderedImg


        this.toBlob = ->
            dataUrl = canvas.toDataURL()
            if !!w.atob
                #check if the dataUrl is encoded
                if dataUrl.split(',')[0].indexOf('base64') != -1
                    byteString = atob( dataUrl.split(',')[1] )
                else
                    byteString = atob( decodesURIComponent(dataUrl).split(',')[1] )
                length = byteString.length
                arrayBuffer = new ArrayBuffer(length)
                intArray = new Uint8Array(arrayBuffer)
                for i in [0..length]
                    intArray[i] = byteString.charCodeAt(i)

                #separate the mimetype and pass it to Blob
                mimetype = /image\/\w+/.exec(dataUrl)[0]
                if hasBlob()
                    blobData = if hasArrayBufferViweSupport() then intArray else arrayBuffer
                    new Blob( [blobData], {type: mimetype} )
                else
                    bb = new BlobBuilder()
                    bb.append (arrayBuffer)
                    bb.getBlob(mimetype)
    else
        console.log('no Blob or Canvas support! Change to a better browser?')
        return false

    this

context.canvasBlob = canvasBlob