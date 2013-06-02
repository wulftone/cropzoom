###
CropZoom v1.3
CoffeeScript version
Release Date: June 1st, 2013

LICENSE: Dual licensed under the MIT || GPL Version 2 licenses.

New Author: Trevor Bortins (See comments for original authors)
###

#
# CropZoom v1.2
# Release Date: April 17, 2010
#
# Copyright (c) 2010 Gaston Robledo
#
(($) ->
  $.fn.cropzoom = (options) ->

    @each ->


      limitBounds = (ui) ->
        imageData = getData 'image'
        imageData.posY = 0  if ui.position.top > 0
        imageData.posX = 0  if ui.position.left > 0

        bottom = -(imageData.h - ui.helper.parent().parent().height())
        right = -(imageData.w - ui.helper.parent().parent().width())

        imageData.posY = bottom  if ui.position.top < bottom
        imageData.posX = right  if ui.position.left < right
        calculateTranslationAndRotation()


      getExtensionSource = ->
        parts = $options.image.source.split(".")
        parts[parts.length - 1]


      calculateFactor = ->
        imageData = getData 'image'
        imageData.scaleX = ($options.width / imageData.w)
        imageData.scaleY = ($options.height / imageData.h)


      getCorrectSizes = ->
        imageData = getData 'image'

        if $options.image.startZoom != 0
          zoomInPx_width = (($options.image.width * Math.abs($options.image.startZoom)) / 100)
          zoomInPx_height = (($options.image.height * Math.abs($options.image.startZoom)) / 100)
          imageData.h = zoomInPx_height
          imageData.w = zoomInPx_width

          #Checking if the position was set before
          if imageData.posY != 0 && imageData.posX != 0

            if imageData.h > $options.height
              imageData.posY = Math.abs(($options.height / 2) - (imageData.h / 2))
            else
              imageData.posY = (($options.height / 2) - (imageData.h / 2))

            if imageData.w > $options.width
              imageData.posX = Math.abs(($options.width / 2) - (imageData.w / 2))
            else
              imageData.posX = (($options.width / 2) - (imageData.w / 2))

        else
          scaleX = imageData.scaleX
          scaleY = imageData.scaleY

          if scaleY < scaleX
            imageData.h = $options.height
            imageData.w = Math.round(imageData.w * scaleY)
          else
            imageData.h = Math.round(imageData.h * scaleX)
            imageData.w = $options.width

        # Disable snap to container if == little
        $options.image.snapToContainer = false  if imageData.w < $options.width && imageData.h < $options.height
        calculateTranslationAndRotation()


      calculateTranslationAndRotation = ->
        $ ->
          imageData = getData 'image'
          adjustingSizesInRotation()
          rotation = "rotate(" + imageData.rotation + "deg)"

          $($image).css
            transform: rotation
            "-webkit-transform": rotation
            "-ms-transform": rotation
            msTransform: rotation
            top: imageData.posY
            left: imageData.posX


      createRotationButtons = ->
        rotationContainerButtons = $("<div>").attr("id", "rotationContainerButtons")
        value = Math.abs(360 - $options.image.rotation)

        if $options.expose.clockwiseElement != ""
          $clockwiseButton = $($options.expose.clockwiseElement)
        else
          $clockwiseButton = $("<div>").attr("id", "clockwiseButton")

        if $options.expose.counterClockwiseElement != ""
          $counterClockwiseButton = $($options.expose.counterClockwiseElement)
        else
          $counterClockwiseButton = $("<div>").attr("id", "counterClockwiseButton")

        buttons = $([$clockwiseButton[0], $counterClockwiseButton[0]])
        buttons.css
          cursor: 'pointer'

        handleButtonClick = (event, ui) ->
          angle = 0
          rotation = 0
          direction = event.currentTarget.id
          imageData = getData 'image'

          if direction.search("counter") >= 0
            angle = imageData.rotation - 90
          else
            angle = imageData.rotation + 90

          if angle >= 360
            rotation = angle - 360
          else if angle < 0
            rotation = angle + 360
          else
            rotation = angle

          imageData.rotation = rotation
          calculateTranslationAndRotation()

          if $options.image.onRotate != null
            $options.image.onRotate $clockwiseButton, imageData.rotation
            $options.image.onRotate $counterClockwiseButton, imageData.rotation


        $clockwiseButton.click handleButtonClick
        $counterClockwiseButton.click handleButtonClick
        rotationContainerButtons.append $clockwiseButton
        rotationContainerButtons.append $counterClockwiseButton

        if $options.expose.rotationElement != ""
          $($options.expose.rotationElement).empty().append rotationContainerButtons
        else
          rotationContainerButtons.css
            position: "absolute"
            top: 5
            left: 5
            opacity: 0.6

          _self.append rotationContainerButtons


      createRotationSlider = ->
        rotationContainerSlider = $("<div>").attr("id", "rotationContainer").mouseover(->
          $(this).css "opacity", 1
        ).mouseout(->
          $(this).css "opacity", 0.6
        )

        rotMin = $("<div>").attr("id", "rotationMin").html("0")
        rotMax = $("<div>").attr("id", "rotationMax").html("360")
        $slider = $("<div>").attr("id", "rotationSlider")
        orientation = "vertical"
        value = Math.abs(360 - $options.image.rotation)

        if $options.expose.slidersOrientation == "horizontal"
          orientation = "horizontal"
          value = $options.image.rotation


        handleRotationSlide = (event, ui) ->
          imageData = getData 'image'
          imageData.rotation = ((if value == 360 then Math.abs(360 - ui.value) else Math.abs(ui.value)))

          calculateTranslationAndRotation()

          $options.image.onRotate $slider, imageData.rotation  if $options.image.onRotate != null


        $slider.slider
          orientation: orientation
          value: value
          range: "max"
          min: 0
          max: 360
          step: ((if ($options.rotationSteps > 360 || $options.rotationSteps < 0) then 1 else $options.rotationSteps))
          slide: handleRotationSlide

        rotationContainerSlider.append rotMin
        rotationContainerSlider.append $slider
        rotationContainerSlider.append rotMax

        if $options.expose.rotationElement != ""
          $slider.addClass $options.expose.slidersOrientation
          rotationContainerSlider.addClass $options.expose.slidersOrientation
          rotMin.addClass $options.expose.slidersOrientation
          rotMax.addClass $options.expose.slidersOrientation
          $($options.expose.rotationElement).empty().append rotationContainerSlider

        else
          $slider.addClass "vertical"
          rotationContainerSlider.addClass "vertical"
          rotMin.addClass "vertical"
          rotMax.addClass "vertical"

          rotationContainerSlider.css
            position: "absolute"
            top: 5
            left: 5
            opacity: 0.6

          _self.append rotationContainerSlider


      createZoomSlider = ->
        zoomContainerSlider = $("<div>").attr("id", "zoomContainer").mouseover(->
          $(this).css "opacity", 1
        ).mouseout(->
          $(this).css "opacity", 0.6
        )

        zoomMin = $("<div>").attr("id", "zoomMin").html("<b>-</b>")
        zoomMax = $("<div>").attr("id", "zoomMax").html("<b>+</b>")
        $slider = $("<div>").attr("id", "zoomSlider")

        # Apply Slider
        imageData = getData 'image'
        $slider.slider
          orientation: ((if $options.expose.zoomElement != "" then $options.expose.slidersOrientation else "vertical"))
          value: ((if $options.image.startZoom != 0 then $options.image.startZoom else getPercentOfZoom(imageData)))
          min: ((if $options.image.useStartZoomAsMinZoom then $options.image.startZoom else $options.image.minZoom))
          max: $options.image.maxZoom
          step: ((if ($options.zoomSteps > $options.image.maxZoom || $options.zoomSteps < 0) then 1 else $options.zoomSteps))

          slide: (event, ui) ->
            value = ((if $options.expose.slidersOrientation == "vertical" then ($options.image.maxZoom - ui.value) else ui.value))
            zoomInPx_width = ($options.image.width * Math.abs(value) / 100)
            zoomInPx_height = ($options.image.height * Math.abs(value) / 100)

            $($image).css
              width: zoomInPx_width + "px"
              height: zoomInPx_height + "px"

            difX = (imageData.w / 2) - (zoomInPx_width / 2)
            difY = (imageData.h / 2) - (zoomInPx_height / 2)
            newX = ((if difX > 0 then imageData.posX + Math.abs(difX) else imageData.posX - Math.abs(difX)))
            newY = ((if difY > 0 then imageData.posY + Math.abs(difY) else imageData.posY - Math.abs(difY)))

            imageData.posX = newX
            imageData.posY = newY
            imageData.w = zoomInPx_width
            imageData.h = zoomInPx_height

            calculateFactor()
            calculateTranslationAndRotation()

            $options.image.onZoom $image, imageData  if $options.image.onZoom != null


        if $options.slidersOrientation == "vertical"
          zoomContainerSlider.append zoomMax
          zoomContainerSlider.append $slider
          zoomContainerSlider.append zoomMin
        else
          zoomContainerSlider.append zoomMin
          zoomContainerSlider.append $slider
          zoomContainerSlider.append zoomMax

        if $options.expose.zoomElement != ""
          zoomMin.addClass $options.expose.slidersOrientation
          zoomMax.addClass $options.expose.slidersOrientation
          $slider.addClass $options.expose.slidersOrientation
          zoomContainerSlider.addClass $options.expose.slidersOrientation
          $($options.expose.zoomElement).empty().append zoomContainerSlider
        else
          zoomMin.addClass "vertical"
          zoomMax.addClass "vertical"
          $slider.addClass "vertical"
          zoomContainerSlider.addClass "vertical"

          zoomContainerSlider.css
            position: "absolute"
            top: 5
            right: 5
            opacity: 0.6

          _self.append zoomContainerSlider


      getPercentOfZoom = ->
        percent = 0
        imageData = getData 'image'

        if imageData.w > imageData.h
          percent = $options.image.maxZoom - ((imageData.w * 100) / $options.image.width)
        else
          percent = $options.image.maxZoom - ((imageData.h * 100) / $options.image.height)

        percent


      createSelector = ->
        selectorData = getData 'selector'
        if $options.selector.centered
          selectorData.y = ($options.height / 2) - (selectorData.h / 2)
          selectorData.x = ($options.width / 2) - (selectorData.w / 2)

        $selector = $("<div/>").attr("id", _self[0].id + "_selector").css(
          width: selectorData.w
          height: selectorData.h
          top: selectorData.y + "px"
          left: selectorData.x + "px"
          border: $options.selector.border
          "border-radius": $options.selector.borderRadius
          position: "absolute"
          cursor: "move"
          "pointer-events": ((if $options.selector.draggableThroughCrop then "none" else "auto"))
        ).mouseover(->
          $(this).css border: $options.selector.borderHover
        ).mouseout(->
          $(this).css border: $options.selector.border
        )

        # Add draggable to the selector
        if $options.selector.draggable
          $selector.draggable
            containment: "parent"
            iframeFix: true
            refreshPositions: true

            drag: (event, ui) ->
              selectorData = getData 'selector'

              # Update position of the overlay
              selectorData.x = ui.position.left
              selectorData.y = ui.position.top
              makeOverlayPositions ui
              showInfo()
              $options.selector.onSelectorDrag $selector, selectorData  if $options.selector.onSelectorDrag != null

            stop: (event, ui) ->
              selectorData = getData 'selector'
              hideOverlay()  if $options.selector.hideOverlayOnDragAndResize
              $options.selector.onSelectorDragStop $selector, selectorData  if $options.selector.onSelectorDragStop != null

        if $options.selector.resizeable
          $selector.resizable
            aspectRatio: $options.selector.aspectRatio
            maxHeight: $options.selector.maxHeight
            maxWidth: $options.selector.maxWidth
            minHeight: $options.selector.h
            minWidth: $options.selector.w
            containment: "parent"

            resize: (event, ui) ->
              selectorData = getData 'selector'

              # update ovelay position
              selectorData.w = $selector.width()
              selectorData.h = $selector.height()
              makeOverlayPositions ui
              showInfo()
              $options.selector.onSelectorResize $selector, selectorData  if $options.selector.onSelectorResize != null

            stop: (event, ui) ->
              selectorData = getData 'selector'
              hideOverlay()  if $options.selector.hideOverlayOnDragAndResize
              $options.selector.onSelectorResizeStop $selector, selectorData  if $options.selector.onSelectorResizeStop != null

        showInfo $selector  if $options.selector.showInfo

        # add selector to the main container
        _self.append $selector


      showInfo = ->
        alreadyAdded = false

        if $selector.find("#infoSelector").length > 0
          _infoView = $selector.find("#infoSelector")
        else
          _infoView = $("<div>").attr("id", "infoSelector").css(
            position: "absolute"
            top: 0
            left: 0
            background: $options.selector.bgInfoLayer
            opacity: 0.6
            "font-size": $options.selector.infoFontSize + "px"
            "font-family": "Arial"
            color: $options.selector.infoFontColor
            width: "100%"
          )

        selectorData = getData 'selector'

        if $options.selector.showPositionsOnDrag
          _infoView.html "X:" + Math.round(selectorData.x) + "px - Y:" + Math.round(selectorData.y) + "px"
          alreadyAdded = true

        if $options.selector.showDimetionsOnDrag

          if alreadyAdded
            _infoView.html _infoView.html() + " | W:" + selectorData.w + "px - H:" + selectorData.h + "px"
          else
            _infoView.html "W:" + selectorData.w + "px - H:" + selectorData.h + "px"

        $selector.append _infoView


      createOverlay = ->
        arr = ["t", "b", "l", "r"]

        $.each arr, ->
          divO = $("<div>").attr("id", this).css(
            overflow: "hidden"
            background: $options.overlayColor
            opacity: 0.6
            position: "absolute"
            "z-index": 2
            visibility: "visible"
          )

          _self.append divO


      makeOverlayPositions = (ui) ->
        _self.find("#t").css
          display: "block"
          width: $options.width
          height: ui.position.top
          left: 0
          top: 0

        _self.find("#b").css
          display: "block"
          width: $options.width
          height: $options.height
          top: (ui.position.top + $selector.height()) + "px"
          left: 0

        _self.find("#l").css
          display: "block"
          left: 0
          top: ui.position.top
          width: ui.position.left
          height: $selector.height()

        _self.find("#r").css
          display: "block"
          top: ui.position.top
          left: (ui.position.left + $selector.width()) + "px"
          width: $options.width
          height: $selector.height() + "px"


      hideOverlay = ->
        _self.find("#t").hide()
        _self.find("#b").hide()
        _self.find("#l").hide()
        _self.find("#r").hide()


      setData = (key, data) ->
        _self.data key, data


      getData = (key) ->
        _self.data key


      adjustingSizesInRotation = ->
        imageData = getData 'image'
        angle = imageData.rotation * Math.PI / 180
        sin = Math.sin(angle)
        cos = Math.cos(angle)

        # (0,0) stays as (0, 0)

        # (w,0) rotation
        x1 = cos * imageData.w
        y1 = sin * imageData.w

        # (0,h) rotation
        x2 = -sin * imageData.h
        y2 = cos * imageData.h

        # (w,h) rotation
        x3 = cos * imageData.w - sin * imageData.h
        y3 = sin * imageData.w + cos * imageData.h
        minX = Math.min(0, x1, x2, x3)
        maxX = Math.max(0, x1, x2, x3)
        minY = Math.min(0, y1, y2, y3)
        maxY = Math.max(0, y1, y2, y3)

        imageData.rotW = maxX - minX
        imageData.rotH = maxY - minY
        imageData.rotY = minY
        imageData.rotX = minX


      createMovementControls = ->
        table_html = ["<table>", "<tr>", "<td></td>", "<td></td>", "<td></td>", "</tr>", "<tr>", "<td></td>", "<td></td>", "<td></td>", "</tr>", "<tr>", "<td></td>", "<td></td>", "<td></td>", "</tr>", "</table>"].join("\n")
        table = $(table_html)
        btns = []

        btns.push $("<div>").addClass("mvn_no mvn")
        btns.push $("<div>").addClass("mvn_n mvn")
        btns.push $("<div>").addClass("mvn_ne mvn")
        btns.push $("<div>").addClass("mvn_o mvn")
        btns.push $("<div>").addClass("mvn_c")
        btns.push $("<div>").addClass("mvn_e mvn")
        btns.push $("<div>").addClass("mvn_so mvn")
        btns.push $("<div>").addClass("mvn_s mvn")
        btns.push $("<div>").addClass("mvn_se mvn")

        i = 0

        while i < btns.length
          btns[i].mousedown(->
            moveImage this
          ).mouseup(->
            clearTimeout tMovement
          ).mouseout ->
            clearTimeout tMovement

          table.find("td:eq(" + i + ")").append btns[i]
          $($options.expose.elementMovement).empty().append table
          i++


      moveImage = (obj) ->
        imageData = getData 'image'
        if $(obj).hasClass("mvn_no")
          imageData.posX = (imageData.posX - $options.expose.movementSteps)
          imageData.posY = (imageData.posY - $options.expose.movementSteps)

        else if $(obj).hasClass("mvn_n")
          imageData.posY = (imageData.posY - $options.expose.movementSteps)

        else if $(obj).hasClass("mvn_ne")
          imageData.posX = (imageData.posX + $options.expose.movementSteps)
          imageData.posY = (imageData.posY - $options.expose.movementSteps)

        else if $(obj).hasClass("mvn_o")
          imageData.posX = (imageData.posX - $options.expose.movementSteps)

        else if $(obj).hasClass("mvn_c")
          imageData.posX = ($options.width / 2) - (imageData.w / 2)
          imageData.posY = ($options.height / 2) - (imageData.h / 2)

        else if $(obj).hasClass("mvn_e")
          imageData.posX = (imageData.posX + $options.expose.movementSteps)

        else if $(obj).hasClass("mvn_so")
          imageData.posX = (imageData.posX - $options.expose.movementSteps)
          imageData.posY = (imageData.posY + $options.expose.movementSteps)

        else if $(obj).hasClass("mvn_s")
          imageData.posY = (imageData.posY + $options.expose.movementSteps)

        else if $(obj).hasClass("mvn_se")
          imageData.posX = (imageData.posX + $options.expose.movementSteps)
          imageData.posY = (imageData.posY + $options.expose.movementSteps)

        if $options.image.snapToContainer
          imageData.posY = 0  if imageData.posY > 0
          imageData.posX = 0  if imageData.posX > 0
          bottom = -(imageData.h - _self.height())
          right = -(imageData.w - _self.width())
          imageData.posY = bottom  if imageData.posY < bottom
          imageData.posX = right  if imageData.posX < right

        calculateTranslationAndRotation()

        tMovement = setTimeout(->
          moveImage obj
        , 100)


      defaults =
        width: 500
        height: 375
        bgColor: "#000"
        overlayColor: "#000"

        selector:
          x: 0
          y: 0
          w: 229
          h: 100
          aspectRatio: false
          centered: false
          border: null
          borderColor: "yellow"
          borderColorHover: "red"
          borderHover: null
          borderRadius: null
          bgInfoLayer: "#FFF"
          draggable: true
          draggableThroughCrop: true
          infoFontSize: 10
          infoFontColor: "blue"
          resizable: true
          showInfo: false
          showPositionsOnDrag: true
          showDimetionsOnDrag: true
          maxHeight: null
          maxWidth: null
          startWithOverlay: false

          hideOverlayOnDragAndResize: true
          onSelectorDrag: null
          onSelectorDragStop: null
          onSelectorResize: null
          onSelectorResizeStop: null

        image:
          source: ""
          rotation: 0
          width: 0
          height: 0
          minZoom: 10
          maxZoom: 150
          startZoom: 0
          x: 0
          y: 0
          useStartZoomAsMinZoom: false
          snapToContainer: false
          onZoom: null
          onRotate: null
          onImageDrag: null

        enableRotation: true
        enableZoom: true
        zoomSteps: 1
        rotationSteps: 5
        useRotationButtons: false # false => slider, true => buttons

        expose:
          slidersOrientation: "vertical"
          zoomElement: ""
          rotationElement: ""
          clockwiseElement: ""
          counterClockwiseElement: ""
          elementMovement: ""
          movementSteps: 5

      $options = $.extend(true, defaults, options)

      #Preserve options
      if !$.isFunction($.fn.draggable) || !$.isFunction($.fn.resizable) || !$.isFunction($.fn.slider)
        alert "You must include ui.draggable, ui.resizable and ui.slider to use cropZoom"
        return

      if $options.image.source == "" || $options.image.width == 0 || $options.image.height == 0
        alert "You must set the source, witdth and height of the image element"
        return

      _self = $(this)

      setData "options", $options

      _self.empty()
      _self.css
        width: $options.width
        height: $options.height
        "background-color": $options.bgColor
        overflow: "hidden"
        position: "relative"
        border: "2px solid #333"

      setData "image",
        h: $options.image.height
        w: $options.image.width
        posY: $options.image.y
        posX: $options.image.x
        scaleX: 0
        scaleY: 0
        rotation: $options.image.rotation
        source: $options.image.source
        bounds: [0, 0, 0, 0]
        id: "image_to_crop_" + _self[0].id

      calculateFactor()
      getCorrectSizes()

      setData "selector",
        x: $options.selector.x
        y: $options.selector.y
        w: ((if $options.selector.maxWidth != null then ((if $options.selector.w > $options.selector.maxWidth then $options.selector.maxWidth else $options.selector.w)) else $options.selector.w))
        h: ((if $options.selector.maxHeight != null then ((if $options.selector.h > $options.selector.maxHeight then $options.selector.maxHeight else $options.selector.h)) else $options.selector.h))

      $container = $("<div>").attr("id", "k").css(
        width: $options.width
        height: $options.height
        position: "absolute"
      )

      $image = $("<img>").addClass 'cropzoom-grab'
      $image.attr "src", $options.image.source

      imageData = getData 'image'
      $($image).css
        position: "absolute"
        left: imageData.posX
        top: imageData.posY
        width: imageData.w
        height: imageData.h

      ext = getExtensionSource()

      $image.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + $options.image.source + "',sizingMethod='scale');"  if ext == "png" || ext == "gif"

      $container.append $image

      _self.append $container

      calculateTranslationAndRotation()

      # adding draggable to the image
      $($image).draggable
        refreshPositions: true

        drag: (event, ui) ->
          $i = $ event.target
          $i.removeClass('cropzoom-grab').addClass 'cropzoom-grabbing'

          imageData = getData 'image'
          imageData.posY = ui.position.top
          imageData.posX = ui.position.left

          if $options.image.snapToContainer
            limitBounds ui
          else
            calculateTranslationAndRotation()

          # Fire the callback
          $options.image.onImageDrag $image  if $options.image.onImageDrag != null

        stop: (event, ui) ->
          $i = $ event.target
          $i.removeClass('cropzoom-grabbing').addClass 'cropzoom-grab'

          limitBounds ui  if $options.image.snapToContainer

      createSelector()

      _self.find(".ui-icon-gripsmall-diagonal-se").css
        background: "#FFF"
        border: "1px solid #000"
        width: 8
        height: 8

      createOverlay()

      if $options.selector.startWithOverlay
        ui_object = position:
          top: $selector.position().top
          left: $selector.position().left

        makeOverlayPositions ui_object

      createZoomSlider()  if $options.enableZoom

      if $options.enableRotation

        if $options.useRotationButtons
          createRotationButtons()
        else
          createRotationSlider()

      createMovementControls()  if $options.expose.elementMovement != ""

      $.fn.cropzoom.getParameters = (_self, custom) ->
        image = _self.data("image")
        selector = _self.data("selector")
        fixed_data =
          viewPortW: _self.width()
          viewPortH: _self.height()
          imageX: image.posX
          imageY: image.posY
          imageRotate: image.rotation
          imageW: image.w
          imageH: image.h
          imageSource: image.source
          selectorX: selector.x
          selectorY: selector.y
          selectorW: selector.w
          selectorH: selector.h

        $.extend fixed_data, custom

      $.fn.cropzoom.getSelf = ->
        _self

      # $.fn.cropzoom.getOptions = ->
      #   _self.getData('options')

      this


  # Css Hooks
  #
  #   * jQuery.cssHooks["MsTransform"] = { set: function( elem, value ) {
  #   * elem.style.msTransform = value; } };
  #
  $.fn.extend

    ###
    Function to set the image position and zoom.

    Internally, `imageData` sets the values that get passed back and
    forth between the relevant calculations.  Displaying changes is done
    entirely by modifying the css of the image.

    @param x [Number] X-coordinate for top-left of crop area
    @param y [Number] Y-coordinate for top-left of crop area
    @param z [Number] Zoom amount
    @param r [Number] Rotation angle
    ###
    setImage: (x, y, z, r) ->
      _self = $(this)
      imageData = _self.data 'image'
      $image = _self.find "img[src='#{imageData.source}']"


      # Position
      imageData.posX = x
      imageData.posY = y


      # Zoom
      width = $image[0].naturalWidth
      height = $image[0].naturalHeight

      w = z * width
      h = z * height

      imageData.w = w
      imageData.h = h
      imageData.scaleX = (width / w)
      imageData.scaleY = (height / h)


      # Rotation
      imageData.rotation = r
      angle = imageData.rotation * Math.PI / 180
      sin = Math.sin(angle)
      cos = Math.cos(angle)

      # (0,0) stays as (0, 0)

      # (w,0) rotation
      x1 = cos * imageData.w
      y1 = sin * imageData.w

      # (0,h) rotation
      x2 = -sin * imageData.h
      y2 = cos * imageData.h

      # (w,h) rotation
      x3 = cos * imageData.w - sin * imageData.h
      y3 = sin * imageData.w + cos * imageData.h
      minX = Math.min(0, x1, x2, x3)
      maxX = Math.max(0, x1, x2, x3)
      minY = Math.min(0, y1, y2, y3)
      maxY = Math.max(0, y1, y2, y3)

      imageData.rotW = maxX - minX
      imageData.rotH = maxY - minY
      imageData.rotY = minY
      imageData.rotX = minX

      rotation = "rotate(" + imageData.rotation + "deg)"

      # Apply changes to CSS so the user can see them.
      $image.css
        transform: rotation
        "-webkit-transform": rotation
        "-ms-transform": rotation
        msTransform: rotation
        top: imageData.posY
        left: imageData.posX
        width: w + "px"
        height: h + "px"


    ###
    Function to set the selector position and sizes

    @param x [Number] X-coordinate for top-left of crop area
    @param y [Number] Y-coordinate for top-left of crop area
    @param w [Number] Width of crop area
    @param h [Number] Height of crop area
    @param animate [Boolean] To animate the transition or not `true/false`
    ###
    setSelector: (x, y, w, h, animate) ->
      _self = $(this)
      selector = _self.find("#" + _self[0].id + "_selector")

      if animate != `undefined` && animate == true
        selector.animate
          top: y
          left: x
          width: w
          height: h
        , "slow"

      else
        selector.css
          top: y
          left: x
          width: w
          height: h

      _self.data "selector",
        x: x
        y: y
        w: w
        h: h


    ###
    Restore the plugin, re-setting it to its initial state.
    ###
    restore: ->
      obj = $(this)
      $options = obj.data("options")

      obj.empty()
      obj.data "image", {}
      obj.data "selector", {}

      $($options.expose.zoomElement).empty()  if $options.expose.zoomElement != ""
      $($options.expose.rotationElement).empty()  if $options.expose.rotationElement != ""
      $($options.expose.elementMovement).empty()  if $options.expose.elementMovement != ""

      obj.cropzoom $options


    ###
    Instead of sending to the server with {send}, you can just export
    the data crop/zoom/rotate data with this function.

    @return [Object] Parameters object containing all the crop info
    ###
    export: (custom) ->
      _self = $(this)
      _self.cropzoom.getParameters _self, custom


    ###
    Send the data to the server

    @param url [String] The target url where you'll do your processing
    @param type [String] e.g. 'POST'
    @param custom [Object]
    @param onSuccess [Function] Success callback function
    ###
    send: (url, type, custom, onSuccess) ->
      _self = $(this)
      response = ""

      $.ajax
        url: url
        type: type
        data: (_self.cropzoom.getParameters(_self, custom))
        success: (r) ->
          _self.data "imageResult", r
          onSuccess r  if onSuccess != `undefined` && onSuccess != null

) jQuery

#Adding touch fix

#!
# * jQuery UI Touch Punch 0.2.2
# *
# * Copyright 2011, Dave Furfero
# * Dual licensed under the MIT || GPL Version 2 licenses.
# *
# * Depends:
# * jquery.ui.widget.js
# * jquery.ui.mouse.js
#
(($) ->

  # Detect touch support

  # Ignore browsers without touch support

  ###
  Simulate a mouse event based on a corresponding touch event
  @param {Object} event A touch event
  @param {String} simulatedType The corresponding mouse event
  ###
  simulateMouseEvent = (event, simulatedType) ->

    # Ignore multi-touch events
    return  if event.originalEvent.touches.length > 1
    event.preventDefault()
    touch = event.originalEvent.changedTouches[0]
    simulatedEvent = document.createEvent("MouseEvents")

    # Initialize the simulated mouse event using the touch event's coordinates
    # type
    # bubbles
    # cancelable
    # view
    # detail
    # screenX
    # screenY
    # clientX
    # clientY
    # ctrlKey
    # altKey
    # shiftKey
    # metaKey
    # button
    simulatedEvent.initMouseEvent simulatedType, true, true, window, 1, touch.screenX, touch.screenY, touch.clientX, touch.clientY, false, false, false, false, 0, null # relatedTarget

    # Dispatch the simulated event to the target element
    event.target.dispatchEvent simulatedEvent

  $.support.touch = "ontouchend" of document

  return  unless $.support.touch

  mouseProto = $.ui.mouse::
  _mouseInit = mouseProto._mouseInit
  touchHandled = undefined

  ###
  Handle the jQuery UI widget's touchstart events
  @param {Object} event The widget element's touchstart event
  ###
  mouseProto._touchStart = (event) ->
    self = this

    # Ignore the event if another widget == already being handled
    return  if touchHandled || !self._mouseCapture(event.originalEvent.changedTouches[0])

    # Set the flag to prevent other widgets from inheriting the touch event
    touchHandled = true

    # Track movement to determine if interaction was a click
    self._touchMoved = false

    # Simulate the mouseover event
    simulateMouseEvent event, "mouseover"

    # Simulate the mousemove event
    simulateMouseEvent event, "mousemove"

    # Simulate the mousedown event
    simulateMouseEvent event, "mousedown"


  ###
  Handle the jQuery UI widget's touchmove events
  @param {Object} event The document's touchmove event
  ###
  mouseProto._touchMove = (event) ->

    # Ignore event if !handled
    return  unless touchHandled

    # Interaction was !a click
    @_touchMoved = true

    # Simulate the mousemove event
    simulateMouseEvent event, "mousemove"


  ###
  Handle the jQuery UI widget's touchend events
  @param {Object} event The document's touchend event
  ###
  mouseProto._touchEnd = (event) ->

    # Ignore event if !handled
    return  unless touchHandled

    # Simulate the mouseup event
    simulateMouseEvent event, "mouseup"

    # Simulate the mouseout event
    simulateMouseEvent event, "mouseout"

    # If the touch interaction did !move, it should trigger a click

    # Simulate the click event
    simulateMouseEvent event, "click"  unless @_touchMoved

    # Unset the flag to allow other widgets to inherit the touch event
    touchHandled = false


  ###
  A duck punch of the $.ui.mouse _mouseInit method to support touch events.
  This method extends the widget with bound touch event handlers that
  translate touch events to mouse events and pass them to the widget's
  original mouse event handling methods.
  ###
  mouseProto._mouseInit = ->
    self = this

    # Delegate the touch handlers to the widget's element
    self.element.bind("touchstart", $.proxy(self, "_touchStart")).bind("touchmove", $.proxy(self, "_touchMove")).bind "touchend", $.proxy(self, "_touchEnd")

    # Call the original $.ui.mouse init method
    _mouseInit.call self

) jQuery
