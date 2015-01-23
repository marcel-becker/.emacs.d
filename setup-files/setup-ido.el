;; Time-stamp: <2015-01-22 09:08:42 kmodi>

;; Interactively Do Things
;; Source: http://www.masteringemacs.org/articles/2010/10/10/introduction-to-ido-mode/
;; Source: https://github.com/magnars/.emacs.d/blob/master/setup-ido.el

;; If ido-ubiquitous 1.6 is used in emacs 24.3, there will always be a
;; compile-log buffer warnings; below defvars will prevent those.
(defvar ido-cur-item         nil)
(defvar ido-default-item     nil)
(defvar predicate            nil)
(defvar inherit-input-method nil)
(defvar ido-cur-list         nil)

(req-package ido
  :require (flx-ido ido-vertical-mode ido-ubiquitous recentf)
  :init
  (progn
    (setq ido-enable-flex-matching t ;; enable fuzzy search
          ido-everywhere t
          ido-create-new-buffer 'always ;; create a new buffer if no buffer matches substring
          ido-file-extensions-order '(".sv" ".v" ".svh" ".tv" ".m" ".c" ".cpp" ".el")
          ;;  customize the order in which files are sorted when Ido displays them in
          ;; the minibuffer. There are certain file extensions I use more than others,
          ;; so I tell Ido to emphasize those
          ido-use-filename-at-point 'guess ;; find file at point using ido
          ;; look into other directories if the entered filename doesn't exist
          ;; in current directory ido-auto-merge-work-directories-length -1
          ;; do NOT look into other directories if the entered filename doesn't
          ;; exist in current directory
          ido-auto-merge-work-directories-length 0))
  :config
  (progn
    (ido-mode 1)
    ;; Use flx-ido for better flex matching between words
    (flx-ido-mode 1)
    (setq ido-use-faces nil) ;; disable ido faces to see flx highlights
    (ido-vertical-mode 1) ;; flx-ido looks better with ido-vertical-mode
    (ido-ubiquitous-mode 1)
    ;; Sometimes when using ido-switch-buffer the *Messages* buffer get in the way,
    ;; so we set it to be ignored (it can be accessed using `C-h e', so there is
    ;; really no need for it in the buffer list).
    ;; Source: https://github.com/larstvei/dot-emacs
    (add-to-list 'ido-ignore-buffers "*Messages*")
    ;; sort ido filelist by mtime instead of alphabetically
    ;; source: http://www.emacswiki.org/emacs/InteractivelyDoThings
    (defun ido-sort-mtime ()
      ;; Sort the list only when the File gid is non-zero;
      ;; otherwise the sort function errors out.
      ;; (message "Current dir: %s File GID: %s File Attributes: %s"
      ;;          ido-current-directory
      ;;          (fourth (file-attributes ido-current-directory))
      ;;          (file-attributes ido-current-directory))
      (when (file-exists-p ido-current-directory) ; only if the current directory exists
        (when (not (= (fourth (file-attributes ido-current-directory)) 0))
          (setq ido-temp-list
                (sort ido-temp-list
                      (lambda (a b)
                        (time-less-p
                         (sixth (file-attributes (concat ido-current-directory b)))
                         (sixth (file-attributes (concat ido-current-directory a))))))))
        (ido-to-end  ;; move . files to end (again)
         (delq nil (mapcar
                    (lambda (x) (and (char-equal (string-to-char x) ?.) x))
                    ido-temp-list)))))
    (add-hook 'ido-make-file-list-hook 'ido-sort-mtime)
    (add-hook 'ido-make-dir-list-hook  'ido-sort-mtime)
    ;; Open recent files with IDO,
    ;; https://github.com/lunaryorn/stante-pede/blob/master/init.el
    ;; http://emacsredux.com/blog/2013/04/05/recently-visited-files/
    ;; http://www.reddit.com/r/emacs/comments/21a4p9/use_recentf_and_ido_together/cgc8f6b
    ;; `abbreviate-file-name' abbreviates home dir to ~/ in the file list
    ;; Custom abbreviations can be added to `directory-abbrev-alist'.
    (defun ido-find-recentf ()
      "Use ido to select a recently opened file from the `recentf-list'"
      (interactive)
      (find-file
       (ido-completing-read "Recentf open: "
                            (mapcar 'abbreviate-file-name recentf-list)
                            nil t)))
    ;; Be able to bury buffers from ido
    ;; Source: http://endlessparentheses.com/Ido-Bury-Buffer.html
    (defun endless/ido-bury-buffer-at-head ()
      "Bury the buffer at the head of `ido-matches'."
      (interactive)
      (let ((enable-recursive-minibuffers t)
            (buf (ido-name (car ido-matches)))
            (nextbuf (cadr ido-matches)))
        (when (get-buffer buf)
          ;; If next match names a buffer use the buffer object;
          ;; buffer name may be changed by packages such as
          ;; uniquify.
          (when (and nextbuf (get-buffer nextbuf))
            (setq nextbuf (get-buffer nextbuf)))
          (bury-buffer buf)
          (if (bufferp nextbuf)
              (setq nextbuf (buffer-name nextbuf)))
          (setq ido-default-item nextbuf
                ido-text-init ido-text
                ido-exit 'refresh)
          (exit-minibuffer))))
    (defun ido-define-keys ()
      (unbind-key "C-a" ido-completion-map)
      (bind-keys
       :map ido-completion-map
       ;; C-n/p  and up/down keys are more intuitive in vertical layout
       ("C-n"    . ido-next-match)
       ("<down>" . ido-next-match)
       ("C-p"    . ido-prev-match)
       ("<up>"   . ido-prev-match)
       ("C-f"    . ido-magic-forward-char)
       ("C-b"    . ido-magic-backward-char)
       ("C-i"    . ido-toggle-ignore)
       ("C-S-b"  . endless/ido-bury-buffer-at-head)))
    (add-hook 'ido-setup-hook 'ido-define-keys)
    (bind-keys
     :map modi-mode-map
     ;; overriding the `C-x C-o` binding with `delete-blank-lines'
     ("C-x C-o"     . ido-find-recentf))
    ))


(provide 'setup-ido)

;; (defun ido-define-keys ()
;;   ;; C-n/p  and up/down keys are more intuitive in vertical layout
;;   (define-key ido-completion-map (kbd "C-n")    'ido-next-match)
;;   (define-key ido-completion-map (kbd "<down>") 'ido-next-match)
;;   (define-key ido-completion-map (kbd "C-p")    'ido-prev-match)
;;   (define-key ido-completion-map (kbd "<up>")   'ido-prev-match)
;;   (define-key ido-completion-map (kbd "C-b")    'endless/ido-bury-buffer-at-head))
;; (add-hook 'ido-setup-hook 'ido-define-keys)

;; Default ido key map

;; Basic map
;; | C-a     | 'ido-toggle-ignore              |
;; | C-c     | 'ido-toggle-case                |
;; | C-e     | 'ido-edit-input                 |
;; | Tab     | 'ido-complete                   |
;; | Space   | 'ido-complete-space             |
;; | C-j     | 'ido-select-text                |
;; | C-m     | 'ido-exit-minibuffer            |
;; | C-p     | 'ido-toggle-prefix (OVERRIDDEN) |
;; | C-r     | 'ido-prev-match                 |
;; | C-s     | 'ido-next-match                 |
;; | C-t     | 'ido-toggle-regexp              |
;; | C-z     | 'ido-undo-merge-work-directory  |
;; | C-Space | 'ido-restrict-to-matches        |
;; | M-Space | 'ido-take-first-match           |
;; | C-@     | 'ido-restrict-to-matches        |
;; | Right   | 'ido-next-match                 |
;; | Left    | 'ido-prev-match                 |
;; | ?       | 'ido-completion-help            |

;; Magic commands.
;; | C-b | 'ido-magic-backward-char (OVERRIDDEN) |
;; | C-f | 'ido-magic-forward-char               |
;; | C-d | 'ido-magic-delete-char                |

;; File and directory map
;; | C-x C-b                      | 'ido-enter-switch-buffer                 |
;; | C-x C-f                      | 'ido-fallback-command                    |
;; | C-x C-d                      | 'ido-enter-dired                         |
;; | Down                         | 'ido-next-match-dir                      |
;; | Up                           | 'ido-prev-match-dir                      |
;; | M-Up                         | 'ido-prev-work-directory                 |
;; | M-Down                       | 'ido-next-work-directory                 |
;; | Backspace                    | 'ido-delete-backward-updir               |
;; | Delete                       | 'ido-delete-backward-updir               |
;; | [remap delete-backward-char] | 'ido-delete-backward-updir) ; B          |
;; | [remap backward-kill-word]   | 'ido-delete-backward-word-updir)  ; M-DE |
;; | C-Backspace                  | 'ido-up-directory                        |
;; | C-l                          | 'ido-reread-directory                    |
;; | M-d                          | 'ido-wide-find-dir-or-delete-dir         |
;; | M-b                          | 'ido-push-dir                            |
;; | M-v                          | 'ido-push-dir-first                      |
;; | M-f                          | 'ido-wide-find-file-or-pop-dir           |
;; | M-k                          | 'ido-forget-work-directory               |
;; | M-m                          | 'ido-make-directory                      |
;; | M-n                          | 'ido-next-work-directory                 |
;; | M-o                          | 'ido-prev-work-file                      |
;; | M-C-o                        | 'ido-next-work-file                      |
;; | M-p                          | 'ido-prev-work-directory                 |
;; | M-s                          | 'ido-merge-work-directories              |

;; File only map
;; | C-k | 'ido-delete-file-at-head    |
;; | C-o | 'ido-copy-current-word      |
;; | C-w | 'ido-copy-current-file-name |
;; | M-l | 'ido-toggle-literal         |

;; Buffer map
;; | C-x C-f | 'ido-enter-find-file        |
;; | C-x C-b | 'ido-fallback-command       |
;; | C-k     | 'ido-kill-buffer-at-head    |
;; | C-o     | 'ido-toggle-virtual-buffers |


    ;; (setq ido-enable-prefix nil
    ;;       ido-case-fold nil
    ;;       ido-use-filename-at-point nil
    ;;       ido-max-prospects 10)
;; (defun ido-disable-line-truncation ()
;;   (set (make-local-variable 'truncate-lines) nil))
;; (add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-truncation)

;; ;; Use C-w to go back up a dir to better match normal usage of C-w
;; ;; - insert current file name with C-x C-w instead.
;; (define-key ido-file-completion-map (kbd "C-w") 'ido-delete-backward-updir)
;; (define-key ido-file-completion-map (kbd "C-x C-w") 'ido-copy-current-file-name)

;; (define-key ido-file-dir-completion-map (kbd "C-w") 'ido-delete-backward-updir)
;; (define-key ido-file-dir-completion-map (kbd "C-x C-w") 'ido-copy-current-file-name))

;; ;; Always rescan buffer for imenu
;; (set-default 'imenu-auto-rescan t)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Ido at point (Replacement for auto-complete)
;; ;; https://github.com/katspaugh/ido-at-point
;; (require 'ido-at-point)
;; (ido-at-point-mode t)
;; Update: But I found auto-complete better.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use ido everywhere, example: when searching for var name `C-h v`, searching
;; for function name `C-h f`, etc

;; ;; Fix ido-ubiquitous for newer packages
;; (defmacro ido-ubiquitous-use-new-completing-read (cmd package)
;;   `(eval-after-load ,package
;;      '(defadvice ,cmd (around ido-ubiquitous-new activate)
;;         (let ((ido-ubiquitous-enable-compatibility nil))
;;           ad-do-it))))

;; (ido-ubiquitous-use-new-completing-read webjump 'webjump)
;; (ido-ubiquitous-use-new-completing-read yas-expand 'yasnippet)
;; (ido-ubiquitous-use-new-completing-read yas-visit-snippet-file 'yasnippet)
