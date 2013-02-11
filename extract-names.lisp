(defun extract-names ()
  "Extracts the names of graphite functions and dumps them in ./temp"
  (with-open-file (s "./graphite.lisp")
    (let* ((output ())
           (output (handler-case
                       (loop while T do (setf output (cons (read s) output)))
                     (condition () output)))
           (output (cl-arrows:->
                    (cl-arrows::--> output
                                    (remove-if (lambda (thing)
                                                 (not (eql (car thing) 'g-defun))))
                                    (mapcar (lambda (thing) (cadr thing))))
                    (sort (lambda (a b) (string-lessp (string a) (string b)))))))
      (with-open-file (f "./temp" :direction :output :if-exists :supersede)
        (dolist (name output)
          (write-line (format nil "#:~a"
                              (string-downcase  (string name))) f))))))
