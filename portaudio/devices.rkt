#lang racket/base

;; manage devices and the selection thereof across platforms

(require "portaudio.rkt"
         racket/bool
         racket/contract)

(provide (contract-out 
          [default-host-api (->  symbol?)]
          [all-host-apis (-> (listof symbol?))]
          [host-api (parameter/c (or/c false? symbol?))]
          [find-output-device (-> number? nat?)]
          [device-low-output-latency (-> nat? number?)]))
;; can't put contract on it, or can't use in teaching languages:
(provide set-host-api!)

(define nat? exact-nonnegative-integer?)

;; default-host-api : 
;; return the symbol associated with the host API
(define (default-host-api)
  (define host-api-index (pa-get-default-host-api))
  (pa-host-api-info-type (pa-get-host-api-info host-api-index)))

;; all-host-apis : return the symbols associated with supported host APIs
;; enumerate the symbols associated with the supported APIs
;; this list is in order of the API indexes, so, for instance, if element
;; 3 of the list is 'foo, then API 'foo has index 3.
(define (all-host-apis)
  (for/list ([i (in-range (pa-get-host-api-count))])
    (pa-host-api-info-type (pa-get-host-api-info i))))

;; host-api : a parameter used when opening streams, to determine which
;; api to use; false indicates that no value has been set, and the default
;; will be used (we can't set it beforehand, because you can't check
;; the default before initializing portaudio).
(define host-api 
  (make-parameter 
   #f
   (lambda (new-val)
     (cond [(not (or (false? new-val)
                     (member new-val (all-host-apis))))
            (raise-argument-error 'host-api "false or host api symbol"
                                  0 new-val)]
           [else new-val]))))

;; set-host-api! : a version of the parameter setter that you can use
;; in a beginner language
(define (set-host-api! host-api-str)
  (host-api (string->symbol host-api-str))
  (symbol->string (host-api)))

;; find-output-device : number -> number
;; return a device from the current host api with the given latency, using
;; the default, if possible
(define (find-output-device latency)
  (define selected-host-api (or (host-api) (default-host-api)))
  (define reasonable-devices 
    (low-latency-output-devices latency selected-host-api))
  (when (null? reasonable-devices)
    (error 'stream-choose "no devices available in current API ~s with ~sms latency or less."
           selected-host-api
           (* 1000 latency)))
  (define default-output-device (host-api-default-output-device 
                                 selected-host-api))
  ;; choose the default if it matches the spec:
  (cond [(member default-output-device reasonable-devices) 
         default-output-device]
        [else 
         ;; arbitrarily choose the first...
         (log-warning 
          (format
           "default output device doesn't support low-latency (~sms) output, using device ~s instead"
           (* 1000 latency)
           (device-name (car reasonable-devices))))
         (car reasonable-devices)]))


;; return the default output device associated with a host API
;; need to do a reverse lookup...
;; symbol -> number
(define (host-api-default-output-device host-api)
  (for/or ([i 0] 
           [this-host-api (all-host-apis)]
           #:when (symbol=? host-api this-host-api))
    i))

;; reasonable-latency-output-devices : real -> (list-of natural?)
;; output devices with reasonable latency
(define (low-latency-output-devices latency host-api)
  (for/list ([i (in-range (pa-get-device-count))]
             #:when (belongs-to-selected-api? host-api i)
             #:when (has-outputs? i)
             #:when (matches-latency? latency i))
    i))

;; does this device belong to the current host api?
;; nat -> boolean
(define (belongs-to-selected-api? selected-host-api i)  
  (define device-host-api-index 
    (pa-device-info-host-api (pa-get-device-info i)))
  (define host-api (pa-host-api-info-type (pa-get-host-api-info 
                                           device-host-api-index)))
  (symbol=? selected-host-api host-api))

;; has-outputs? : natural -> boolean
;; return true if the device has at least
;; two output channels
(define (has-outputs? i)
  (<= 2 (pa-device-info-max-output-channels (pa-get-device-info i))))

;; matches-latency? : natural real -> boolean
;; return true when the device has low latency
;; no greater than some threshold
(define (matches-latency? latency i)
  (<= (device-low-output-latency i) latency))

;; device-low-output-latency : natural -> real
;; return the low output latency of a device 
(define (device-low-output-latency i)
  (pa-device-info-default-low-output-latency (pa-get-device-info i)))