#lang setup/infotab

(define name "PortAudio")

(define blurb '((p "PortAudio is a cross-platform library "
                   "for audio output and input. It runs "
                   "on Windows, Mac OS X, and linux. "
                   "This package provides Racket bindings "
                   "for these functions. For higher-level "
                   "tools and utilities, use the RSound package.")))

(define scribblings '(("portaudio.scrbl" () (tool))))
(define categories '(media))
(define version "2012-10-13-12:44")
(define release-notes '((p "improved windows host api handling, "
                           "bugfixes")))
(define compile-omit-paths '("test"))

;; planet-specific:
(define repositories '("4.x"))
(define primary-file "main.rkt")

#;(define homepage "http://schematics.sourceforge.net/")
#;(define url "http://schematics.sourceforge.net/")

