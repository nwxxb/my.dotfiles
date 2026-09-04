;;; init.el --- Init File -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:
;; this file executed for Emacs configuration

;;; Code:

(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-x C-b") 'ibuffer)

(show-paren-mode 1)             ;; show the pair of a parenthesis under cursor
(savehist-mode 1)               ;; persists minibuffer history TODO: extract this into another package
(repeat-mode 1)

;; reversible C-x 1
(winner-mode +1)
(defun toggle-delete-other-windows ()
  "Delete other windows in frame if any, or restore previous window config."
  (interactive)
  (if (and winner-mode
           (equal (selected-window) (next-window)))
      (winner-undo)
    (delete-other-windows)))

(global-set-key (kbd "C-x 1") #'toggle-delete-other-windows)

(setq-default indent-tabs-mode nil) ;; don't allow tabs and use space
                                    ;; by default (another mode might
                                    ;; change it)

(setq use-short-answers t                     ;; enable to use "y" or "n" to a confirmation
      apropos-do-all t                        ;; more beginner friendly apropos
      save-interprogram-paste-before-kill t   ;; push clipboard (e.g. an url from browser) to kill ring
      kill-do-not-save-duplicates t           ;; don't duplicate kill entry
      delete-selection-mode 1                 ;; enable replacing selected text with typed text
      mouse-yank-at-point t                   ;; if you use the "paste" click, paste it on emac's point/cursor
      history-length 25                       ;; set the length of command history
      savehist-additional-variables           ;; expand savehist to these rings below
      '(search-ring regexp-search-ring kill-ring)
      completion-ignore-case t                ;; e.g. on hippie expand
      read-buffer-completion-ignore-case t    ;; e.g. searching buffer
      read-file-name-completion-ignore-case t ;; e.g. ignore case when searching file
      search-default-mode t                   ;; enable regexp on isearch (the prompt might not contain word "regexp")
      delete-by-moving-to-trash t             ;; move deleted files to trash instead of permanently remove it
      ffap-machine-p-known 'reject            ;; prevent freeze when use find-file-at-point & cursor above a hostname
      reb-re-syntax 'string                   ;; prevent doing double escaping (e.g. "\\(") on re-builder cmd
      )

;; emacs built-in ui setting
(setq global-hl-line-mode nil                                ;; don't colorize current cursor line
      ediff-window-setup-function 'ediff-setup-windows-plain ;; don't open new frame just to show help on ediff
      frame-inhibit-implied-resize t                         ;; prevent implicit resize
      column-number-mode t                                   ;; display current column cursor in modeline
      visible-bell nil                                       ;; remove visual blinking
      ring-bell-function 'ignore                             ;; remove noisy bell
      scroll-conservatively 0                                ;; as long as it's not 0, the point/cursor won't re-centered while we scroll
      scroll-margin 15                                       ;; add margin when we scroll
      window-combination-resize t                            ;; prevent possibility of tiny window while others stay large on splitted windows
      display-line-numbers-width-start t
      )

;; tab-bar (enable showing different frame/"window config" in different tab
(setq tab-bar-show 1
      tab-bar-new-tab-choice t
      tab-bar-tab-hints t)
(tab-bar-mode 1)

(setq-default truncate-lines t)   ;; don't wrap long lines

;; emacs 31 new knob
(if (> emacs-major-version 30)
    (setq view-lossage-auto-refresh t
          native-comp-async-on-battery-power nil
          kill-region-dwim 'emacs-word
          ibuffer-human-readable-size t))

;; emacs 31: builtin treesitter
(if (> emacs-major-version 30)
    (setq treesit-auto-install-grammar 'ask
	  treesit-enabled-modes t))

(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; set font
(set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 100)

;; recenter after save-place restores position
;; TODO: elisp: comprehend this
(advice-add 'save-place-find-file-hook :after
            (lambda (&rest _)
              (when buffer-file-name (ignore-errors (recenter)))))

;; files backup
(setq make-backup-files nil) ;; let's not backup edited files (see files that has name end with "~")

;; isolate setting from M-x customize
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
;; beware that custom file like this might trip you up. if you notice a setting keep persisting
;; across session, maybe it exists on custom.el. It's good to:
;; 1. see the custom.el and... 2. then copy it to init.el in order for the changes to persist on next emacs session
;;
;; However, we still need to load the custom.el below for setting like: supressing warning
(when (file-exists-p custom-file) (load-file custom-file))

;; Define a global customizable variable `my-use-nerd-fonts' to control the use of
;; Nerd Fonts symbols throughout the configuration. This boolean variable allows
;; users to easily enable or disable the use of symbols from Nerd Fonts, providing
;; flexibility in appearance settings. By setting it to `t', we enable Nerd Fonts
;; symbols; setting it to `nil' would disable them.
(defcustom my-use-nerd-fonts t
  "Configuration for using Nerd Fonts Symbols."
  :type 'boolean
  :group 'appearance)

;;; Package manager
;; Setup Elpaca
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Uncomment for systems which cannot create symlinks:
;; (elpaca-no-symlink-mode)

;; Infuse elpaca into the use-package macro
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;; ;; FIX; apparently elpaca will prefer built-in and not pull in what magit needs
;; ;; Only needed in emacs 30
;; ;; This can probably go away in the future versions of Emacs
;; ;; https://github.com/progfolio/elpaca/issues/272#issuecomment-2298727726
;; (setq elpaca-ignored-dependencies
;;       (delq 'transient elpaca-ignored-dependencies))

;;; Minibuffer setting

;; see the current modeline in your buffer
;; you can see (list of modes...) which can be really long
;; let's tidy this up
(use-package diminish
  :ensure (:wait t)
  :demand t)

;; eldoc is a builtin tool to see a quick help
;; on your minibuffer
(use-package eldoc
  :ensure nil
  :diminish eldoc-mode
  :custom
  (eldoc-idle-delay 1)
  (eldoc-echo-area-use-multiline-p t)
  (eldoc-echo-area-display-truncation-message t)
  (eldoc-help-as-pt t)
  :hook
  (elpaca-after-init . global-eldoc-mode))

(use-package eldoc-box
  :ensure t
  :defer t)

;; directly show options below mini-buffer instead of using the
;; default separate buffer, and spread out all candidate in one column
;; (almost like dropdown)
(use-package vertico
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . vertico-mode)
  :custom
  (vertico-count 10)
  (vertico-resize nil))

;; fill up the empty right side of vertico with helpful info
(use-package marginalia
  :ensure t
  :defer t
  :init (marginalia-mode 1))

;; flexible pattern matching for mini buffer completions
(use-package orderless
  :ensure t
  :defer t
  :after vertico
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; show you a pop up help if you are confused
;; when typing combos
(use-package which-key
  :ensure nil
  :defer t
  :diminish which-key-mode
  :hook
  (after-init . which-key-mode))

;;; In Buffer editing
;; Corfu: emacs's in-buffer auto-completion
(use-package corfu
  :ensure t
  :defer t
  :hook ((prog-mode . corfu-mode)
         (prog-mode . corfu-popupinfo-mode))
  :custom
  (tab-always-indent 'complete) ;; in order for corfu to work, we have mutate the tab function
  (corfu-auto nil)              ;; only completes when hitting TAB
  (corfu-auto-prefix 1)         ;; Trigger completion after typing 1 character
  (corfu-quit-no-match t)       ;; Quit popup if no match
  (corfu-scroll-margin 5)       ;; Margin when scrolling completions
  (corfu-max-width 50)          ;; Maximum width of completion popup
  (corfu-min-width 50)          ;; Minimum width of completion popup
  (corfu-popupinfo-delay 0.5)  ;; Delay before showing documentation popup
  :config
  (if my-use-nerd-fonts
      (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)))

(use-package editormode
  :ensure nil
  :defer t
  :hook
  (elpaca-after-init . editorconfig-mode))

;; crux: extend the emacs-vanilla-keybind
(use-package crux
  :ensure t
  :defer t
  :bind (("C-g" . crux-keyboard-quit-dwim)
         ("C-o" . crux-smart-open-line)
         ("C-c d" . crux-duplicate-current-line-or-region)))

;;; Utils
;; Dired: for discovering directory
(use-package dired
  :ensure nil
  :defer t
  :commands (dired)
  :hook
  ((dired-mode . hl-line-mode))
  :config
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'top)
  (setq delete-by-moving-to-trash t)
  (setq dired-dwim-target t))

(use-package dired-subtree
  :ensure t
  :defer t
  :after dired
  :bind
  ( :map dired-mode-map
    ("<tab>" . dired-subtree-toggle)
    ("TAB" . dired-subtree-toggle)
    ("<backtab>" . dired-subtree-remove)
    ("S-TAB" . dired-subtree-remove))
  :config
  (setq dired-subtree-use-backgrounds nil))

;;; project.el: switching and managing project
(use-package project
  :ensure nil
  :defer t
  :custom
  ;; stop annoying prompt when switching to a project, and open project on dired instead
  (project-switch-commands 'project-dired)
  (project-vc-extra-root-markers '(".project" ".projectile"))
  (project-mode-line t))

;;; eglot: built in emacs lsp client
(use-package eglot
  :ensure nil
  :defer t
  :config
  (with-eval-after-load 'eglot
    ;; register new LSP server outside of the defaults coming from eglot
    (add-to-list 'eglot-server-programs '((ruby-mode ruby-ts-mode) . ("mise" "x" "--" "ruby-lsp")))

    ;; disabling unneeded LSP server capabilities
    (add-to-list 'eglot-ignored-server-capabilities :documentOnTypeFormattingProvider)
    (add-to-list 'eglot-ignored-server-capabilities :semanticTokensProvider))

  ;; (setq-default eglot-workspace-configuration
  ;;               '(
  ;;                 :ruby-lsp (:initializationOptions (:formatter "auto"))
  ;;                 ))
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect nil)
  (eglot-send-changes-idle-time 0.5)
  (eglot-extend-to-xref t)
  (eglot-code-action-indications nil)
  (eglot-events-buffer-config '(:size 0 :format short))

  :hook
  (eglot-managed-mode . eglot-inlay-hints-mode)
  (prog-mode
   .
   (lambda ()
     (unless (eq major-mode 'emacs-lisp-mode)
       (eglot-ensure))))
  (before-save
   .
   (lambda ()
     (if (eglot-managed-p)
         (eglot-format))))

  :bind
  (:map
   eglot-mode-map
   ("C-c c a" . eglot-code-actions)
   ("C-c c o" . eglot-code-actions-organize-imports)
   ("C-c c r" . eglot-rename)
   ("C-c c f" . eglot-format)))

;; flycheck: alternative to built-in flymake
(use-package flycheck
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . global-flycheck-mode)
  :config
  (global-flycheck-eglot-mode 1))

;;; org mode, super-charged and mutated markdown in emacs
(use-package org
  :ensure nil
  :defer t
  :custom
  (org-agenda-files (list "~/org/"))
  (org-agenda-filter-preset '("-personal"))
  (org-agenda-window-setup 'other-window)
  (org-startup-folded 'show2levels)
  (org-startup-indented t)
  (org-agenda-restore-windows-after-quit t)
  (org-tags-column 0)
  (org-ellipsis " 󱞤")
  :config
  (add-to-list 'project-kill-buffer-conditions '(derived-mode . org-agenda-mode)))

;; magit: A Git Porcelain inside Emacs
;; TODO: connect magit to preject.el
(use-package magit
  :ensure t
  :defer t
  :commands (magit-status))

;; TOOD: connect it with project.el (and make sure we can open
;; terminal per project)
;; 
;; may need another package: libvterm-dev
(use-package vterm
  :ensure t
  :defer t
  :init
  (defun my-project-shell ()
    "Start an inferior shell in the current project's root directory.
  If a buffer already exists for running a shell in the project's root,
  switch to it.  Otherwise, create a new shell buffer.
  With \\[universal-argument] prefix arg, create a new inferior shell buffer even
  if one already exists."
    (interactive)
    (require 'comint)
    (let* ((default-directory (project-root (project-current t)))
           (default-project-shell-name (project-prefixed-buffer-name "shell"))
           (shell-buffer (get-buffer default-project-shell-name)))
      (if (and shell-buffer (not current-prefix-arg))
          (if (comint-check-proc shell-buffer)
              (pop-to-buffer shell-buffer (bound-and-true-p display-comint-buffer-action))
            (vterm shell-buffer))
        (vterm (generate-new-buffer-name default-project-shell-name)))))
  
  (advice-add 'project-shell :override #'my-project-shell)
  :config
  (add-to-list 'project-kill-buffer-conditions '(derived-mode . vterm-mode)))
    

;;; kkp: enable kitty keyboard protocol in emacs terminal
;; most terminal emulator cannot recognize shortcut like C-;
;; so we must to make sure
;; 1) enable kitty keyboard protocol in terminal emulator (you don't have to use kitty)
;; 2) make emacs follow the kitty keyboard protocol
(use-package kkp
  :ensure t
  :defer t
  :hook (tty-setup . global-kkp-mode))

;; (use-package exec-path-from-shell
;;   :ensure t
;;   :if (memq window-system '(mac ns x pgtk))
;;   :config
;;   (exec-path-from-shell-initialize))

(use-package ultra-scroll
  :ensure t
  :defer t
  :init
  (setq scroll-conservatively 3) ; or whatever value you prefer, since v0.4
        ;scroll-margin 0)        ; scroll-margin>0 is now supported, since v0.7
  :config
  (ultra-scroll-mode 1))

;;; Appearances
;;; NERD ICONS
;; don't forget to run `M-x nerd-icons-install-fonts` to fetch the icons
;; The `nerd-icons' package provides a set of icons for use in Emacs. These icons can
;; enhance the visual appearance of various modes and packages, making it easier to
;; distinguish between different file types and functionalities.
(use-package nerd-icons
  :if my-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
  :ensure t                               ;; Ensure the package is installed.
  :defer t)                               ;; Load the package only when needed to improve startup time.

;;; NERD ICONS Dired
;; The `nerd-icons-dired' package integrates nerd icons into the Dired mode,
;; providing visual icons for files and directories. This enhances the Dired
;; interface by making it easier to identify file types at a glance.
(use-package nerd-icons-dired
  :if my-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
  :ensure t                               ;; Ensure the package is installed.
  :defer t                                ;; Load the package only when needed to improve startup time.
  :diminish nerd-icons-dired-mode
  :hook
  (dired-mode . nerd-icons-dired-mode))

;;; NERD ICONS COMPLETION
;; The `nerd-icons-completion' package enhances the completion interfaces in
;; Emacs by integrating nerd icons with completion frameworks such as
;; `marginalia'. This provides visual cues for the completion candidates,
;; making it easier to distinguish between different types of items.
(use-package nerd-icons-completion
  :if my-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
  :ensure t                               ;; Ensure the package is installed.
  :after (:all nerd-icons marginalia)     ;; Load after `nerd-icons' and `marginalia' to ensure proper integration.
  :config
  (nerd-icons-completion-mode)            ;; Activate nerd icons for completion interfaces.
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup)) ;; Setup icons in the marginalia mode for enhanced completion display.

;;; NERD-ICONS-CORFU
;; Provides Nerd Icons to be used with CORFU.
(use-package nerd-icons-corfu
  :if my-use-nerd-fonts
  :ensure t
  :defer t
  :after (:all corfu))

;;; Diff-hl: show on buffer/dired when something get mutated
(use-package diff-hl
  :ensure t
  :defer t
  :hook
  (find-file . (lambda ()
                 (global-diff-hl-mode)           ;; Enable Diff-HL mode for all files.
                 (diff-hl-flydiff-mode)          ;; Automatically refresh diffs.
                 (diff-hl-margin-mode)))         ;; Show diff indicators in the margin.
  (dired-mode . diff-hl-dired-mode)
  :custom
  (diff-hl-side 'left)                           ;; Set the side for diff indicators.
  (diff-hl-margin-symbols-alist '((insert . "┃") ;; Customize symbols for each change type.
                                  (delete . "┃")
                                  (change . "┃")
                                  (unknown . "┆")
                                  (ignored . "i"))))

(use-package tokyo-night
  :ensure t
  :demand t
  :config (load-theme 'tokyo-night t))

;; TODO put this to my.dotfiles
;; DONE see redux's blog on popular built in setting
;; DONE overwrite marked region
;; DONE setup packages installer
;; TODO dired (also learn it)
;; TODO flymake and eldoc (setup and how to navigate)
;; TODO ediff (also learn it)
;; DONE installing terminal (eat or vterm)
;; TODO vertico marginalia
;; TODO external: connecting mise to the emacs's shell-command (M-!)
;; TODO magit
;; TODO eglot
;; TODO formatter & remove whitespace automatically
;; TODO trying elisp
;; TODO Basic Workflow
;; - search and replace on file
;; - search and replace on project
;; - move around variable and function
;; - run a command, put stdout on buffer, and navigate around
;; TODO Org mode
;; - agenda
;; - use as presentation
;; - use as spreadsheet
;; - export to pdf and markdown
;; TODO tramp for remote editing
;; TODO lib for AI
;; TODO cosmetic:
;; - how to customize modeline
;; - change font style & size

(add-hook 'after-init-hook
                (lambda ()
                        (message "Emacs has fully loaded. This code runs after startup.")
                        (with-current-buffer (get-buffer-create "*scratch*")
        (insert (format
                 ";;     ...
;;  ....
;; ..             Welcome to Emacs!
;;  ......
;;       ...      Load time: %s
;;    ...
;;   ..
;;    ..........
"
                 (emacs-init-time))))))

;;; init.el ends here
