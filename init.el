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

(use-package exec-path-from-shell
    :init
    (exec-path-from-shell-initialize))
;; SECTION -- window settings
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode)
;;start emacs maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setq initial-scratch-message ";;C-j evaluate\n;;C-x C-f to save buffer\n\n")

(use-package color-theme-sanityinc-tomorrow)
(load-theme 'sanityinc-tomorrow-eighties t)

(use-package diminish)  ; could try delight instead
    
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
             ;;FUZZY SEARCHING EVERYWHERE :DDD
             (setq ivy-re-builders-alist
                   '((t . ivy--regex-fuzzy))))

(use-package counsel
  :after ivy)

(use-package flx
  :after ivy)

(use-package ivy-rich
  :after ivy
  :config
  (ivy-rich-mode 1))

(use-package company
   :config
   (setq company-dabbrev-downcase nil)

   (use-package company-quickhelp
        :config
        (company-quickhelp-mode)))

(add-hook 'after-init-hook 'global-company-mode)

(use-package which-key
             :diminish
             :config
             (which-key-mode))

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

(use-package clojure-mode)
;;(use-package cider)

(use-package lsp-mode
  :after company
  :hook
  (python-mode . lsp)
  (groovy-mode . lsp)
  :commands lsp)

(defvar lsp-language-id-configuration
  '((groovy-mode . "groovy")
    (python-mode . "python")))

(use-package company-lsp
    :after lsp-mode
    :init
    (push 'company-lsp company-backends))

(use-package magit)
(use-package evil-magit
    :after magit
    :after evil)

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
  (setq org-log-done t))

(use-package evil-org
  :after org
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
            (lambda ()
              (evil-org-set-key-theme)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package org-bullets
    :config
    (add-hook 'org-mode-hook 'org-bullets-mode))

;; SECTION -- general keybindings
;; SPACEMACS-like keybinding
;; TODO: look into moving to evil-leader (general.el feels like a bit much)
(use-package general)
(general-define-key
  :prefix "SPC"
  :states 'normal
  "f" 'counsel-find-file
  "x" 'counsel-M-x
  "p" 'projectile-command-map

  ;; bookmark shortcuts
  "b" '(nil :wk "bookmarks")
  "b m" 'bookmark-set
  "b b" 'bookmark-jump
  "b d" 'counsel-bookmarked-directory
  "b l" '((lambda () (interactive) (call-interactively 'bookmark-bmenu-list)) :wk "list bookmarks")

  ;; buffer shortcuts
  "u" '(nil :wk "buffer")
  "u k" 'kill-buffer
  "u c" 'kill-current-buffer
  "u e" 'eval-buffer
  "u l" 'list-buffers
  "u u" 'switch-to-buffer
  
  ;; scrolling shortcuts
  "s" '(nil :wk "scroll")
  "s f" '(evil-scroll-page-down :wk "page-down")
  "s b" '(evil-scroll-page-up :wk "page-up")
  "s d" '(evil-scroll-down :wk "scroll down")
  "s u" '(evil-scroll-up :wk "scroll up")

  ;; terminal
  "t" '(shell-pop :wk "terminal"))

;; Bind these to control for use in visual-mode
(general-define-key
 :states 'visual
 ;;comments
 "C-c c" 'comment-region
 "C-c u" 'uncomment-region)

(general-define-key
    :states '(visual normal insert)
    ;; so i stop spamming search ;)
    "C-s" 'save-buffer)

(general-define-key
    :states '(normal insert visual)
    "C-," 'er/expand-region
    "C-c TAB" 'company-complete)

(general-define-key
    :states 'normal
    "/" 'swiper)

(provide 'init)
;;; init.el ends here
