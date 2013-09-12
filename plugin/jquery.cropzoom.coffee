###
TODO: Find out why it jumps when you drag the image, the original cropzoom doesn't--
  it only jumps in the 90 and 270 rotation positions, maybe related to width and height issues
TODO: Find out how to rotate with the crop area as the centerpoint instead of the image (new feature)
###

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
        calculateTranslationAndRotation imageData


      getExtensionSource = ->
        parts = opt.image.source.split(".")
        parts[parts.length - 1]


      calculateFactor = ->
        imageData = getData 'image'
        imageData.scaleX = (opt.width / imageData.w)
        imageData.scaleY = (opt.height / imageData.h)


      getCorrectSizes = ->
        imageData = getData 'image'

        if opt.image.startZoom != 0
          zoomInPx_width = ((opt.image.width * Math.abs(opt.image.startZoom)) / 100)
          zoomInPx_height = ((opt.image.height * Math.abs(opt.image.startZoom)) / 100)
          imageData.h = zoomInPx_height
          imageData.w = zoomInPx_width

          #Checking if the position was set before
          if imageData.posY != 0 && imageData.posX != 0

            if imageData.h > opt.height
              imageData.posY = Math.abs((opt.height / 2) - (imageData.h / 2))
            else
              imageData.posY = ((opt.height / 2) - (imageData.h / 2))

            if imageData.w > opt.width
              imageData.posX = Math.abs((opt.width / 2) - (imageData.w / 2))
            else
              imageData.posX = ((opt.width / 2) - (imageData.w / 2))

        else
          scaleX = imageData.scaleX
          scaleY = imageData.scaleY

          if scaleY < scaleX
            imageData.h = opt.height
            imageData.w = Math.round(imageData.w * scaleY)
          else
            imageData.h = Math.round(imageData.h * scaleX)
            imageData.w = opt.width

        # Disable snap to container if == little
        opt.image.snapToContainer = false  if imageData.w < opt.width && imageData.h < opt.height
        calculateTranslationAndRotation imageData


      ###
      This appears to mutate the imageData during a rotation maneuver

      @param imageData [Object] The object that contains all of the rotation info
      ###
      adjustingSizesInRotation = (imageData) ->
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


      ###
      Calculates the CSS rotation transform and the CSS translation for the image
      and mutates the imageData object

      @param imageData [Object] The object that contains all of the rotation and translation info
      ###
      calculateTranslationAndRotation = (imageData) ->
        $ ->
          if $image
            adjustingSizesInRotation imageData
            rotation = "rotate(" + imageData.rotation + "deg)"

            $image.css
              transform: rotation
              "-webkit-transform": rotation
              "-ms-transform": rotation
              msTransform: rotation
              top: imageData.posY
              left: imageData.posX


      ###
      Create buttons that, when clicked, rotate the image
      ###
      createRotationButtons = ->
        rotationContainerButtons = $("<div>").attr("id", "rotationContainerButtons")
        value = Math.abs(360 - opt.image.rotation)

        if opt.expose.clockwiseElement != ""
          $clockwiseButton = $(opt.expose.clockwiseElement)
        else
          $clockwiseButton = $("<div>").attr("id", "clockwiseButton")

        if opt.expose.counterClockwiseElement != ""
          $counterClockwiseButton = $(opt.expose.counterClockwiseElement)
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
          calculateTranslationAndRotation imageData

          if opt.image.onRotate != null
            opt.image.onRotate $clockwiseButton, imageData.rotation
            opt.image.onRotate $counterClockwiseButton, imageData.rotation


        $clockwiseButton.click handleButtonClick
        $counterClockwiseButton.click handleButtonClick
        rotationContainerButtons.append $clockwiseButton
        rotationContainerButtons.append $counterClockwiseButton

        if opt.expose.rotationElement != ""
          $(opt.expose.rotationElement).empty().append rotationContainerButtons
        else
          rotationContainerButtons.css
            position: "absolute"
            top: 5
            left: 5
            opacity: 0.6

          _self.append rotationContainerButtons


      # createRotationSlider = ->
      #   rotationContainerSlider = $("<div>").attr("id", "rotationContainer").mouseover(->
      #     $(this).css "opacity", 1
      #   ).mouseout(->
      #     $(this).css "opacity", 0.6
      #   )

      #   rotMin = $("<div>").attr("id", "rotationMin").html("0")
      #   rotMax = $("<div>").attr("id", "rotationMax").html("360")
      #   $slider = $("<div>").attr("id", "rotationSlider")
      #   orientation = "vertical"
      #   value = Math.abs(360 - opt.image.rotation)

      #   if opt.expose.slidersOrientation == "horizontal"
      #     orientation = "horizontal"
      #     value = opt.image.rotation


      #   handleRotationSlide = (event, ui) ->
      #     imageData = getData 'image'
      #     imageData.rotation = ((if value == 360 then Math.abs(360 - ui.value) else Math.abs(ui.value)))

      #     calculateTranslationAndRotation imageData

      #     opt.image.onRotate $slider, imageData.rotation  if opt.image.onRotate != null


      #   $slider.slider
      #     orientation: orientation
      #     value: value
      #     range: "max"
      #     min: 0
      #     max: 360
      #     step: ((if (opt.rotationSteps > 360 || opt.rotationSteps < 0) then 1 else opt.rotationSteps))
      #     slide: handleRotationSlide

      #   rotationContainerSlider.append rotMin
      #   rotationContainerSlider.append $slider
      #   rotationContainerSlider.append rotMax

      #   if opt.expose.rotationElement != ""
      #     $slider.addClass opt.expose.slidersOrientation
      #     rotationContainerSlider.addClass opt.expose.slidersOrientation
      #     rotMin.addClass opt.expose.slidersOrientation
      #     rotMax.addClass opt.expose.slidersOrientation
      #     $(opt.expose.rotationElement).empty().append rotationContainerSlider

      #   else
      #     $slider.addClass "vertical"
      #     rotationContainerSlider.addClass "vertical"
      #     rotMin.addClass "vertical"
      #     rotMax.addClass "vertical"

      #     rotationContainerSlider.css
      #       position: "absolute"
      #       top: 5
      #       left: 5
      #       opacity: 0.6

      #     _self.append rotationContainerSlider


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


        percentizeZoomDimension = (currentDimension, naturalDimension) ->
          (currentDimension * 100) / naturalDimension


        getPercentOfZoom = ->
          imageData = getData 'image'

          p = if imageData.w > imageData.h
            percentizeZoomDimension imageData.w, opt.image.width
          else
            percentizeZoomDimension imageData.h, opt.image.height

          # debug "Percent: #{p}"
          p


        makeSliderValue = (val) ->
          v = if opt.expose.slidersOrientation == "vertical"
            # debug 'vertical slider'
            opt.image.maxZoom - val
          else
            val

          # debug "Slider value: #{v}"
          v


        handleSliderMove = (ui) ->
          value = makeSliderValue ui.value
          # value = ui.value


          ###
          Calculate the new dimension, given a "natural" size of the image (zoom 100%)
          and a zoom value.  For example, a zoom of 50 (percent) and a dimension of 100 (px)
          would result in a dimension of 50 (px).

          @param zoom [Integer] An integer number representing the percentage of zoom
          @param naturalDimension [Number] The 100% zoom dimension (x/width or y/height) in pixels we're calculating against

          @return [Number] The resultant dimension (px)
          ###
          zoomCalc = (zoom, naturalDimension) ->
            absoluteZoom = Math.abs zoom # Make sure our zoom is a positive number
            newDimension = naturalDimension * absoluteZoom / 100
            # debug "Value: #{absoluteZoom}, naturalDimension: #{naturalDimension}, zoomedDimension: #{newDimension}"
            newDimension


          zoomInPx_width = zoomCalc value, opt.image.width
          zoomInPx_height = zoomCalc value, opt.image.height

          $image.css
            width: zoomInPx_width + "px"
            height: zoomInPx_height + "px"


          ###
          Recalculate the image position (center-weighted) based on the naturalDimension
          and targetDimension.  For example, an image with a 1000px dimension (we'd need
          to do this twice, once for x and once for y) if we're zooming to 500px (a 50%
          zoom), we should re-center the image accordingly as the height/width changes.

          @param position [Number] The current dimension's position (x or y)
          @param naturalDimension [Number] The image's natural height or width in pixels
          @param targetDimension [Number] The image's target height or width in pixels

          @return [Number] The new position
          ###
          newPosition = (position, naturalDimension, targetDimension) ->
            position + ( (naturalDimension / 2) - (targetDimension / 2) )


          imageData.posX = newPosition imageData.posX, imageData.w, zoomInPx_width
          imageData.posY = newPosition imageData.posY, imageData.h, zoomInPx_height
          imageData.w = zoomInPx_width
          imageData.h = zoomInPx_height

          calculateFactor()
          calculateTranslationAndRotation imageData

          opt.image.onZoom $image, imageData  if opt.image.onZoom != null


        $slider.slider
          orientation: ( if opt.expose.zoomElement != "" then opt.expose.slidersOrientation else "vertical" )
          value: makeSliderValue( if opt.image.startZoom != 0 then opt.image.startZoom else getPercentOfZoom(imageData) )
          min: ( if opt.image.useStartZoomAsMinZoom then opt.image.startZoom else opt.image.minZoom )
          max: opt.image.maxZoom
          step: ( if (opt.zoomSteps > opt.image.maxZoom || opt.zoomSteps < 0) then 1 else opt.zoomSteps )

          slide: (event, ui) ->
            handleSliderMove ui

          change: (event, ui) ->
            handleSliderMove ui


        ###
        Used for mousewheel events.  Changes the slider value depending
        on the delta of the slider.
        ###
        moveSlider = (delta) ->
          sliderVal = $slider.slider "value"
          stepSize = $slider.slider("option").step

          if delta > 0
            changeSliderValue sliderVal - stepSize
          else if delta < 0
            changeSliderValue sliderVal + stepSize


        ###
        Used for mousewheel events via moveSlider.  Changes the value of the
        slider, effectively moving the slider as if grabbed and moved by hand.

        @param val [Number] Move the slider to this value.
        ###
        changeSliderValue = (val) ->
          $slider.slider "value", val


        ###
        Setup mousewheel handler to zoom image when mousewheel scrolls.  Only
        works in the deltaY scroll direction.  DeltaX is ignored.
        ###
        $('#k').mousewheel (e, delta, deltaX, deltaY) ->
          moveSlider deltaY


        if opt.slidersOrientation == "vertical"
          zoomContainerSlider.append zoomMax
          zoomContainerSlider.append $slider
          zoomContainerSlider.append zoomMin
        else
          zoomContainerSlider.append zoomMin
          zoomContainerSlider.append $slider
          zoomContainerSlider.append zoomMax

        if opt.expose.zoomElement != ""
          zoomMin.addClass opt.expose.slidersOrientation
          zoomMax.addClass opt.expose.slidersOrientation
          $slider.addClass opt.expose.slidersOrientation
          zoomContainerSlider.addClass opt.expose.slidersOrientation
          $(opt.expose.zoomElement).empty().append zoomContainerSlider
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


      ###
      Create the selector that selects the crop area
      ###
      createSelector = ->
        selectorData = getData 'selector'
        if opt.selector.centered
          selectorData.y = (opt.height / 2) - (selectorData.h / 2)
          selectorData.x = (opt.width / 2) - (selectorData.w / 2)

        $selector = $("<div/>").attr("id", _self[0].id + "_selector").css(
          width: selectorData.w
          height: selectorData.h
          top: selectorData.y + "px"
          left: selectorData.x + "px"
          border: opt.selector.border
          "border-radius": opt.selector.borderRadius
          position: "absolute"
          cursor: "move"
          "pointer-events": (if opt.selector.draggableThroughCrop then "none" else "auto")
        ).mouseover(->
          $(this).css border: opt.selector.borderHover
        ).mouseout(->
          $(this).css border: opt.selector.border
        )

        # Add draggable to the selector
        if opt.selector.draggable
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
              opt.selector.onSelectorDrag $selector, selectorData  if opt.selector.onSelectorDrag != null

            stop: (event, ui) ->
              selectorData = getData 'selector'
              hideOverlay()  if opt.selector.hideOverlayOnDragAndResize
              opt.selector.onSelectorDragStop $selector, selectorData  if opt.selector.onSelectorDragStop != null

        if opt.selector.resizeable
          $selector.resizable
            aspectRatio: opt.selector.aspectRatio
            maxHeight: opt.selector.maxHeight
            maxWidth: opt.selector.maxWidth
            minHeight: opt.selector.h
            minWidth: opt.selector.w
            containment: "parent"

            resize: (event, ui) ->
              selectorData = getData 'selector'

              # update ovelay position
              selectorData.w = $selector.width()
              selectorData.h = $selector.height()
              makeOverlayPositions ui
              showInfo()
              opt.selector.onSelectorResize $selector, selectorData  if opt.selector.onSelectorResize != null

            stop: (event, ui) ->
              selectorData = getData 'selector'
              hideOverlay()  if opt.selector.hideOverlayOnDragAndResize
              opt.selector.onSelectorResizeStop $selector, selectorData  if opt.selector.onSelectorResizeStop != null

        showInfo $selector  if opt.selector.showInfo

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
            background: opt.selector.bgInfoLayer
            opacity: 0.6
            "font-size": opt.selector.infoFontSize + "px"
            "font-family": "Arial"
            color: opt.selector.infoFontColor
            width: "100%"
          )

        selectorData = getData 'selector'

        if opt.selector.showPositionsOnDrag
          _infoView.html "X:" + Math.round(selectorData.x) + "px - Y:" + Math.round(selectorData.y) + "px"
          alreadyAdded = true

        if opt.selector.showDimetionsOnDrag

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
            background: opt.overlayColor
            opacity: 0.6
            position: "absolute"
            "z-index": 2
            visibility: "visible"
          )

          _self.append divO


      makeOverlayPositions = (ui) ->
        _self.find("#t").css
          display: "block"
          width: opt.width
          height: ui.position.top
          left: 0
          top: 0

        _self.find("#b").css
          display: "block"
          width: opt.width
          height: opt.height
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
          width: opt.width
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


      # createMovementControls = ->
      #   table_html = ["<table>", "<tr>", "<td></td>", "<td></td>", "<td></td>", "</tr>", "<tr>", "<td></td>", "<td></td>", "<td></td>", "</tr>", "<tr>", "<td></td>", "<td></td>", "<td></td>", "</tr>", "</table>"].join("\n")
      #   table = $(table_html)
      #   btns = []

      #   btns.push $("<div>").addClass("mvn_no mvn")
      #   btns.push $("<div>").addClass("mvn_n mvn")
      #   btns.push $("<div>").addClass("mvn_ne mvn")
      #   btns.push $("<div>").addClass("mvn_o mvn")
      #   btns.push $("<div>").addClass("mvn_c")
      #   btns.push $("<div>").addClass("mvn_e mvn")
      #   btns.push $("<div>").addClass("mvn_so mvn")
      #   btns.push $("<div>").addClass("mvn_s mvn")
      #   btns.push $("<div>").addClass("mvn_se mvn")

      #   i = 0

      #   while i < btns.length
      #     btns[i].mousedown(->
      #       moveImage this
      #     ).mouseup(->
      #       clearTimeout tMovement
      #     ).mouseout ->
      #       clearTimeout tMovement

      #     table.find("td:eq(" + i + ")").append btns[i]
      #     $(opt.expose.elementMovement).empty().append table
      #     i++


      # ###
      # Move the image

      # @param obj [Element] TODO: I don't know what this is
      # ###
      # moveImage = (obj) ->
      #   imageData = getData 'image'
      #   $obj = $(obj)

      #   if $obj.hasClass("mvn_no")
      #     imageData.posX = (imageData.posX - opt.expose.movementSteps)
      #     imageData.posY = (imageData.posY - opt.expose.movementSteps)

      #   else if $obj.hasClass("mvn_n")
      #     imageData.posY = (imageData.posY - opt.expose.movementSteps)

      #   else if $obj.hasClass("mvn_ne")
      #     imageData.posX = (imageData.posX + opt.expose.movementSteps)
      #     imageData.posY = (imageData.posY - opt.expose.movementSteps)

      #   else if $obj.hasClass("mvn_o")
      #     imageData.posX = (imageData.posX - opt.expose.movementSteps)

      #   else if $obj.hasClass("mvn_c")
      #     imageData.posX = (opt.width / 2) - (imageData.w / 2)
      #     imageData.posY = (opt.height / 2) - (imageData.h / 2)

      #   else if $obj.hasClass("mvn_e")
      #     imageData.posX = (imageData.posX + opt.expose.movementSteps)

      #   else if $obj.hasClass("mvn_so")
      #     imageData.posX = (imageData.posX - opt.expose.movementSteps)
      #     imageData.posY = (imageData.posY + opt.expose.movementSteps)

      #   else if $obj.hasClass("mvn_s")
      #     imageData.posY = (imageData.posY + opt.expose.movementSteps)

      #   else if $obj.hasClass("mvn_se")
      #     imageData.posX = (imageData.posX + opt.expose.movementSteps)
      #     imageData.posY = (imageData.posY + opt.expose.movementSteps)

      #   if opt.image.snapToContainer
      #     imageData.posY = 0  if imageData.posY > 0
      #     imageData.posX = 0  if imageData.posX > 0
      #     bottom = -(imageData.h - _self.height())
      #     right = -(imageData.w - _self.width())
      #     imageData.posY = bottom  if imageData.posY < bottom
      #     imageData.posX = right  if imageData.posX < right

      #   calculateTranslationAndRotation imageData

      #   ###
      #   TODO: Find out what this does
      #   ###
      #   tMovement = setTimeout(->
      #     moveImage obj
      #   , 100)


      ###
      ----------------------------
      This is where it all starts!
      ----------------------------
      ###

      defaults =
        width: 500
        height: 375
        bgColor: "#000"
        overlayColor: "#000"
        border: '1px solid black'
        boxShadow: null

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
          element: null
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

      opt = $.extend(true, defaults, options)

      #Preserve options
      if !$.isFunction($.fn.draggable) || !$.isFunction($.fn.resizable) || !$.isFunction($.fn.slider)
        alert "You must include ui.draggable, ui.resizable and ui.slider to use cropZoom"
        return

      if opt.image.source == "" || opt.image.width == 0 || opt.image.height == 0
        alert "You must set the source, witdth and height of the image element"
        return

      _self = $(this)

      setData "options", opt

      _self.empty()
      _self.css
        width: opt.width
        height: opt.height
        "background-color": opt.bgColor
        overflow: "hidden"
        position: "relative"
        border: opt.border || "2px solid #333"
        'box-shadow': opt.boxShadow

      setData "image",
        h: opt.image.height
        w: opt.image.width
        posY: opt.image.y
        posX: opt.image.x
        scaleX: 0
        scaleY: 0
        rotation: opt.image.rotation
        source: opt.image.source
        bounds: [0, 0, 0, 0]
        id: "image_to_crop_" + _self[0].id

      calculateFactor()
      getCorrectSizes()

      setData "selector",
        x: opt.selector.x
        y: opt.selector.y
        w: ((if opt.selector.maxWidth != null then ((if opt.selector.w > opt.selector.maxWidth then opt.selector.maxWidth else opt.selector.w)) else opt.selector.w))
        h: ((if opt.selector.maxHeight != null then ((if opt.selector.h > opt.selector.maxHeight then opt.selector.maxHeight else opt.selector.h)) else opt.selector.h))

      $container = $("<div>").attr("id", "k").css(
        width: opt.width
        height: opt.height
        position: "absolute"
      )

      if opt.image.element
        console.debug 'using existing image element'
        $image = $(opt.image.element)
      else
        $image = $("<img>")
        $image.attr "src", opt.image.source

      $image.addClass 'cropzoom-grab'
      imageData = getData 'image'
      $image.css
        position: "absolute"
        left: imageData.posX
        top: imageData.posY
        width: imageData.w
        height: imageData.h

      ext = getExtensionSource()

      if (ext == "png" || ext == "gif") && $image.style
        $image.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + opt.image.source + "',sizingMethod='scale');"

      $container.append $image

      _self.append $container

      calculateTranslationAndRotation imageData

      # adding draggable to the image
      $image.draggable
        refreshPositions: true

        drag: (event, ui) ->
          $i = $ event.target
          $i.removeClass('cropzoom-grab').addClass 'cropzoom-grabbing'

          imageData = getData 'image'
          imageData.posY = ui.position.top
          imageData.posX = ui.position.left

          if opt.image.snapToContainer
            limitBounds ui
          else
            calculateTranslationAndRotation imageData

          # Fire the callback
          opt.image.onImageDrag $image  if opt.image.onImageDrag != null

        stop: (event, ui) ->
          $i = $ event.target
          $i.removeClass('cropzoom-grabbing').addClass 'cropzoom-grab'

          limitBounds ui  if opt.image.snapToContainer

      createSelector()

      _self.find(".ui-icon-gripsmall-diagonal-se").css
        background: "#FFF"
        border: "1px solid #000"
        width: 8
        height: 8

      createOverlay()

      if opt.selector.startWithOverlay
        ui_object = position:
          top: $selector.position().top
          left: $selector.position().left

        makeOverlayPositions ui_object

      createZoomSlider()  if opt.enableZoom

      if opt.enableRotation

        if opt.useRotationButtons
          createRotationButtons()
        else
          createRotationSlider()

      createMovementControls()  if opt.expose.elementMovement != ""


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
      opt = obj.data("options")

      obj.empty()
      obj.data "image", {}
      obj.data "selector", {}

      $(opt.expose.zoomElement).empty()  if opt.expose.zoomElement != ""
      $(opt.expose.rotationElement).empty()  if opt.expose.rotationElement != ""
      $(opt.expose.elementMovement).empty()  if opt.expose.elementMovement != ""

      obj.cropzoom opt


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
