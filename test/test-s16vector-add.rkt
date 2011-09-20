#lang racket

(require "../s16vector-add.rkt"
         ffi/vector
         ffi/unsafe
         rackunit)

;; s16vector of length 20 with random numbers from -50 to 49
(define src-buf (make-s16vector 20 0))
(define src-cpointer (s16vector->cpointer src-buf))
(for ([i (in-range (s16vector-length src-buf))])
  (s16vector-set! src-buf i (- (random 100) 50)))

(define tgt-buf (make-s16vector 100 0))
(define tgt-cpointer (s16vector->cpointer tgt-buf))

(s16buffer-add!/c (ptr-add tgt-cpointer (* 2 36)) src-cpointer 20)
(s16buffer-add!/c (ptr-add tgt-cpointer (* 2 46)) src-cpointer 15)

(check-equal?
 (for/and ([i (in-range 26)])
   (equal? (s16vector-ref tgt-buf i) 0))
 #t)

(check-equal?
 (for/and ([i (in-range 10)])
   (equal? (s16vector-ref tgt-buf (+ 46 i)) 
           (+ (s16vector-ref src-buf i)
              (s16vector-ref src-buf (+ i 10)))))
 #t)
