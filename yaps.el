;;; yaps.el --- Yet Another Persistent Scratch -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Ray Wang <ray.hackmylife@gmail.com>

;; Author: Ray Wang <ray.hackmylife@gmail.com>
;; Package-Requires: ((emacs "24.3"))
;; Package-Version: 0
;; Keywords: convenience, files
;; URL: https://github.com/rayw000/yaps

;; This file is not part of GNU Emacs.

;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:
;; Yaps makes your *scratch* buffer persistent and cannot be killed (bury instead).
;;
;; Similar packages:
;; https://github.com/Fanael/persistent-scratch

;; Usage:
;;
;;   Require package:
;;
;;     (require 'yaps) ;; if not using the ELPA package
;;     Once you require, `yaps-mode' would automatically be enabled on buffer `yaps-scratch-buffer-name'.
;;
;;   Customizations:
;;
;;     `yaps-scratch-buffer-name': Buffer name which you want to enable `yaps' for. Default is *scratch*.
;;
;;     `yaps-data-directory': Directory to store yaps data. Default it `user-emacs-directory'.
;;
;;     `yaps-mode-map': Key maps to `yaps-mode'.
;;
;;   Functions:
;;
;;     `yaps-save-scratch-data': Save scratch contents into `yaps-data-directory'.
;;
;;     `yaps-clear-scratch-data': Clear scratch contents.
;;
;;     `yaps-bury-scratch-buffer': Bury (instead of kill) scratch buffer.
;;
;;     `yaps-restore-data-from-file': Restore data from yaps data file.



(defgroup yaps nil
  "Yaps group."
  :prefix "yaps-"
  :group 'files)

(defcustom yaps-scratch-buffer-name "*scratch*"
  "Scratch buffer name which `yaps' will connect to."
  :type 'string)

(defcustom yaps-data-directory user-emacs-directory
  "Directory for yaps data."
  :type 'string)

(defvar yaps--data-file (concat yaps-data-directory
                                (unless (equal (substring yaps-data-directory -1) "/") "/")
                                "yaps.data")
  "Data file which stores yaps data.")


(defvar yaps-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [remap save-buffer] 'yaps-save-scratch-data)
    map)
  "Yaps mode key maps.")

;;;###autoload
(defun yaps-save-scratch-data ()
  "Save *scratch* buffer data into file."
  (interactive)
  (with-current-buffer yaps-scratch-buffer-name
    (save-restriction
      (widen)
      (let* ((content (buffer-substring-no-properties (point-min)
                                                      (point-max)))
             (point (point))
             (assoc-to-save `((content . ,(format "%S" content))
                              (point . ,(format "%d" point)))))
        (write-region (format "%s" assoc-to-save) nil yaps--data-file)
        (message "Buffer content saved to %s." yaps--data-file)))))

;;;###autoload
(defun yaps-clear-scratch-data ()
  (interactive)
  (with-current-buffer yaps-scratch-buffer-name
    (erase-buffer)))

;;;###autoload
(defun yaps-bury-scratch-buffer ()
  "Bury *scratch* buffer instead of kill it."
  (if (not (equal (buffer-name) yaps-scratch-buffer-name))
      t
    (message "%s buffer buried." yaps-scratch-buffer-name)
    (bury-buffer)
    nil))

;;;###autoload
(defun yaps-restore-data-from-file ()
  "Restore data from yaps data file."
  (interactive)
  (when yaps-mode
    (with-current-buffer yaps-scratch-buffer-name
      (if (not (file-exists-p yaps--data-file))
          (message "File %s doesn't exist." yaps--data-file)
        (let* ((sexp (car (read-from-string
                           (with-temp-buffer
                             (insert-file-contents yaps--data-file)
                             (buffer-string)))))
               (content (cdr (assoc 'content sexp)))
               (point (cdr (assoc 'point sexp))))
          (erase-buffer)
          (insert content)
          (goto-char point))))))

;;;###autoload
(define-minor-mode yaps-mode
  "Minor mode of Yaps."
  :init-value nil
  :lighter "yaps"
  :group 'yaps
  :global nil
  :keymap yaps-mode-map
  :after-hook (yaps-restore-data-from-file)
  (if yaps-mode
      (add-hook 'kill-buffer-query-functions 'yaps-bury-scratch-buffer)
    (remove-hook 'kill-buffer-query-functions 'yaps-bury-scratch-buffer)))

(make-local-variable 'yaps-mode)

;; auto enable `yaps-mode' for `yaps-scratch-buffer-name'.
(with-current-buffer (get-buffer-create yaps-scratch-buffer-name)
  (call-interactively 'yaps-mode))

(provide 'yaps)
;;; yaps.el ends here
