;;; early-init.el --- Early Init -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:
;; this file executed before init.el

;;; Code:

;; Gnome Wayland GTK Specific: running restart-emacs command will
;; spawn a new separate program with different StartupWMClass which
;; make the emacs icon disappear. We need to make sure that
;; StartupWMClass remain consistent wherever we spawn the emacs
(setq x-resource-name "emacs")
(setq x-resource-class "Emacs")

;; GC: Temporarily bumps up GC threshold when we're opening emacs
;; Temporarily increase GC threshold during startup
(setq gc-cons-threshold most-positive-fixnum)

;; Restore to normal value after startup (e.g. 50MB)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 50 1024 1024))))

;; Performance:
(setq load-prefer-newer t
      inhibit-compacting-font-caches t)

;; turn on native compilation
(setq native-comp-jit-compilation t
      package-native-compile t)

;; Set the maximum output size for reading process output, allowing for larger data transfers.
(setq read-process-output-max (* 1024 1024 4))

;; Disable the startup message when Emacs launches.
(setq inhibit-startup-message t)

(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

;; ;; set default frame (or in OS lingo window) size
;; (add-to-list 'default-frame-alist '(width . 100))
;; (add-to-list 'default-frame-alist '(height . 40))

;; I don't know if it's gonna slow startup time but I really hate the
;; white blinking when startup (transition emac's white theme to configured
;; theme)
;; (load-theme 'modus-vivendi-tinted :no-confirm)

;; set font
;; (set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 100)

;; we will use elpaca on init.el
(setq package-enable-at-startup nil)

(message "early init is running")
;;; early-init.el ends here
