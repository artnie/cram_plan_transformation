;;;
;;; Copyright (c) 2018, Arthur Niedzwiecki <niedzwiecki@uni-bremen.de>
;;;
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;;
;;;     * Redistributions of source code must retain the above copyright
;;;       notice, this list of conditions and the following disclaimer.
;;;     * Redistributions in binary form must reproduce the above copyright
;;;       notice, this list of conditions and the following disclaimer in the
;;;       documentation and/or other materials provided with the distribution.
;;;     * Neither the name of the Intelligent Autonomous Systems Group/
;;;       Technische Universitaet Muenchen nor the names of its contributors
;;;       may be used to endorse or promote products derived from this software
;;;       without specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.

(in-package :plt)

(defvar *transformation-rules* (make-hash-table :test 'eq))
(defvar *disabled-transformation-rules* '())

(defmacro register-transformation-rule (name predicate)
  `(setf (gethash ',name *transformation-rules*)
         ,predicate))

(defmacro disable-transformation-rule (name)
  `(pushnew ',name *disabled-transformation-rules*))

(defmacro enable-transformation-rule (name)
  `(setf *disabled-transformation-rules*
         (remove ',name *disabled-transformation-rules*)))

(defun apply-rules ()
  (let ((applicable-rules '())
        (raw-bindings))
    (loop for k being the hash-keys of *transformation-rules* do
      (unless (member k *disabled-transformation-rules*)
        (roslisp:ros-info (plt) "Checking predicate for rule ~a." k)
        (setf raw-bindings (prolog (gethash k *transformation-rules*)))
        (when raw-bindings
          (push `(,k . ,raw-bindings) applicable-rules))))
    (roslisp:ros-info (plt) "Following rules are applicable:")
    (loop for i to (1- (length applicable-rules)) do
      (roslisp:ros-info (plt) "~a: ~a" i (car (nth i applicable-rules))))
    (roslisp:ros-info (plt) "Type the rule number to apply:")
    (let ((choice (read)))
      (if (and (typep choice 'integer)
               (nth choice applicable-rules))
          (funcall (car (nth choice applicable-rules)) (cdr (nth choice applicable-rules)))
          (roslisp:ros-info (plt) "Invalid number ~a" choice)))))
      

