;;; factlog.el --- File activity logger

;; Copyright (C) 2012 Takafumi Arakaki

;; Author: Takafumi Arakaki <aka.tkf at gmail.com>

;; This file is NOT part of GNU Emacs.

;; factlog.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; factlog.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with factlog.el.
;; If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'recentf)
(require 'deferred)

(defgroup factlog nil
  "File activity logger."
  :group 'convenience
  :prefix "factlog:")

(defvar factlog:lisp-dir (if load-file-name
                             (file-name-directory load-file-name)
                           default-directory))

(defvar factlog:source-dir (expand-file-name
                            ".."
                            (file-name-nondirectory factlog:lisp-dir)))

(defvar factlog:cli-script
  (convert-standard-filename
   (expand-file-name "factlog_cli.py" factlog:source-dir))
  "Full path to FactLog CLI script.")

(defcustom factlog:command
  (list "python" factlog:cli-script)
  "Command to run factlog CLI."
  :group 'factlog)

(defun factlog:deferred-process (&rest args)
  (apply #'deferred:process (append factlog:command args)))

(defun factlog:after-save-handler ()
  (when (recentf-include-p buffer-file-name)
    (factlog:deferred-process
     "record" "--file-point" (format "%s" (point)) buffer-file-name)))

(define-minor-mode factlog-mode
  "FactLog mode -- file activity logger.

\\{factlog-mode-map}"
  ;; :keymap factlog-mode-map
  :global t
  :group 'factlog
  (if factlog-mode
      (add-hook 'after-save-hook 'factlog:after-save-handler)
    (remove-hook 'after-save-hook 'factlog:after-save-handler)))

(provide 'factlog)

;;; factlog.el ends here
