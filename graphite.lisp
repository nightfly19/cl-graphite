(in-package :cl-graphite)

(defparameter cl-graphite::*server* "https://localhost")

(defun to-graphite-name (name)
  (cffi:translate-camelcase-name name))

(defun expand-query (forms)
  (mapcar (lambda (form)
            (list (car form) (macroexpand (cadr form))))
          forms))

(defun stringed-function (name args)
  (format nil "~a%28~{~a~^,%20~}%29" name args))

(defun quote-string (input-string)
  (format nil "\"~a\"" input-string))

(defun escape-quote-string (input-string)
  (url-rewrite:url-encode (format nil "\"~a\"" input-string)))

(defmacro g-defun (name l-list args)
  `(defun ,name ,l-list
     (stringed-function ,(to-graphite-name name) ,args)))

(defun expand-argument-value (value)
  (cond
    ((eql () value) "false")
    ((eql T value) "true")
    ((listp value) (eval value))
    ((symbolp value) (url-rewrite:url-encode (to-graphite-name value)))
    ((stringp value) (url-rewrite:url-encode value))
    (t value)))

(defun expand-arguments (forms)
  (mapcar (lambda (form)
            (format nil "~a=~a"
                    (to-graphite-name (car form))
                    (expand-argument-value (cadr form))))
          forms))

(defmacro with-server (server &body body)
  `(let ((cl-graphite::*server* ,server))
     ,@body))

(defun query-url* (form)
  (format nil "~a/render/?~{~a~^&~}"
          cl-graphite::*server*
          (expand-arguments (expand-query form))))

(defmacro query-url (&body body)
  (query-url* body))

(defmacro html-link-list (&body body)
  `(cl-who:with-html-output-to-string (*standard-output* nil :prologue nil :indent 0)
     (:ul ,@(mapcar (lambda (link)
                      `(:li (:a :href ,(query-url*
                                        (cons (list :title (car link)) (cadr link)))
                                ,(car link))))
                    body))))

(defmacro redmine-link-list (&body body)
  `(with-output-to-string (*standard-output*)
     (dolist (link (quote ,body))
       (let ((title (quote-string (car link)))
             (link-from (cons (list :title (car link)) (cadr link))))
         (write-line (format nil "* ~a:~a" title (query-url* link-from )))))
     *standard-output*))
