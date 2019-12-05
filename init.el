 ;;; init.el --- Drew's emacs config
 ;;; Commentary:
 ;;; Code:

;; optimizations to speed up start-up time (per John Wiegley)
(defvar file-name-handler-alist-old file-name-handler-alist)

(setq package-enable-at-startup nil
      file-name-handler-alist nil
      message-log-max 16384
      gc-cons-threshold 402653184
      gc-cons-percentage 0.6
      auto-window-vscroll nil)

;; SECTION -- files

;; use emacs-local for environment specific resources
(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))

(defvar my/emacs-local-resources (expand-file-name "emacs-local" (getenv "HOME")))
(unless (file-directory-p my/emacs-local-resources)
  (make-directory my/emacs-local-resources))

;; put packages in separate repo
(setq package-user-dir (expand-file-name "elpa" my/emacs-local-resources))
(unless (file-directory-p package-user-dir)
  (make-directory package-user-dir))

;; Keep emacs "custom" settings in separate file and load it
(setq custom-file (expand-file-name "custom-file.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)

;https://emacsredux.com/blog/2013/05/09/keep-backup-and-auto-save-files-out-of-the-way/
;; store all backup and autosave files in specified backups directory
(defvar my/backup-directory (expand-file-name "backups" my/emacs-local-resources))
(unless (file-directory-p my/backup-directory)
  (make-directory my/backup-directory))

(setq recentf-save-file (expand-file-name "recentf" my/emacs-local-resources))
;; still creating eshell directory TODO: find a way to move this as well
(setq eshell-history-file-name (expand-file-name "eshell-history" my/emacs-local-resources))
(setq auto-save-list-file-name (expand-file-name "auto-save-list" my/backup-directory))

(setq backup-directory-alist
      `((".*" . ,my/backup-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,my/backup-directory t)))
(setq auto-save-visited-model t)

;; add local binaries to path
;;(add-to-list 'exec-path "~/bin")
;; TODO: do I need to add /usr/local/bin for brew?
;; maybe use exec-path-from-shell

;; SECTION -- packaging
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(package-initialize)

;; Don't load stale byte-compiled files
(setq load-prefer-newer t)

(defun my/package-install-refresh-contents (&rest args)
    (package-refresh-contents)
    (advice-remove 'package-install 'my/package-install-refresh-contents))

(advice-add 'package-install :before 'my/package-install-refresh-contents)

(when (not (package-installed-p 'use-package))
    (package-install 'use-package))

(eval-when-compile
    (require 'use-package)
    (setq use-package-always-ensure t))
;;    (setq use-package-always-defer t))

(use-package benchmark-init
  :disabled
  :config
  ;; To disable collection of benchmark data after init is done.
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

(use-package exec-path-from-shell
    :init
    (exec-path-from-shell-copy-env "WORKON_HOME")
    (exec-path-from-shell-initialize))

;; SECTION -- window settings
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode)
;;start emacs maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setq initial-scratch-message ";;C-j evaluate\n;;C-x C-f to save buffer\n\n")

;; (use-package color-theme-sanityinc-tomorrow)
;; (load-theme 'sanityinc-tomorrow-eighties t)

(use-package diminish)  ; could try delight instead

(use-package golden-ratio
    :diminish
    :init (golden-ratio-mode 1))

;; (use-package spaceline
;;   :init
;;   (use-package fancy-battery
;;     :init (fancy-battery-mode))
;;   (use-package spaceline-all-the-icons
;;     :after fancy-battery
;;     :config
;;     (spaceline-all-the-icons-theme)
;;     (spaceline-all-the-icons--setup-git-ahead)
;;     (spaceline-all-the-icons--setup-package-updates)
;;     (spaceline-toggle-all-the-icons-narrowed-on)
;;     (spaceline-toggle-all-the-icons-battery-status-on)
;;     (spaceline-toggle-all-the-icons-buffer-position-on)))

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode))

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;; (load-theme 'doom-city-lights t)
  (load-theme 'doom-Iosvkem t)
  
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; dashboard could use some setup
(defvar dashboard-dir (expand-file-name "elisp/dashboard" user-emacs-directory))
(use-package dashboard
  :load-path dashboard-dir
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-banner-logo-title "Drew's eViLmacs")
  (setq dashboard-items '((recents  . 15)
                          (bookmarks . 15)
                          (projects . 15)))
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-set-init-info t)
  (setq dashboard-set-navigator t)
  (setq dashboard-startup-banner 4))

(use-package restart-emacs)

;; SECTION -- terminal
;; TL;DR -- simple eshell
(use-package shell-pop)

(use-package eshell-prompt-extras
    :init
    (use-package virtualenvwrapper)
    (venv-initialize-eshell)
    (with-eval-after-load "esh-opt"
    (autoload 'epe-theme-lambda "eshell-prompt-extras")
    (setq eshell-highlight-prompt nil
            eshell-prompt-function 'epe-theme-lambda)))

;; SECTION -- coding modes
(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

(use-package gh-md
  :after markdown-mode)

;; SECTION -- Completion
(use-package ivy
             :config
             (ivy-mode 1)
             (setq ivy-use-virtual-buffers t)
             (setq ivy-count-format "(%d/%d) ")
             ;;FUZZY SEARCHING EVERYWHERE (except swiper):DDD
             (setq ivy-re-builders-alist
                   '((swiper-isearch . ivy--regex-plus)
                     (t . ivy--regex-fuzzy))))

(use-package counsel
  :config
  (setcdr (assoc 'counsel-M-x ivy-initial-inputs-alist) "")
  :after ivy)

(use-package flx
  :after ivy)

(use-package ivy-rich
  :after ivy
  :config
  (ivy-rich-mode 1))

(use-package flyspell)

(use-package company
   :diminish
   :init
   (global-company-mode 1)
   (setq company-dabbrev-downcase nil)

   (use-package company-quickhelp
        :config
        (company-quickhelp-mode)))


(add-hook 'after-init-hook 'global-company-mode)

(use-package which-key
             :diminish
             :config
             (which-key-mode)
             (setq which-key-sort-order 'which-key-description-order))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package flycheck-pos-tip
  :after flycheck
  :init (flycheck-pos-tip-mode))

;; SECTION -- indention // parens
;;paren mode is love; paren mode is life
(show-paren-mode 1)

;;hate tabs -- don't current like this setup need to redo indentation
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

(use-package indent-guide
  :diminish
  :config
  (set-face-background 'indent-guide-face "red")
  (indent-guide-global-mode))

(use-package rainbow-delimiters
  :config
  (add-hook 'groovy-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'python-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode))

(use-package smartparens
    :diminish
    :config
    (require 'smartparens-config)
    (smartparens-global-mode 1))

(use-package expand-region)

;; SECTION -- DEV

(use-package groovy-mode
    :config
    (setq groovy-indent-offset 4))

(use-package anaconda-mode
  :config
  (add-hook 'python-mode-hook 'anaconda-mode)
  (use-package company-anaconda))

(eval-after-load "company"
 '(add-to-list 'company-backends 'company-anaconda))

(use-package clojure-mode)
;;(use-package cider)

(use-package lsp-mode
  :after company
  :hook
  ;; (python-mode . lsp-deferred)
  (groovy-mode . lsp-deferred)
  :commands lsp)

(defvar lsp-language-id-configuration
  '((groovy-mode . "groovy")))
    ;; (python-mode . "python")))

(use-package company-lsp
    :after lsp-mode
    :init
    (push 'company-lsp company-backends))

(use-package magit
    :defer 5)

(use-package yasnippet
    :config
    (yas-global-mode 1)
    (use-package yasnippet-snippets))

;; SECTION -- EVIL
;;                             ,-.
;;        ___,---.__          /'|`\          __,---,___
;;     ,-'    \`    `-.____,-'  |  `-.____,-'    //    `-.
;;   ,'        |           ~'\     /`~           |        `.
;;  /      ___//              `. ,'          ,  , \___      \
;; |    ,-'   `-.__   _         |        ,    __,-'   `-.    |
;; |   /          /\_  `   .    |    ,      _/\          \   |
;; \  |           \ \`-.___ \   |   / ___,-'/ /           |  /
;;  \  \           | `._   `\\  |  //'   _,' |           /  /
;;   `-.\         /'  _ `---'' , . ``---' _  `\         /,-'
;;      ``       /     \    ,='/ \`=.    /     \       ''
;;              |__   /|\_,--.,-.--,--._/|\   __|
;;              /  `./  \\`\ |  |  | /,//' \,'  \
;; eViL-mode4life  /     ||--+--|--+-/-|     \   \
;;            |   |     /'\_\_\ | /_/_/`\     |   |
;;             \   \__, \_     `~'     _/ .__/   /
;;              `-._,-'   `-._______,-'   `-._,-'

(defun my/save-and-kill-buffer ()
    (interactive)
    (save-buffer)
    (kill-current-buffer)
)

(use-package evil
             :init
             (setq evil-want-keybinding nil)
             :config
             (evil-ex-define-cmd "q" 'kill-current-buffer)
             (evil-ex-define-cmd "wq" 'my/save-and-kill-buffer)
             (evil-ex-define-cmd "quit" 'evil-save-and-quit)
             (evil-mode 1))

(use-package evil-collection
  :after evil
  :custom (evil-collection-setup-minibuffer t)
  :init (evil-collection-init))

;; SECTION -- project management
(use-package neotree
             :requires evil
             :config
             (global-set-key [f8] 'neotree-toggle)
             (evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
             (evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
             (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
             (evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
             (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
             (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-next-line)
             (evil-define-key 'normal neotree-mode-map (kbd "p") 'neotree-previous-line)
             (evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
             (evil-define-key 'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle))

(use-package projectile
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
  :init
  (setq projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" my/emacs-local-resources))
  (setq projectile-completion-system 'ivy))

(use-package counsel-projectile
    :after (counsel projectile)
    :init (counsel-projectile-mode))

;; SECTION -- ORG MODE
(use-package org
  :ensure org-plus-contrib
  :config
  (require 'ox-confluence)
  (require 'ox-beamer)
  (setq org-log-done t)

  :config
  (use-package org-bullets)
  (use-package org-present)
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
            (lambda ()
              (evil-org-set-key-theme)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  (setq org-present-text-scale 4)
  (add-hook 'org-mode-hook 'org-bullets-mode)
  (add-hook 'org-mode-hook 'org-bullets-mode))


(eval-after-load "org-present"
  '(progn
     (add-hook 'org-present-mode-hook
               (lambda ()
                 (org-present-big)
                 (org-display-inline-images)
                 (org-present-hide-cursor)
                 (org-present-read-only)))
     (add-hook 'org-present-mode-quit-hook
               (lambda ()
                 (org-present-small)
                 (org-remove-inline-images)
                 (org-present-show-cursor)
                 (org-present-read-write)))))

(setq org-agenda-custom-commands
      '(("h" "Agenda and Home-related tasks"
            ((agenda "")
             (todo ""))
             ((org-agenda-files '("~/org/personal-notes.org"))))
        ("w" "Work Agenda and Tasks"
            ((agenda "")
             (todo ""))
            ((org-agenda-files '("~/org/nike-work-notes.org"))))))

(setq org-default-notes-file (concat org-directory "/inbox.org"))
(setq org-refile-targets '(("~/org/nike-work-notes.org" :maxlevel . 1)
                           ("~/org/personal-notes.org" :maxlevel . 1)
                           ("~/org/emacs-notes.org" :maxlevel . 1)
                           (nil :maxlevel . 9)))

;; SECTION -- keybindings
;; SPACEMACS-like keybinding
(defvar my/leader-map
  (make-sparse-keymap)
  "Keymap for 'leader' keys.")

(evil-define-key 'normal global-map (kbd "SPC") my/leader-map)
(evil-define-key 'insert global-map (kbd "C-<SPC>") my/leader-map)
(evil-define-key 'visual global-map (kbd "C-<SPC>")my/leader-map)

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
(define-key my/leader-map "w" 'widen)

(define-key my/leader-map "oa" 'org-agenda)
(define-key my/leader-map "ol" 'org-store-link)
(define-key my/leader-map "or" 'org-refile)
(define-key my/leader-map "oe" '(lambda () (interactive) (find-file "~/org/emacs-notes.org")))
(define-key my/leader-map "op" '(lambda () (interactive) (find-file "~/org/personal-notes.org")))
(define-key my/leader-map "ow" '(lambda () (interactive) (find-file "~/org/nike-work-notes.org")))
(define-key my/leader-map "oi" '(lambda () (interactive) (find-file "~/org/inbox.org")))

(which-key-add-key-based-replacements "<SPC> o" "org-prefix")
(which-key-add-key-based-replacements "<SPC> oe" "emacs notes")
(which-key-add-key-based-replacements "<SPC> op" "personal notes")
(which-key-add-key-based-replacements "<SPC> ow" "work notes")
(which-key-add-key-based-replacements "<SPC> oi" "inbox")

(define-key my/leader-map "D" 'counsel-descbinds)

(define-key my/leader-map "yn" 'yas-new-snippet)
(define-key my/leader-map "ye" 'yas-expand)

(which-key-add-key-based-replacements "<SPC> y" "yas-prefix")

(define-key my/leader-map "t" 'shell-pop)

;;(evil-global-set-key 'motion "C-," 'er/expand-region)
(evil-global-set-key 'normal "/" 'swiper-isearch)
(evil-global-set-key 'visual (kbd "C-c c") 'comment-region)
(evil-global-set-key 'visual (kbd "C-c u") 'uncomment-region)

(evil-define-minor-mode-key 'normal 'org-present-mode (kbd "n") 'org-present-next)
(evil-define-minor-mode-key 'normal 'org-present-mode (kbd "p") 'org-present-prev)
(evil-define-minor-mode-key 'normal 'org-present-mode (kbd "q") 'org-present-quit)

(provide 'init.el)
;;; init.el ends here
