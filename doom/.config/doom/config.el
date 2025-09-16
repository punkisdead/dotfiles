;;; -*- lexical-binding: t; -*-

(setq user-full-name "Jeremy Anderson"
      user-mail-address "janderson@denim.com")



;;(after! web-mode
;;  (setq web-mode-code-indent-offset 2)
;;  (setq web-mode-css-indent-offset 2)
;;  (setq web-mode-markup-indent-offset 2))

;;(after! js2-mode
;;  (setq js-indent-level 2)
;;  (setq indent-tabs-mode nil))

(setq doom-font (font-spec :family "CaskaydiaMono Nerd Font" :size 15)
      doom-big-font (font-spec :family "CaskaydiaMono Nerd Font" :size 24))

;; Set Catppuccin flavor (options: 'latte, 'frappe, 'macchiato, 'mocha)
(setq catppuccin-flavor 'mocha) ;; Dark theme with high contrast

;; Set the theme to catppuccin
(setq doom-theme 'catppuccin)

(custom-set-faces
  '(ansi-color-blue ((t (:foreground "RoyalBlue1" :weight bold))))
  '(ansi-color-red ((t (:foreground "firebrick" :weight bold)))))

(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

(setq display-line-numbers-type t)

;;(add-to-list 'load-path "~/.config/emacs/site-lisp/asdf")
;;(require 'asdf)

;;(asdf-enable) ;; This ensures Emacs has the correct paths to asdf shims and bin

;; (after! lsp-mode
;;   (lsp-register-client
;;    (make-lsp-client :new-connection (lsp-stdio-connection
;;                                      (lambda ()
;;                                        (list "~/.asdf/shims/elixir"
;;                                              "~/.asdf/shims/elixir-ls")))
;;                     :major-modes '(elixir-mode)
;;                     :priority -1
;;                     :server-id 'elixir-ls)))




;; In ~/.doom.d/config.el
(use-package! exec-path-from-shell
  :config
  (when (or (memq window-system '(mac ns x))
            (daemonp))
    (exec-path-from-shell-initialize)
    ;; Explicitly copy these variables
    (exec-path-from-shell-copy-envs '("PATH" "MIX_PATH" "MIX_ARCHIVES" "HEX_HOME" "MIX_HOME"))))

;;(setq company-global-modes '(not inf-ruby-mode))

;; (load (expand-file-name "~/quicklisp/slime-helper.el"))
;; Replace "sbcl" with the path to your implementation
;; (setq inferior-lisp-program "sbcl")

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(add-hook 'projectile-mode-hook 'projectile-direnv-export-variables)

(after! direnv
  (setq direnv-always-show-summary t)
  ;; Optional: Set the timeout for direnv operations
  (setq direnv-non-file-modes '(dired-mode magit-mode))
)

(setq doom-themes-treemacs-theme "doom-colors")

;; Configure eglot for Elixir
(after! eglot
  ;; Add ElixirLS to eglot server programs
  (add-to-list 'eglot-server-programs
               '((elixir-mode elixir-ts-mode heex-mode) .
                 ("~/.elixir-ls/release/language_server.sh"))))

;; Optional: Configure eglot behavior
(after! eglot
  ;; Disable specific features if needed
  (setq eglot-autoshutdown t)  ; Shutdown server when last buffer is closed
  (setq eglot-confirm-server-initiated-edits nil)  ; Don't ask for confirmation
  (setq eglot-sync-connect-timeout 10)  ; Increase connection timeout
  (setq eglot-connect-timeout 10)
  (setq eglot-extend-to-xref t)  ; Use eglot for xref

  ;; Customize which events trigger synchronization
  (setq eglot-send-changes-idle-time 0.5))

;; Set up keybindings for eglot (Doom already provides many)
(map! :after eglot
      :map eglot-mode-map
      :leader
      :prefix ("c l" . "lsp")
      :desc "Start LSP"           "s" #'eglot
      :desc "Restart LSP"         "r" #'eglot-reconnect
      :desc "Shutdown LSP"        "q" #'eglot-shutdown
      :desc "Rename symbol"       "R" #'eglot-rename
      :desc "Format buffer"       "f" #'eglot-format-buffer
      :desc "Format region"       "F" #'eglot-format
      :desc "Show diagnostics"    "d" #'flymake-show-diagnostics-buffer
      :desc "Code actions"        "a" #'eglot-code-actions
      :desc "Organize imports"    "o" #'eglot-code-action-organize-imports)

;; Optional: Auto-start eglot for Elixir files
(add-hook 'elixir-mode-hook 'eglot-ensure)
(add-hook 'elixir-ts-mode-hook 'eglot-ensure)
(add-hook 'heex-mode-hook 'eglot-ensure)

;; Optional: Configure ElixirLS-specific settings
(after! eglot
  (defun my/eglot-elixir-ls-settings ()
    "Configure ElixirLS-specific settings."
    `(:elixirLS (:dialyzerEnabled :json-false
                 :fetchDeps t
                 :suggestSpecs t
                 :signatureAfterComplete t
                 :enableTestLenses t)))

  ;; Apply settings when connecting to ElixirLS
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (when (derived-mode-p 'elixir-mode 'elixir-ts-mode 'heex-mode)
                (setq-local eglot-workspace-configuration
                            (my/eglot-elixir-ls-settings))))))

;; If you use asdf or similar version managers
(after! eglot
  ;; Make sure PATH is set correctly for eglot
  (when (memq window-system '(mac ns x))
    (setenv "PATH" (concat (getenv "PATH") ":~/.elixir-ls/release"))
    (setq exec-path (append exec-path '("~/.elixir-ls/release")))))

;; Or if you need to set specific environment variables
(setenv "ERL_AFLAGS" "-kernel shell_history enabled")

;; Ignore common directories to improve performance
(after! eglot
  ;; Tell eglot to ignore certain directories
  (add-to-list 'project-vc-ignores "node_modules")
  (add-to-list 'project-vc-ignores "_build")
  (add-to-list 'project-vc-ignores "deps")
  (add-to-list 'project-vc-ignores ".elixir_ls"))

;; Optimize flymake for use with eglot
(after! flymake
  (setq flymake-no-changes-timeout 0.5)
  (setq flymake-start-syntax-check-on-newline t)
  (setq flymake-start-syntax-check-on-find-file t))

;; Optional: Use company for better completion experience
(after! company
  (setq company-idle-delay 0.2)
  (setq company-minimum-prefix-length 1))

;; Debug helpers for eglot
(defun my/eglot-show-workspace-configuration ()
  "Show current eglot workspace configuration."
  (interactive)
  (when (eglot-current-server)
    (message "%s" (json-encode (eglot--workspace-configuration-plist
                                (eglot-current-server))))))

;; Toggle eglot event logging for debugging
(defun my/toggle-eglot-events-buffer ()
  "Toggle the eglot events buffer for debugging."
  (interactive)
  (setq eglot-events-buffer-size (if (eq eglot-events-buffer-size 0)
                                     2000000
                                   0))
  (message "Eglot events buffer %s"
           (if (eq eglot-events-buffer-size 0) "disabled" "enabled")))

(map! :leader
      :prefix ("c l" . "lsp")
      :desc "Show workspace config" "w" #'my/eglot-show-workspace-configuration
      :desc "Toggle eglot events" "E" #'my/toggle-eglot-events-buffer)

(after! eglot
  ;; Increase timeout settings
  (setq eglot-connect-timeout 30)  ; Increase from 10 to 30 seconds
  (setq eglot-sync-connect 1)      ; Wait 1 second for synchronous connection
  (setq eglot-autoshutdown t)      ; Shutdown unused servers

  ;; Alternative: Set to nil for infinite timeout (not recommended)
  ;; (setq eglot-connect-timeout nil)
  )

;; accept completion from copilot and fallback to company
;; (use-package! copilot
;;   :hook (prog-mode . copilot-mode)
;;   :bind (:map copilot-completion-map
;;               ("<tab>" . 'copilot-accept-completion)
;;               ("TAB" . 'copilot-accept-completion)
;;               ("C-TAB" . 'copilot-accept-completion-by-word)
;;               ("C-<tab>" . 'copilot-accept-completion-by-word)))
;; 
;; (after! copilot
;;   ;; Clear the warning list to suppress warnings
;;   (setq copilot-indent-warned-modes '())
;; 
;;   ;; Default fallback
;;   (setq-default copilot-indent-offset 2))
;; 
;; (after! copilot
;;   ;; Override the indentation detection function
;;   (defun copilot--infer-indentation-offset ()
;;     "Return the indentation offset for the current buffer."
;;     (or copilot-indent-offset
;;         (and (boundp 'tab-width) tab-width)
;;         2)))
;; 
;; (use-package! copilot-chat
;;   :defer t
;;   :config
;;   (setq copilot-chat-auth-hook #'copilot-chat-auth-from-environment)
;;   ;; Optionally set up keybindings
;;   (map! :leader
;;         (:prefix ("x" . "AI")
;;          :desc "Copilot Chat" "c" #'copilot-chat-run)))
