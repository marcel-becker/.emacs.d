;; Time-stamp: <2015-02-10 12:42:28 kmodi>

;; Line number packages

(defvar modi/linum-fn-default 'nlinum
  "Default value of linum mode, used when toggling linum on and off.
Set this value to either 'nlinum, 'linum or 'linum-relative.")

(defvar modi/linum-fn-internal nil
  "State variable that tells if line numbers are being displayed or not.
If nil, the line numbers are not displayed.
Else this value is either 'nlinum, 'linum or 'linum-relative.

This variable is for internal use only, not to be set by user.")

;; linum
(require 'linum)
(global-linum-mode -1) ; Disable linum-mode globally

;; nlinum
;; http://elpa.gnu.org/packages/nlinum.html
(require 'nlinum)
(global-nlinum-mode -1) ; Disable nlinum-mode globally
(setq nlinum-format "%4d ") ; right aligned, 4 char wide line num col

(require 'linum-relative)
;; linum relative
(setq linum-relative-current-symbol "")
;; The symbol you want to show on the current line, by default it is 0.
;; You can use any string like \"->\". If this variable is empty string,
;; linum-releative will show the real line number at current line.

(defun modi/blend-linum ()
  "Set the linum foreground and background color to that of the theme."
  (set-face-attribute 'linum nil
                      :height 0.9
                      :foreground "dim gray"
                      :background (face-background 'default)))

(defun modi/turn-on-linum ()
  "Turn on linum mode in specific modes."
  (interactive)
  (dolist (hook '(verilog-mode-hook
                  emacs-lisp-mode-hook
                  cperl-mode-hook
                  c-mode-hook
                  python-mode-hook
                  matlab-mode-hook
                  sh-mode-hook
                  web-mode-hook
                  html-mode-hook
                  css-mode-hook
                  makefile-gmake-mode-hook))
    (add-hook hook #'linum-mode)))

(defun modi/turn-off-linum ()
  "Unhook linum mode from various major modes."
  (interactive)
  (dolist (hook '(verilog-mode-hook
                  emacs-lisp-mode-hook
                  cperl-mode-hook
                  c-mode-hook
                  python-mode-hook
                  matlab-mode-hook
                  sh-mode-hook
                  web-mode-hook
                  html-mode-hook
                  css-mode-hook
                  makefile-gmake-mode-hook))
    (remove-hook hook #'linum-mode)))

(defun modi/turn-on-nlinum ()
  "Turn on nlinum mode in specific modes."
  (interactive)
  (dolist (hook '(verilog-mode-hook
                  emacs-lisp-mode-hook
                  cperl-mode-hook
                  c-mode-hook
                  python-mode-hook
                  matlab-mode-hook
                  sh-mode-hook
                  web-mode-hook
                  html-mode-hook
                  css-mode-hook
                  makefile-gmake-mode-hook))
    (add-hook hook #'nlinum-mode)))

(defun modi/turn-off-nlinum ()
  "Unhook nlinum mode from various major modes."
  (interactive)
  (dolist (hook '(verilog-mode-hook
                  emacs-lisp-mode-hook
                  cperl-mode-hook
                  c-mode-hook
                  python-mode-hook
                  matlab-mode-hook
                  sh-mode-hook
                  web-mode-hook
                  html-mode-hook
                  css-mode-hook
                  makefile-gmake-mode-hook))
    (remove-hook hook #'nlinum-mode)))

(defun modi/set-linum (linum-pkg)
  "Set linum to either 'nlinum, 'linum-relative or 'linum.
Set to nil to disable linum altogether."
  (interactive
   (list (intern (completing-read
                  "linum pkg (default nlinum): "
                  '("nlinum" "linum-relative" "linum" "nil")
                  nil t nil nil "nlinum"))))
  (when (stringp linum-pkg)
    (setq linum-pkg (intern linum-pkg)))
  (cl-case linum-pkg
    (nlinum
     (modi/turn-off-linum)
     (modi/turn-on-nlinum))
    (linum-relative
     (modi/turn-off-nlinum)
     (setq linum-format 'linum-relative)
     (modi/turn-on-linum))
    (linum
     (modi/turn-off-nlinum)
     (setq linum-format 'dynamic)
     (modi/turn-on-linum))
    (t
     (modi/turn-off-linum)
     (modi/turn-off-nlinum)))
  (if linum-pkg
      (message "Activated %s" linum-pkg)
    (when modi/linum-fn-internal
      (message "Deactivated %s" modi/linum-fn-internal)))
  (setq modi/linum-fn-internal linum-pkg))

(defun modi/toggle-linum ()
  "Toggle linum between the disabled state and enabled using the default
package set by the user using variable `modi/linum-fn-default'."
  (interactive)
  (if modi/linum-fn-internal
      (modi/set-linum nil)
    (modi/set-linum modi/linum-fn-default)))

;; Set/unset linum
(modi/set-linum modi/linum-fn-default)


(provide 'setup-linum)
