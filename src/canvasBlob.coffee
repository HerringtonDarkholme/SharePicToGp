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
    if (hasBlob() or !!BlobBuilder) and hasArrayBuffer()

        width = imgEle.width
        height = imgEle.height
        that = this
        canvas = document.createElement('canvas')
        canvas.width = width
        canvas.height = height
        context = canvas.getContext('2d')
        context.drawImage(imgEle, 0, 0)

        this.renderImage = (w=width, h=height) ->
            return canvas

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

        this

argument[0].canvasBlob = canvasBlob