
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(defun my/package-installed-p (pkg)
  "Check if package is installed. In emacs26 package-installed-p
seems to require package-initialize iff the package is *not*
installed. This prevents calling package-initialized if all
packages are already installed which improves startup time."
  (condition-case nil
      (package-installed-p pkg)
    (error
     (package-initialize)
     (package-installed-p pkg))))

(when (not (my/package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(setq use-package-always-ensure t)
(tool-bar-mode -1)
(global-display-line-numbers-mode)

(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))

(setq initial-scratch-message ";;C-j evaluate\n;;C-x C-f to save buffer\n\n")

;;get default shell
(setq my/osx-brew-zsh "/usr/local/bin/zsh")
(setq my/default-zsh "/bin/zsh")
(setq my/default-bash "/bin/bash")
(setq my/default-shell
      (if (file-exists-p my/osx-brew-zsh)
          my/osx-brew-zsh
        (if (file-exists-p my/default-zsh)
            my/default-zsh
          my/default-bash)))

;; dashboard could use some setup
(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo))

;; TODO: consider switching to helm
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
;; eViL        /   /     ||--+--|--+-/-|     \   \
;;            |   |     /'\_\_\ | /_/_/`\     |   |
;;             \   \__, \_     `~'     _/ .__/   /
;;              `-._,-'   `-._______,-'   `-._,-'
(use-package evil
             :config
             (evil-mode 1))

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

(use-package which-key
             :config
             (which-key-mode))

(use-package general)
(use-package color-theme-sanityinc-tomorrow)

(use-package multi-term
    :config
    (setq multi-term-program my/default-shell)
    (setq multi-term-dedicated-select-after-open-p t))

;; SPACEMACS-like keybinding
;; TODO: look into moving to evil-leader (general.el feels like a bit much)
(general-define-key
  :prefix "SPC"
  :states 'normal
  "f" 'counsel-find-file
  "x" 'counsel-M-x

  ;; bookmark shortcuts
  "b" '(nil :wk "bookmarks")
  "b m" 'bookmark-set
  "b b" 'bookmark-jump
  "b l" '((lambda () (interactive) (call-interactively 'bookmark-bmenu-list)) :wk "list bookmarks")

  ;; buffer shortcuts
  "u" '(nil :wk "buffer")
  "u k" 'kill-buffer
  "u e" 'eval-buffer
  "u l" 'list-buffers
  
  ;; scrolling shortcuts
  "s" '(nil :wk "scroll")
  "s f" '(evil-scroll-page-down :wk "page-down")
  "s b" '(evil-scroll-page-up :wk "page-up")
  "s d" '(evil-scroll-down :wk "scroll down")
  "s u" '(evil-scroll-up :wk "scroll up")

  ;; terminal
  "t" '(nil :wk "terminal")
  "t o" '(multi-term :wk "open terminal")
  "t t" '(multi-term-dedicated-toggle :wk "mini-term toggle")
  "t n" '(multi-term-next :wk "next terminal")
  "t p" '(multi-term-prev :wk "prev terminal"))

;; Bind these to control for use in visual-mode
(general-define-key
 :states 'visual
 ;;comments
 "C-c c" 'comment-region
 "C-c u" 'uncomment-region)

(general-define-key
    :states '(visual normal)
    ;; so i stop spamming search ;)
    "C-s" 'save-buffer)

;;start emacs maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;;paren mode is love; paren mode is life
(show-paren-mode 1)

;;hate tabs -- don't current like this setup need to redo indentation
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

;; custom shit:
;; TODO: move to separate file
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
        [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
        (vector "#1d1f21" "#cc6666" "#b5bd68" "#f0c674" "#81a2be" "#b294bb" "#8abeb7" "#c5c8c6"))
 '(beacon-color "#cc6666")
 '(custom-enabled-themes (quote (sanityinc-tomorrow-eighties)))
 '(custom-safe-themes
        (quote
         ("628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" default)))
 '(fci-rule-color "#373b41")
 '(flycheck-color-mode-line-face-to-color (quote mode-line-buffer-id))
 '(frame-background-mode (quote dark))
 '(package-selected-packages
        (quote
         (powerline-evil dashboard magit yaml-mode general neotree ivy which-key evil python-mode color-theme-sanityinc-tomorrow groovy-mode)))
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
        (quote
         ((20 . "#cc6666")
          (40 . "#de935f")
          (60 . "#f0c674")
          (80 . "#b5bd68")
          (100 . "#8abeb7")
          (120 . "#81a2be")
          (140 . "#b294bb")
          (160 . "#cc6666")
          (180 . "#de935f")
          (200 . "#f0c674")
          (220 . "#b5bd68")
          (240 . "#8abeb7")
          (260 . "#81a2be")
          (280 . "#b294bb")
          (300 . "#cc6666")
          (320 . "#de935f")
          (340 . "#f0c674")
          (360 . "#b5bd68"))))
 '(vc-annotate-very-old-color nil)
 '(vterm-shell "/usr/local/bin/zsh")
 '(window-divider-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
