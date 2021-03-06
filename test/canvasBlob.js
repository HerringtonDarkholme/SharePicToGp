// Generated by CoffeeScript 1.4.0
(function() {
  var BlobBuilder, canvasBlob, canvasPrototype, hasArrayBuffer, hasArrayBufferViweSupport, hasBlob, w;

  w = window;

  canvasPrototype = w.HTMLCanvasElement && w.HTMLCanvasElement.prototype;

  hasBlob = function() {
    try {
      return w.Blob && Boolean(new Blob);
    } catch (e) {
      return false;
    }
  };

  BlobBuilder = w.BlobBuilder || w.WebKitBlobBuilder || w.MozBlobBuilder || w.MSBlobBuilder;

  hasArrayBuffer = function() {
    try {
      return w.ArrayBuffer && w.Uint8Array;
    } catch (e) {
      return false;
    }
  };

  hasArrayBufferViweSupport = function() {
    try {
      return hasArrayBuffer() && hasBlob() && new Blob(new Uint8Array(100)).size === 100;
    } catch (e) {
      return false;
    }
  };

  canvasBlob = function(imgEle) {
    var canvas, context, height, that, width;
    if (!(imgEle != null) && imgEle.tagName !== 'IMG') {
      console.log('TypeError: Need a image object');
      return false;
    }
    if (!!canvasPrototype && (hasBlob() || !!BlobBuilder) && hasArrayBuffer()) {
      width = imgEle.width;
      height = imgEle.height;
      that = this;
      canvas = document.createElement('canvas');
      canvas.width = width;
      canvas.height = height;
      context = canvas.getContext('2d');
      context.drawImage(imgEle, 0, 0);
      this.imageName = function() {
        try {
          return /[^\/]+\.[^\/]+$/.exec(imgEle.src)[0];
        } catch (e) {
          console.log('invalid name');
          return 'error';
        }
      };
      this.renderImage = function(targetW, targetH, alpha, beta) {
        var clip, ratio, renderedImg;
        if (targetW == null) {
          targetW = width;
        }
        if (targetH == null) {
          targetH = height;
        }
        if (alpha == null) {
          alpha = 0.25;
        }
        if (beta == null) {
          beta = 4;
        }
        renderedImg = document.createElement('img');
        renderedImg.src = canvas.toDataURL();
        clip = function(img, w, h) {
          return img.style = "clip: rect(0px, " + w + "px, " + h + "px, 0px);";
        };
        if (targetH > height) {
          ratio = targetW / width * height / targetH;
          if (ratio < alpha) {
            if (targetW > width) {
              renderedImg.width = targetW;
              clip(renderedImg, targetW, targetH);
            } else {
              clip(renderedImg, width, targetH);
            }
          } else if (ratio < 1) {
            renderedImg.height = targetH;
          } else if (ratio < beta) {
            renderedImg.width = targetW;
          } else {
            renderedImg.height = targetH;
            clip(renderedImg, targetW, targetH);
          }
        } else {
          if (width > targetW) {
            if (targetW / width * height / targetH < beta) {
              renderedImg.width = targetW;
            } else {
              clip(renderedImg, targetW, height);
            }
          }
        }
        return renderedImg;
      };
      this.toBlob = function() {
        var arrayBuffer, bb, blobData, byteString, dataUrl, i, intArray, length, mimetype, _i;
        dataUrl = canvas.toDataURL();
        if (!!w.atob) {
          if (dataUrl.split(',')[0].indexOf('base64') !== -1) {
            byteString = atob(dataUrl.split(',')[1]);
          } else {
            byteString = atob(decodesURIComponent(dataUrl).split(',')[1]);
          }
          length = byteString.length;
          arrayBuffer = new ArrayBuffer(length);
          intArray = new Uint8Array(arrayBuffer);
          for (i = _i = 0; 0 <= length ? _i <= length : _i >= length; i = 0 <= length ? ++_i : --_i) {
            intArray[i] = byteString.charCodeAt(i);
          }
          mimetype = /image\/\w+/.exec(dataUrl)[0];
          if (hasBlob()) {
            blobData = hasArrayBufferViweSupport() ? intArray : arrayBuffer;
            return new Blob([blobData], {
              type: mimetype
            });
          } else {
            bb = new BlobBuilder();
            bb.append(arrayBuffer);
            return bb.getBlob(mimetype);
          }
        }
      };
    } else {
      console.log('no Blob or Canvas support! Change to a better browser?');
      return false;
    }
    return this;
  };

  argument[0].canvasBlob = canvasBlob;

}).call(this);
