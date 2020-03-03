;;; One place for all my keybinds

(defvar my/leader-map
  (make-sparse-keymap)
  "Keymap for 'leader' keys.")

(evil-define-key 'normal global-map (kbd "SPC") my/leader-map)
(evil-define-key 'insert global-map (kbd "C-<SPC>") my/leader-map)
(evil-define-key 'visual global-map (kbd "C-<SPC>") my/leader-map)

(which-key-add-key-based-replacements "<SPC> c" "open config")
(define-key my/leader-map "c" '(lambda () (interactive) (find-file "~/.emacs.d/init.el")))

(define-key my/leader-map "f" 'counsel-find-file)
(define-key my/leader-map "x" 'counsel-M-x)
(define-key my/leader-map "p" 'projectile-command-map)
(define-key my/leader-map "m" 'bookmark-set)
(define-key my/leader-map "b" 'bookmark-jump)
(define-key my/leader-map "d" 'counsel-bookmarked-directory)
(define-key my/leader-map "k" 'kill-buffer)
(define-key my/leader-map "c" 'kill-current-buffer)
(define-key my/leader-map "e" 'eval-buffer)
(define-key my/leader-map "l" 'list-buffers)
(define-key my/leader-map "u" 'ivy-switch-buffer)
;; (define-key my/leader-map "w" 'widen)
(define-key my/leader-map "r" 'ranger)
(define-key my/leader-map "t" 'shell-pop)
(define-key my/leader-map "D" 'counsel-descbinds)

(which-key-add-key-based-replacements "<SPC> g" "magit-prefix")
(define-key my/leader-map "gs" 'magit-status)
(define-key my/leader-map "gc" 'magit-clone)
(define-key my/leader-map "gl" 'magit-log)
(define-key my/leader-map "gb" 'magit-branch-and-checkout)

(which-key-add-key-based-replacements "<SPC> o" "org-prefix")
(define-key my/leader-map "oa" 'org-agenda)
(define-key my/leader-map "ol" 'org-store-link)
(define-key my/leader-map "or" 'org-refile)
(define-key my/leader-map "ox" 'org-export-dispatch)
(define-key my/leader-map "oc" 'org-confluence-export-as-confluence)

(which-key-add-key-based-replacements "<SPC> oe" "emacs notes")
(define-key my/leader-map "oe" '(lambda () (interactive) (find-file "~/org/emacs-notes.org")))

(which-key-add-key-based-replacements "<SPC> op" "personal notes")
(define-key my/leader-map "op" '(lambda () (interactive) (find-file "~/org/personal-notes.org")))

(which-key-add-key-based-replacements "<SPC> ow" "work notes")
(define-key my/leader-map "ow" '(lambda () (interactive) (find-file "~/org/nike-work-notes.org")))

(which-key-add-key-based-replacements "<SPC> oi" "inbox")
(define-key my/leader-map "oi" '(lambda () (interactive) (find-file "~/org/inbox.org")))

(which-key-add-key-based-replacements "<SPC> w" "window-prefix")
(define-key my/leader-map "wo" 'other-window)
(define-key my/leader-map "wd" 'delete-other-windows)
(define-key my/leader-map "wv" 'evil-window-vsplit)
(define-key my/leader-map "ws" 'evil-window-split)
(define-key my/leader-map "wq" 'evil-quit)

(which-key-add-key-based-replacements "<SPC> y" "yas-prefix")
(define-key my/leader-map "yn" 'yas-new-snippet)

;;(evil-global-set-key 'motion "C-," 'er/expand-region)
(evil-global-set-key 'normal "/" 'swiper-isearch)
(evil-global-set-key 'visual (kbd "C-c c") 'comment-region)
(evil-global-set-key 'visual (kbd "C-c u") 'uncomment-region)

(evil-define-minor-mode-key 'normal 'org-present-mode (kbd "n") 'org-present-next)
(evil-define-minor-mode-key 'normal 'org-present-mode (kbd "p") 'org-present-prev)
(evil-define-minor-mode-key 'normal 'org-present-mode (kbd "q") 'org-present-quit)

(provide 'keybinds.el)
