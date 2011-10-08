#lang racket/base

(require ffi/unsafe)
;; The mzrt-sema functions work with OS threads. Unfortunately,
;; they also block whole OS threads, so you need to use them carefully.
;; In particular, if you're going to do a sema-wait, you'd better do
;; it using 'places' so it won't shut down all of Racket.

;; yes, there's some abstraction possible here.

(provide (all-defined-out))

;; FFI OBJECTS FROM THE SCHEME LIBRARY
(define schemelib (ffi-lib #f))

(define-cpointer-type _mzrt-semaphore)

(define mzrt-sema-create
  (get-ffi-obj "mzrt_sema_create"
               #f
               (_fun (sema-ptr : (_ptr o _mzrt-semaphore))
                     _int
                     -> (err-code : _int)
                     -> (cond [(= err-code 0) sema-ptr]
                              [else (error 'mzrt-sema-create
                                           (format "error number ~s"
                                                   err-code))]))))

(define mzrt-sema-wait
  (get-ffi-obj "mzrt_sema_wait"
               #f
               (_fun _mzrt-semaphore
                     -> (err-code : _int)
                     -> (cond [(= err-code 0) (void)]
                              [else (error 'mzrt-sema-wait
                                           (format "error number ~s"
                                                   err-code))]))))

(define mzrt-sema-post
  (get-ffi-obj "mzrt_sema_post"
               #f
               (_fun _mzrt-semaphore
                     -> (err-code : _int)
                     -> (cond [(= err-code 0) (void)]
                              [else (error 'mzrt-sema-post
                                           (format "error number ~s"
                                                   err-code))]))))




