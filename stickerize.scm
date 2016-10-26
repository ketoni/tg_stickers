
(define (script-fu-stickerize img brusz) 
(
	let*
	(
		(toplayer (car (gimp-image-get-active-layer img)))
		(brush (car (gimp-brush-new "temp-brush")))
		(width 0)
		(height 0)
		(ratio 0)
		(pad 25)
	)
	
	(gimp-image-undo-group-start img)
	(gimp-context-push)
	(gimp-context-set-paint-method "gimp-paintbrush")
	(gimp-context-set-brush brush)
	(gimp-context-set-paint-mode NORMAL-MODE)
	(gimp-context-set-foreground '(245 245 245))
	(gimp-brush-set-hardness brush 1.0)
	(gimp-brush-set-radius brush brusz)
	
	(gimp-item-set-name toplayer "top")
	
	(plug-in-autocrop-layer 0 img toplayer)
	(set! width (car (gimp-drawable-width toplayer)))
	(set! height (car (gimp-drawable-height toplayer)))
	(set! ratio (/ height width))
	
	(if (> ratio 1)
		(begin
			(set! height 512)
			(set! width (* (/ 1 ratio) 512))
		)
		(begin
			(set! height (* ratio 512))
			(set! width 512)
		)
	)

	(gimp-layer-scale toplayer (- width pad) (- height pad) TRUE)
	(gimp-layer-resize toplayer width height (/ pad 2) (/ pad 2))
	(gimp-image-resize-to-layers img)
	
	(define edgelayer (car (gimp-layer-new-from-drawable toplayer img)))
	(gimp-item-set-name edgelayer "edges")
	(gimp-image-insert-layer img edgelayer 0 0)
	(gimp-image-lower-item-to-bottom img edgelayer)
	
	(gimp-image-select-item img 0 edgelayer)
	(gimp-edit-stroke edgelayer)
	(gimp-selection-none img)
	
	(define shadowlayer (car (gimp-layer-new-from-drawable edgelayer img)))
	(gimp-item-set-name shadowlayer "shadow")
	(gimp-image-insert-layer img shadowlayer 0 0)
	(gimp-image-lower-item-to-bottom img shadowlayer)
	
	(gimp-threshold shadowlayer 255 255)
	(plug-in-gauss 1 img shadowlayer 7.0 7.0 1)
	(gimp-layer-translate shadowlayer 2 3)
	(gimp-layer-set-opacity shadowlayer 55.0)
	(gimp-layer-resize-to-image-size shadowlayer)
	
	
	(gimp-image-merge-visible-layers img 1)
	(gimp-item-set-name (car (gimp-image-get-active-layer img)) "Sticker")
	
	(gimp-brush-delete brush)
	(gimp-context-pop)
	(gimp-displays-flush)
	(gimp-image-undo-group-end img)
)
)

(script-fu-register
	"script-fu-stickerize"
	"Stickerize"
	""
	"Keksi"
	""
	"5.7.2015"
	""
	SF-IMAGE "Image" 0
	SF-VALUE "Edge size (px)" "5"

)(script-fu-menu-register "script-fu-stickerize" "<Image>/File")