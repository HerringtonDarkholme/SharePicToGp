// Generated by CoffeeScript 1.4.0
(function() {
  var BATCH_SIZE, BlobBuilder, GpAPI, IMGOBJ_MULTI, IMGOBJ_PIC_ARRAY_SIZE, IMGOBJ_SINGLE, SPAR_34_MULTI, SPAR_34_SINGLE, addListener, ajax, albumInfoLength, authuser, baseURL, canvasBlob, canvasPrototype, context, hasArrayBuffer, hasArrayBufferViweSupport, hasBlob, imageInfoLength, init, messageHandler, openSession, postImage, rmvListener, setCallbacks, spar34Length, sparRequestLength, uploadImage, w, xhr_compatible,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  context = arguments[0] || window;

  w = window;

  addListener = w.addEventListener != null ? 'addEventListener' : 'attachEvent';

  rmvListener = w.removeEventListener != null ? 'removeEventListener' : 'detachEvent';

  xhr_compatible = function() {
    if (w.XMLHttpRequest != null) {
      return new XMLHttpRequest();
    } else {
      try {
        return new ActiveXObject('Msxml2.XMLHTTP.6.0');
      } catch (e) {

      }
      try {
        return new ActiveXObject('Msxml2.XMLHTTP.3.0');
      } catch (e) {

      }
      try {
        return new ActiveXObject('Microsoft.XMLHTTP');
      } catch (e) {
        throw new Error("Your browser is in great SECURITY DANGER! Please Install Chrome for better SECURITY and PERFORMANCE");
      }
    }
  };

  ajax = function(options) {
    var async, data, header, method, prog, url, value, xhr, _i, _len, _ref, _ref1;
    if (!(options != null) && !options['url']) {
      console.log("no proper arguments!");
      return false;
    }
    url = options['url'];
    data = options['data'] != null ? options['data'] : null;
    method = options['method'] != null ? options['method'] : (data == null ? 'GET' : 'POST');
    async = options['async'] != null ? options['async'] : true;
    xhr = xhr_compatible();
    xhr.open(method, url, async);
    if (options['headers'] != null) {
      console.log('header');
      _ref = options['headers'];
      for (header in _ref) {
        value = _ref[header];
        console.log("" + header + " : " + value);
        try {
          xhr.setRequestHeader(header, value);
        } catch (e) {
          console.log("cannot set " + header + " to " + value);
          return false;
        }
      }
    }
    if (options['before'] != null) {
      try {
        options['before'](xhr);
      } catch (e) {
        console.log('error at execute beforeSend');
        return false;
      }
    }
    _ref1 = ['onload', 'onerror', 'onprogress'];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      prog = _ref1[_i];
      if (options[prog] != null) {
        xhr[prog] = (function() {
          var active;
          active = prog;
          return function(progressEvent) {
            return options[active](xhr, progressEvent);
          };
        })();
      }
    }
    xhr.onreadystatechanges = function() {
      var _ref2, _ref3;
      if (xhr.readyState === 4 && ((200 <= (_ref2 = xhr.status) && _ref2 < 300) || xhr.status === 304)) {
        try {
          if (options['onload'] != null) {
            options['onload'](xhr);
          }
        } catch (e) {
          console.log("onload handler error");
          return false;
        }
      }
      if (xhr.readyState === 4 && xhr.status >= 400) {
        try {
          if (options['error'] != null) {
            options['error'](xhr);
          }
        } catch (e) {
          console.log("error handler error");
          return false;
        }
      }
      console.log('progress cannot be mocked by xhr');
      if (options['spec'] != null) {
        if (_ref3 = '' + xhr.status, __indexOf.call(options['spec'], _ref3) >= 0) {
          try {
            return options['spec'](xhr);
          } catch (e) {
            console.log('spec error');
            return false;
          }
        }
      }
    };
    return xhr.send(data);
  };

  context.ajax = ajax;

  /*
  test =
      url     : 'http://www.baidu.com' #no relative path
      #method  : 'GET'
      before  : -> console.log 'before'
      headers :
          'content-type' : 'application/x-www-form-urlencoded;charset=UTF-8' #set data to form data
      onload  : -> console.log 'success'
      onerror : -> console.log 'error'
      onprogress : -> console.log 'working'
      data    :  'take it boy'
  
  ajax test
  */


  context = arguments[0] || window;

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
    var copy, height, width;
    if (!(imgEle != null) && imgEle.tagName !== 'IMG') {
      console.log('TypeError: Need a image object');
      return false;
    }
    if (!!canvasPrototype && (hasBlob() || !!BlobBuilder) && hasArrayBuffer()) {
      copy = imgEle.cloneNode();
      copy.removeAttribute('width');
      copy.removeAttribute('height');
      width = copy.width;
      height = copy.height;
      this.imageName = function() {
        try {
          return /[^\/]+\.[^\/]+$/.exec(copy.src)[0];
        } catch (e) {
          console.log('invalid name');
          return 'error';
        }
      };
      this.getByteString = function() {
        var byteString, canvas, dataUrl;
        try {
          canvas = document.createElement('canvas');
          context = canvas.getContext('2d');
          canvas.width = width;
          canvas.height = height;
          context.drawImage(copy, 0, 0);
          dataUrl = canvas.toDataURL();
          if (dataUrl.split(',')[0].indexOf('base64') !== -1) {
            return byteString = atob(dataUrl.split(',')[1]);
          } else {
            return byteString = atob(decodesURIComponent(dataUrl).split(',')[1]);
          }
        } catch (e) {
          byteString;

          ajax({
            method: "GET",
            url: copy.src,
            async: false,
            before: function(xhr) {
              xhr.overrideMimeType('text/plain; charset=x-user-defined');
              return true;
            },
            onload: function(resp) {
              return byteString = resp['responseText'];
            },
            onerror: function(resp) {
              throw 'cannot get image!';
            }
          });
          return byteString;
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
        renderedImg = copy.cloneNode();
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
        var arrayBuffer, bb, blobData, byteString, i, intArray, length, mimetype, _i;
        byteString = this.getByteString();
        length = byteString.length;
        arrayBuffer = new ArrayBuffer(length);
        intArray = new Uint8Array(arrayBuffer);
        for (i = _i = 0; 0 <= length ? _i <= length : _i >= length; i = 0 <= length ? ++_i : --_i) {
          intArray[i] = byteString.charCodeAt(i);
        }
        mimetype = (/\.(\w)+/.exec(this.imageName()))[1];
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
      };
    } else {
      console.log('no Blob or Canvas support! Change to a better browser?');
      return false;
    }
    return this;
  };

  context.canvasBlob = canvasBlob;

  context = arguments[0] || window;

  baseURL = "https://plus.google.com";

  authuser = 0;

  sparRequestLength = 45;

  imageInfoLength = 48;

  albumInfoLength = 48;

  spar34Length = 6;

  SPAR_34_MULTI = [250, 38, 35, 1, 0];

  SPAR_34_SINGLE = [249, 18, 1, 0];

  IMGOBJ_MULTI = "27847199";

  IMGOBJ_SINGLE = "27639957";

  IMGOBJ_PIC_ARRAY_SIZE = 14;

  BATCH_SIZE = 2;

  openSession = function(index, batchid) {
    var a, album, callback, fields, fileBlob, fileName, fileSize, requestData, self, sessionRequestFiled;
    fileName = this.imgList[index].imageName();
    fileBlob = this.imgList[index].toBlob();
    fileSize = fileBlob.size;
    album = this.album;
    self = this;
    callback = this.callbacks['open'];
    batchid = batchid.toString();
    this.currentUpload++;
    sessionRequestFiled = function(obj) {
      var content, name, _results;
      _results = [];
      for (name in obj) {
        content = obj[name];
        _results.push({
          "inlined": {
            "name": name,
            "content": content,
            "contentType": "text/plain"
          }
        });
      }
      return _results;
    };
    fields = [
      {
        "external": {
          "name": "file",
          "filename": fileName,
          "put": {},
          "size": fileSize
        }
      }
    ];
    if ((album != null) && album['albumID'] && album['childCount']) {
      a = {
        "disable_asbe_notification": "true",
        "use_upload_size_pref": "true",
        "title": fileName,
        "addtime": new Date().getTime().toString(),
        "batchid": batchid,
        "album_id": album['albumID'],
        "album_abs_position": (album['childCount'] + index).toString(),
        "client": "es-add-standalone-album"
      };
    } else {
      a = {
        "batchid": batchid,
        "client": "sharebox",
        "disable_asbe_notification": "true",
        "streamid": "updates",
        "use_upload_size_pref": "true",
        "album_abs_position": index.toString()
      };
    }
    requestData = {
      "protocolVersion": "0.8",
      "createSessionRequest": {
        "fields": fields.concat(sessionRequestFiled(a))
      }
    };
    return ajax({
      method: "POST",
      url: baseURL + "/_/upload/photos/resumable?authuser=" + authuser,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded;charset=utf-8",
        "x-guploader-client-info": "mechanism=scotty xhr resumable; clientVersion=42171334"
      },
      data: JSON.stringify(requestData),
      onload: function(resp) {
        var obj, uploadURL;
        obj = JSON.parse(resp["responseText"]);
        try {
          uploadURL = obj.sessionStatus.externalFieldTransfers[0].putInfo.url;
          console.log('openSession success');
          if (callback != null) {
            try {
              callback();
            } catch (e) {
              console.log('callback error');
            }
          }
          return self.uploadImage(fileBlob, uploadURL);
        } catch (e) {
          console.log(e);
          return console.log('openSession error');
        }
      }
    });
  };

  uploadImage = function(fileBlob, uploadURL) {
    var callback, self;
    callback = this.callbacks['upload'];
    self = this;
    return ajax({
      method: "POST",
      url: uploadURL,
      data: fileBlob,
      onload: function(resp) {
        var obj;
        obj = JSON.parse(resp['responseText']);
        if (obj["errorMessage"] != null) {
          console.log(obj["errorMessage"]["additionalInfo"]["uploader_service.GoogleRupioAdditionalInfo"]["requestRejectedInfo"]["reasonDescription"]);
        } else {
          console.log('upload success');
          if (callback != null) {
            try {
              callback();
            } catch (e) {
              console.log('callback error');
            }
          }
          self.customerInfo.push(obj["sessionStatus"]["additionalInfo"]["uploader_service.GoogleRupioAdditionalInfo"]["completionInfo"]["customerSpecificInfo"]);
        }
        return self.currentUpload--;
      }
    });
  };

  /*
  format
  postOption =
      comment : '' //String
      mention : ['123456789'] //array of UserID string
      disableComment : false //boolean
      lockPost : false //boolean
      circle : ['72cf18790d1b46b5'] // array of circleID string
      userID : '123456789' //string
      sessionID : 'AObSGbLaHBlAhbLAH:123456789' //session string
  */


  postImage = function(postOption) {
    var albumID, albumInfo, albumUrl, buffer, c, callback, height, image, imgObj, imgObjPics, imgs, info, m, newNullArray, photoID, photoPageUrl, reqid, sessionID, spam, spar, tempArray, title, url, userID, width, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1,
      _this = this;
    callback = this.callbacks['post'];
    userID = postOption['userID'];
    sessionID = postOption['sessionID'];
    newNullArray = function(length) {
      var i, _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
        _results.push(null);
      }
      return _results;
    };
    imgObjPics = function(isAlbum, isMulti) {
      var albumID, height, image, info, photoID, photoPageUrl, temp, title, url, width, _i, _len, _ref, _results;
      _ref = _this.customerInfo;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        info = _ref[_i];
        title = info["title"];
        url = info["url"];
        width = info["width"];
        height = info["height"];
        photoPageUrl = info["photoPageUrl"];
        albumID = info["albumid"];
        photoID = info["photoid"];
        image = newNullArray(IMGOBJ_PIC_ARRAY_SIZE);
        temp = newNullArray(9);
        temp[0] = url;
        temp[1] = width;
        temp[2] = height;
        temp[7] = height;
        temp[8] = [1, url];
        if (isAlbum) {
          temp[8][0] = 0;
        } else if (isMulti) {
          temp[3] = 1;
          temp[4] = 1;
        }
        image[0] = [photoPageUrl, title, "", url, null, temp, null, width.toString(), height.toString(), width, height, null, 'picasaweb.google.com'];
        image[1] = userID;
        image[3] = photoID;
        image[6] = url;
        if (isAlbum || isMulti) {
          image[7] = photoPageUrl;
        }
        image[9] = photoPageUrl;
        image[11] = "albumid=" + albumID + "&photoid=" + photoID;
        image[12] = 1;
        image[13] = [];
        _results.push(image);
      }
      return _results;
    };
    imgs = (function() {
      var _i, _len, _ref, _results;
      _ref = this.customerInfo;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        info = _ref[_i];
        title = info["title"];
        url = info["url"];
        width = info["width"];
        height = info["height"];
        photoPageUrl = info["photoPageUrl"];
        albumID = info["albumid"];
        photoID = info["photoid"];
        image = newNullArray(imageInfoLength);
        image[3] = '';
        image[5] = [null, url, width, height];
        image[9] = [];
        image[21] = title;
        image[24] = [null, photoPageUrl, null, "image/" + title.split('.')[1], "image"];
        image[41] = [];
        image[41][0] = [null, url, width, height];
        image[47] = [];
        image[47][0] = [null, "picasa", "http://google.com/profiles/media/provider", ""];
        image[47][1] = [albumID, photoID, photoPageUrl];
        _results.push(image);
      }
      return _results;
    }).call(this);
    spar = newNullArray(sparRequestLength);
    spar[0] = postOption['comment'];
    spar[1] = "oz:" + userID + "." + (new Date().getTime().toString(16)) + ".0";
    spar[3] = this.album != null ? this.album['albumID'] : this.customerInfo[0]['albumid'];
    spar[9] = true;
    spar[10] = (function() {
      var _i, _len, _ref, _results;
      _ref = postOption['mention'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        m = _ref[_i];
        _results.push([null, m]);
      }
      return _results;
    })();
    spar[14] = spar[36] = [];
    spar[11] = spar[16] = false;
    spar[19] = userID;
    spar[27] = postOption['disableComment'];
    spar[28] = postOption['lockPost'];
    spar[34] = newNullArray(spar34Length);
    spar[37] = [[], null];
    _ref = postOption['circle'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      spar[37][0].push([null, c]);
    }
    _ref1 = postOption['mention'];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      m = _ref1[_j];
      spar[37][0].push([null, null, m]);
    }
    spar[44] = "!A0JoSBi6oOwwzERUO9imjc2DBAIAAAB-UgAAABwq1gEi";
    if ((this.album != null) && (this.album['albumName'] != null)) {
      albumUrl = "https://plus.google.com/photos/" + userID + "/albums/" + this.album['albumID'];
      albumInfo = newNullArray(albumInfoLength);
      albumInfo[3] = this.album['albumName'];
      albumInfo[9] = [];
      if (this.album['albumSummary'] != null) {
        albumInfo[21] = this.album['albumSummary'];
      }
      albumInfo[24] = [null, albumUrl, null, "text/html", "document"];
      albumInfo[41] = [];
      albumInfo[47] = [];
      albumInfo[47][0] = [null, "picasa", "http://google.com/profiles/media/provider", ""];
      albumInfo[47][1] = [null, "0", "http://google.com/profiles/media/additional_metadata", "album_summary_type"];
      for (_k = 0, _len2 = imgs.length; _k < _len2; _k++) {
        image = imgs[_k];
        buffer = image[47][1];
        image[47][1] = [null, buffer[2], "http://google.com/profiles/media/container", ""];
        image[47][2] = [null, "albumid=" + buffer[0] + "&photoid=" + buffer[1], "http://google.com/profiles/media/onepick_media_id", ""];
      }
      spar[6] = JSON.stringify(albumInfo.concat(imgs));
      spar[16] = spar[32] = true;
      spar[29] = false;
      spar[34][0] = SPAR_34_MULTI;
      imgObj = {};
      tempArray = newNullArray(11);
      tempArray[0] = albumUrl;
      tempArray[1] = this.album['albumName'];
      tempArray[3] = imgObjPics(true);
      tempArray[4] = userID;
      tempArray[5] = this.album['albumID'];
      tempArray[8] = 0;
      tempArray[10] = "photos/" + userID + "/albums/" + this.album['albumID'];
      imgObj[IMGOBJ_MULTI] = tempArray;
    } else {
      for (_l = 0, _len3 = imgs.length; _l < _len3; _l++) {
        image = imgs[_l];
        image[41][1] = image[41][0];
        buffer = image[47][1];
        image[47][1] = [null, "albumid=" + buffer[0] + "&photoid=" + buffer[1], "http://google.com/profiles/media/onepick_media_id", ""];
      }
      spar[6] = JSON.stringify(imgs);
      spar[29] = true;
      if (imgs.length > 1) {
        spar[34][0] = SPAR_34_MULTI;
        imgObj = {};
        tempArray = newNullArray(9);
        tempArray[3] = imgObjPics(false, true);
        tempArray[4] = userID;
        tempArray[8] = 0;
        imgObj[IMGOBJ_MULTI] = tempArray;
      } else {
        spar[34][0] = SPAR_34_SINGLE;
        imgObj = {};
        imgObj[IMGOBJ_SINGLE] = (imgObjPics())[0];
      }
    }
    spar[34][spar34Length - 1] = imgObj;
    spam = this.album != null ? 24 : 20;
    reqid = +new Date() % 10000000;
    return ajax({
      method: 'POST',
      url: "" + baseURL + "/_/sharebox/post/?spam=" + spam + "&rt=j&_reqid=" + reqid,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded;charset=utf-8"
      },
      data: 'f.req=' + (encodeURIComponent(JSON.stringify(spar))) + ("&at=" + sessionID),
      onload: function(resp) {
        if (callback != null) {
          try {
            return callback(resp);
          } catch (e) {
            return console.log('callback error');
          }
        }
      }
    });
  };

  init = function() {
    var batchid, i, interval, uploadedAll, wait, _i, _ref,
      _this = this;
    batchid = +new Date();
    for (i = _i = 0, _ref = this.imgList.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      while (this.currentUpload > BATCH_SIZE) {
        true;
      }
      console.log('openSession!');
      this.openSession(i, batchid);
    }
    uploadedAll = function() {
      if (_this.imgList.length === _this.customerInfo.length) {
        clearInterval(wait);
        if (_this.callbacks['ready'] != null) {
          return _this.callbacks['ready']();
        }
      }
    };
    interval = (this.imgList[0].toBlob().size * this.imgList.length) >> 8;
    return wait = setInterval(uploadedAll, interval);
  };

  setCallbacks = function(callbacks) {
    var cb, cbList, _i, _len, _results;
    if (callbacks == null) {
      callbacks = {};
    }
    cbList = ['open', 'upload', 'ready', 'post'];
    if (typeof callbacks === "object") {
      _results = [];
      for (_i = 0, _len = cbList.length; _i < _len; _i++) {
        cb = cbList[_i];
        _results.push(this.callbacks[cb] = callbacks[cb]);
      }
      return _results;
    }
  };

  GpAPI = function(imgList, album) {
    if (album == null) {
      album = null;
    }
    if (imgList == null) {
      console.log('no Pics!');
      return false;
    }
    this.imgList = imgList;
    this.album = album;
    this.customerInfo = [];
    this.currentUpload = 0;
    this.callbacks = {};
    this.setCallbacks();
    return this;
  };

  GpAPI.prototype.openSession = openSession;

  GpAPI.prototype.uploadImage = uploadImage;

  GpAPI.prototype.postImage = postImage;

  GpAPI.prototype.setCallbacks = setCallbacks;

  GpAPI.prototype.init = init;

  context.GpAPI = GpAPI;

  messageHandler = function(message, sender, sendResponse) {
    var cand, candidates, cvsB, filename, graphicalInterface, postOption, target, targetUrl, upload, _i, _len;
    if (message['todo'] === 'execute') {
      targetUrl = message['target'];
      console.log(targetUrl);
      filename = /[^\/]+\.[^\/]+$/.exec(targetUrl);
      try {
        filename = "'" + filename[0] + "'";
      } catch (e) {
        console.log("cannot find proper name!");
        return true;
      }
      candidates = document.querySelectorAll("img[src$=" + filename + "]");
      for (_i = 0, _len = candidates.length; _i < _len; _i++) {
        cand = candidates[_i];
        if (cand.src === targetUrl) {
          target = cand;
          break;
        }
      }
      cvsB = new canvasBlob(target);
      upload = new GpAPI([cvsB]);
      upload.setCallbacks({
        open: function() {
          return console.log('open session');
        },
        upload: function() {
          return console.log('upload image');
        },
        ready: function() {
          console.log('ready');
          return upload.postImage(postOption);
        },
        post: function() {
          return console.log('try to post');
        }
      });
      postOption = {};
      graphicalInterface = function() {
        var bg, cancelButton, circleID, circleName, circleSlection, commentArea, crtEle, d, option, sendButton, sharebox, _ref;
        d = document;
        crtEle = 'createElement';
        bg = d[crtEle]('div');
        bg.id = 'GPic-Background';
        bg.style.width = "" + document.width + "px";
        bg.style.height = "" + document.height + "px";
        bg.style.backgroundColor = "rgba(255,255,255,0.8)";
        bg.style.position = "fixed";
        bg.style.top = "0";
        bg.style.zIndex = "999";
        sharebox = d[crtEle]('div');
        sharebox.id = 'GPic-Sharebox';
        sharebox.style.position = 'fixed';
        sharebox.style.top = '50%';
        sharebox.style.left = '50%';
        sharebox.style.margin = '-5em';
        commentArea = d[crtEle]('textarea');
        commentArea.placeholder = 'add comment';
        circleSlection = d[crtEle]('select');
        _ref = message['user']['circleInfo'];
        for (circleName in _ref) {
          circleID = _ref[circleName];
          option = d[crtEle]('option');
          option.appendChild(d['createTextNode'](circleName));
          option.value = circleID;
          circleSlection.add(option);
        }
        sendButton = d[crtEle]('button');
        cancelButton = d[crtEle]('button');
        sendButton.id = 'Gpic-send';
        cancelButton.id = 'Gpic-cancel';
        sendButton.appendChild(document.createTextNode('send'));
        cancelButton.appendChild(document.createTextNode('cancel'));
        sharebox.appendChild(commentArea);
        sharebox.appendChild(circleSlection);
        sharebox.appendChild(sendButton);
        sharebox.appendChild(cancelButton);
        bg.appendChild(sharebox);
        document.body.appendChild(bg);
        sendButton[addListener]('click', function() {
          postOption = {
            comment: commentArea.value,
            mention: [],
            disableComment: false,
            lockPost: false,
            circle: [circleSlection.options[circleSlection.selectedIndex].value],
            userID: message['user']['userID'],
            sessionID: message['user']['sessionID']
          };
          upload.init();
          document.body.removeChild(bg);
          return sendResponse();
        });
        return cancelButton[addListener]('click', function() {
          document.body.removeChild(bg);
          return sendResponse();
        });
      };
      graphicalInterface();
      return true;
    }
  };

  console.log('start Work!');

  chrome.extension.onMessage.addListener(messageHandler);

  window.onunload = function() {
    chrome.extension.sendMessage({
      unload: true
    });
    return console.log('unloaded');
  };

}).call(this);
