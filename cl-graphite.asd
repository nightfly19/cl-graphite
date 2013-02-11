(asdf:defsystem :cl-graphite
  :name "cl-graphite"
  :version "0.0.1"
  :author "Sage Imel"
  :description "Programmatically generate graphite urls"
  :serial t
  :depends-on (:cffi :cl-who :url-rewrite)
  :components ((:file "packages")
               (:file "graphite")
               (:file "graphite-functions")))
