;; Time-stamp: <2017-06-07 12:15:21 kmodi>

;; Counsel (comes packaged with the `swiper' package)

(use-package counsel
  :defer t
  :init
  (progn
    ;; Do not bind the below keys to counsel commands if the user has decided
    ;; to use ido instead of ivy.
    (when (not (bound-and-true-p disable-pkg-ivy))
      (bind-keys
       :map modi-mode-map
       ("M-i" . counsel-grep-or-swiper)
       ("C-M-y" . counsel-yank-pop)
       ("C-h F" . counsel-faces)       ;Overrides `Info-goto-emacs-command-node'
       ("C-h S" . counsel-info-lookup-symbol)
       ("C-c u" . counsel-unicode-char)
       ("C-c C" . counsel-colors-emacs) ;Alternative to `list-colors-display'
       ([remap execute-extended-command] . counsel-M-x)
       ([remap bookmark-jump] . counsel-bookmark) ;Jump to book or set it if it doesn't exist, C-x r b
       ([remap bookmark-set] . counsel-bookmark)  ;C-x r m
       ([remap find-file]  . counsel-find-file)
       ([remap describe-bindings] . counsel-descbinds)
       ([remap finder-by-keyword] . counsel-package) ;C-h p
       ([remap describe-variable] . counsel-describe-variable)
       ([remap describe-function] . counsel-describe-function))
      (bind-keys
       ("M-o" . counsel-recentf))
      (bind-to-modi-map "v" #'counsel-set-variable)
      (bind-keys
       :map read-expression-map
       ("C-r" . counsel-expression-history)) ; useful in `eval-expression' (`M-:')
      (bind-chords
       ("JJ" . counsel-imenu)
       ("'/" . counsel-grep-or-swiper)
       (";'" . counsel-M-x))
      (with-eval-after-load 'org
        (bind-keys
         :map org-mode-map
         ("C-c C-q" . counsel-org-tag))
        (bind-chords
         :map org-mode-map
         ("JJ" . counsel-org-goto)))    ;Jump to org headings
      (with-eval-after-load 'org-agenda
        (bind-key "C-c C-q" #'counsel-org-tag-agenda org-agenda-mode-map))))
  :config
  (progn
    ;; counsel-find-file
    (setq counsel-find-file-at-point t)
    (setq counsel-find-file-ignore-regexp
          (concat
           ;; file names beginning with # or .
           "\\(?:\\`[#.]\\)"
           ;; file names ending with # or ~
           "\\|\\(?:[#~]\\'\\)"))
    ;; Note that `ivy-extra-directories' should also not contain the "../" and
    ;; "./" elements if you don't want to see those in the `counsel-find-file'
    ;; completion list.
    (ivy-set-actions
     'counsel-find-file
     `(("x"
        (lambda (x) (delete-file (expand-file-name x ivy--directory)))
        ,(propertize "delete" 'face 'font-lock-warning-face))))

    ;; counsel-ag
    ;; Redefine `counsel-ag-base-command' with my required options, especially
    ;; the `--follow' option to allow search through symbolic links (part of
    ;; `modi/ag-arguments').
    ;; (setq counsel-ag-base-command "\\ag --vimgrep %s") ; default
    (setq counsel-ag-base-command
          ;; http://stackoverflow.com/a/12999828/1219634
          (concat (mapconcat #'shell-quote-argument
                             (append '("ag")
                                     modi/ag-arguments
                                     '("--noheading" ;No file names above matching content
                                       "--nocolor"
                                       ))
                             " ")
                  " %s"            ;This MUST be %s, not %S
                                        ;https://github.com/abo-abo/swiper/issues/427
                  ))
    ;; Show parent directory in the prompt
    (ivy-set-prompt 'counsel-ag #'counsel-prompt-function-dir)

    ;; counsel-rg
    ;; Redefine `counsel-rg-base-command' with my required options, especially
    ;; the `--follow' option to allow search through symbolic links (part of
    ;; `modi/rg-arguments').
    (setq counsel-rg-base-command
          (concat (mapconcat #'shell-quote-argument
                             (append '("rg")
                                     modi/rg-arguments
                                     '("--no-heading" ;No file names above matching content
                                       ))
                             " ")
                  " %s"            ;This MUST be %s, not %S
                                        ;https://github.com/abo-abo/swiper/issues/427
                  ))

    ;; counsel and org
    (defface modi/counsel-org-goto-level-1 '((t . (:inherit org-level-1 :weight normal)))
      "Face for Level 1 in `counsel-org-goto'.")
    (defface modi/counsel-org-goto-level-2 '((t . (:inherit org-level-2 :weight normal)))
      "Face for Level 2 in `counsel-org-goto'.")
    (defface modi/counsel-org-goto-level-3 '((t . (:inherit org-level-3 :weight normal)))
      "Face for Level 3 in `counsel-org-goto'.")
    (defface modi/counsel-org-goto-level-4 '((t . (:inherit org-level-4 :weight normal)))
      "Face for Level 4 in `counsel-org-goto'.")
    (defface modi/counsel-org-goto-level-5 '((t . (:inherit org-level-5 :weight normal)))
      "Face for Level 5 in `counsel-org-goto'.")
    (defface modi/counsel-org-goto-level-6 '((t . (:inherit org-level-6 :weight normal)))
      "Face for Level 6 in `counsel-org-goto'.")
    (defface modi/counsel-org-goto-level-7 '((t . (:inherit org-level-7 :weight normal)))
      "Face for Level 7 in `counsel-org-goto'.")
    (defface modi/counsel-org-goto-level-8 '((t . (:inherit org-level-8 :weight normal)))
      "Face for Level 8 in `counsel-org-goto'.")

    (setq counsel-org-goto-face-style 'custom)
    (setq counsel-org-goto-custom-faces '(modi/counsel-org-goto-level-1
                                          modi/counsel-org-goto-level-2
                                          modi/counsel-org-goto-level-3
                                          modi/counsel-org-goto-level-4
                                          modi/counsel-org-goto-level-5
                                          modi/counsel-org-goto-level-6
                                          modi/counsel-org-goto-level-7
                                          modi/counsel-org-goto-level-8))))


(provide 'setup-counsel)

;; Peek at files with `C-M-n' and `C-M-p'
;; Input a leading dot to see all files
;;
;; Related blog posts:
;; - http://oremacs.com/2015/06/08/describe-variable-tip
