;; (ql:quickload :hermes-intuition)
(defpackage hermes-intuition
  (:use #:cl #:alexandria)
  (:import-from #:omcom.utils
		#:random-float)
  (:import-from #:ominp.rates
		#:get-tp-sl
		#:from-pips)
  (:export #:con
	   #:ant
	   #:eval-ifis)
  
  (:nicknames #:omint))
(in-package :hermes-intuition)

(cl:setf cl:*read-default-float-format* 'cl:double-float)

(defun con (y x0 x1)
  (let* ((m (/ 1
	       (- x1 x0)))
	 (b (+ (* m (- x0)) 0)))
    (/ (- y b) m)))
;; (con 0.0 -5 0)
;; (con 0.0 0 -5)

(defun ant (x x0 x1)
  (if (= (- x1 x0) 0)
      0
      (let* ((m (/ 1 (- x1 x0)))
	     (b (+ (* m (- x0)) 0)))
	(+ (* m x) b))))
;; (ant 3 0 5)
;; (ant 3 5 0)

;; (defun make-antecedent (mean spread)
;;   (lambda (x) (exp (* -0.5 (expt (/ (- x mean) spread) 2)))))

(defun eval-ifis (inputs input-antecedents input-consequents)
  (let ((tp 0)
	(sl 0)
	(len (length inputs))
	(winner-gm 0)
	(winner-idx 0)
	(num-rules (length (aref input-antecedents 0))))
    ;; Calculating most activated antecedents.
    (loop
      for idx from 0 below num-rules
      do (let ((gm 0))
	   (loop for antecedents across input-antecedents
		 for input in inputs
		 do (let* ((antecedent (aref antecedents idx))
			   (act (ant input (aref antecedent 0) (aref antecedent 1))))
		      (when (and (<= act 1)
				 (>= act 0))
			(incf gm act))))
	   (when (>= gm winner-gm)
	     (setf winner-idx idx)
	     (setf winner-gm gm))))
    ;; Calculating outputs (TP & SL).
    (let ((activation (/ winner-gm len)))
      (loop
	for consequents across input-consequents
	do (progn
	     (incf tp (con activation
			   (aref (aref (aref consequents winner-idx) 0) 0)
			   (aref (aref (aref consequents winner-idx) 0) 1)))
	     (incf sl (con activation
			   (aref (aref (aref consequents winner-idx) 1) 0)
			   (aref (aref (aref consequents winner-idx) 1) 1)))))
      (values
       (/ tp len)
       (/ sl len)
       activation))))

;; Keeping for historical reasons.
;; (defun ifis (i antecedents consequents)
;;   (let ((winner-gm 0)
;; 	(winner-idx 0))
;;     (loop
;;        for idx from 0
;;        for ant across antecedents
;;        do (let ((gm (funcall ant i)))
;; 	    (when (and (<= gm 1)
;; 		       (>= gm 0)
;; 		       (>= gm winner-gm))
;; 	      (setf winner-idx idx)
;; 	      (setf winner-gm gm))))
;;     (funcall (aref consequents winner-idx) winner-gm)))



;; (defparameter *rates* (fracdiff (get-rates-random-count-big :AUD_USD omcom.omage:*train-tf* 10000)))
;; (make-ifis (gen-agent 3 :EUR_USD *rates* (assoccess (gen-random-beliefs 2) :perception-fns) 10 10) 3 :EUR_USD *rates*)
;; (time
;;  (evaluate-agent (let ((beliefs (gen-random-beliefs omcom.omage:*number-of-agent-inputs*)))
;; 		   (gen-agent omcom.omage:*number-of-agent-rules*
;; 			      :AUD_USD
;; 			      *rates*
;; 			      (assoccess beliefs :perception-fns)
;; 			      (assoccess beliefs :lookahead-count)
;; 			      (assoccess beliefs :lookbehind-count)))
;; 		 *rates* :return-fitnesses-p t))

;; (slot-value (gen-agent 2 *rates* (assoccess (gen-random-beliefs 2) :perception-fns) 10 10) 'perception-fns)
;; (insert-agent (gen-agent 2 *rates* (assoccess (gen-random-beliefs 2) :perception-fns) 10 16) :EUR_USD omcom.omage:*train-tf* '(:BULLISH))
