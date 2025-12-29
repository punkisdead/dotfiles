;;; -*- lexical-binding: t; -*-

(setq user-full-name "Jeremy Anderson"
      user-mail-address "jeremy.d.anderson@gmail.com")



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

;; Configure eglot for Ruby with Solargraph
(after! eglot
  ;; Add Solargraph to eglot server programs
  (add-to-list 'eglot-server-programs
               '((ruby-mode ruby-ts-mode) . ("solargraph" "stdio")))

  ;; Alternative: Use ruby-lsp if preferred
  ;; (add-to-list 'eglot-server-programs
  ;;              '((ruby-mode ruby-ts-mode) . ("ruby-lsp")))
  )

;; Auto-start eglot for Ruby files
(add-hook 'ruby-mode-hook 'eglot-ensure)
(add-hook 'ruby-ts-mode-hook 'eglot-ensure)

;; Configure Solargraph-specific settings
(after! eglot
  (defun my/eglot-solargraph-settings ()
    "Configure Solargraph-specific settings."
    `(:solargraph (:diagnostics t
                   :autoformat t
                   :completion t
                   :hover t
                   :symbols t
                   :definitions t
                   :rename t
                   :references t
                   :folding t
                   :logLevel "warn")))

  ;; Apply settings when connecting to Solargraph
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (when (derived-mode-p 'ruby-mode 'ruby-ts-mode)
                (setq-local eglot-workspace-configuration
                            (my/eglot-solargraph-settings))))))

;; Keybindings for Ruby LSP functions
(map! :after eglot
      :map ruby-mode-map
      :localleader
      (:prefix ("l" . "lsp")
       :desc "Start LSP" "s" #'eglot
       :desc "Restart LSP" "r" #'eglot-reconnect
       :desc "Format buffer" "f" #'eglot-format-buffer
       :desc "Format region" "F" #'eglot-format
       :desc "Rename symbol" "R" #'eglot-rename
       :desc "Code actions" "a" #'eglot-code-actions
       :desc "Go to definition" "d" #'xref-find-definitions
       :desc "Find references" "r" #'xref-find-references))

;; Configure treesit for Ruby (Emacs 29+ built-in tree-sitter)
(when (and (fboundp 'treesit-available-p) (treesit-available-p))
  ;; Auto-install grammars if missing
  (setq treesit-language-source-alist
        '((ruby "https://github.com/tree-sitter/tree-sitter-ruby" "master" "src")))

  ;; Install grammar if not present
  (unless (treesit-language-available-p 'ruby)
    (treesit-install-language-grammar 'ruby))

  ;; Remap ruby-mode to ruby-ts-mode
  (add-to-list 'major-mode-remap-alist '(ruby-mode . ruby-ts-mode)))

;; For the older tree-sitter package (fallback)
(after! tree-sitter
  ;; Enable tree-sitter for Ruby mode
  (add-hook 'ruby-mode-hook #'tree-sitter-mode)
  (add-hook 'ruby-mode-hook #'tree-sitter-hl-mode)

  ;; Ensure grammar is installed
  (when (featurep 'tree-sitter-langs)
    (tree-sitter-require 'ruby)))

;; Enhanced Rails support with projectile-rails
(use-package! projectile-rails
  :after (projectile ruby-mode)
  :config
  (projectile-rails-global-mode)

  ;; Define keybindings for Rails commands
  (map! :map projectile-rails-mode-map
        :localleader
        (:prefix ("r" . "rails")
         :desc "Console" "c" #'projectile-rails-console
         :desc "Server" "s" #'projectile-rails-server
         :desc "Generate" "g" #'projectile-rails-generate
         :desc "Destroy" "d" #'projectile-rails-destroy
         :desc "Database console" "D" #'projectile-rails-dbconsole
         :desc "Extract partial" "x" #'projectile-rails-extract-region

         (:prefix ("g" . "goto")
          :desc "Model" "m" #'projectile-rails-find-model
          :desc "Controller" "c" #'projectile-rails-find-controller
          :desc "View" "v" #'projectile-rails-find-view
          :desc "Helper" "h" #'projectile-rails-find-helper
          :desc "Test" "t" #'projectile-rails-find-test
          :desc "Spec" "s" #'projectile-rails-find-spec
          :desc "Migration" "M" #'projectile-rails-find-migration
          :desc "Schema" "S" #'projectile-rails-goto-schema
          :desc "Routes" "R" #'projectile-rails-goto-routes
          :desc "Gemfile" "G" #'projectile-rails-goto-gemfile))))

;; Auto-enable projectile-rails in Rails projects
(add-hook 'projectile-mode-hook 'projectile-rails-on)

;; Ruby code style and formatting
(after! ruby-mode
  ;; Set Ruby indentation
  (setq ruby-indent-level 2)
  (setq ruby-indent-tabs-mode nil)

  ;; Enable electric mode for automatic insertion of end
  (add-hook 'ruby-mode-hook 'ruby-electric-mode)

  ;; Use rubocop for linting if available
  (add-hook 'ruby-mode-hook 'rubocop-mode))

;; Configure inf-ruby for REPL
(use-package! inf-ruby
  :after ruby-mode
  :config
  (add-hook 'ruby-mode-hook 'inf-ruby-minor-mode)
  (add-hook 'compilation-filter-hook 'inf-ruby-auto-enter)

  ;; Keybindings for REPL
  (map! :map ruby-mode-map
        :localleader
        (:prefix ("s" . "repl")
         :desc "Start REPL" "s" #'inf-ruby
         :desc "Send region" "r" #'ruby-send-region
         :desc "Send definition" "d" #'ruby-send-definition
         :desc "Send block" "b" #'ruby-send-block
         :desc "Send buffer" "B" #'ruby-send-buffer
         :desc "Switch to REPL" "z" #'ruby-switch-to-inf)))

;; RSpec mode for testing
(use-package! rspec-mode
  :after ruby-mode
  :config
  (add-hook 'ruby-mode-hook 'rspec-mode)

  ;; Keybindings for RSpec
  (map! :map rspec-mode-map
        :localleader
        (:prefix ("t" . "test")
         :desc "Run all specs" "a" #'rspec-verify-all
         :desc "Run spec file" "f" #'rspec-verify
         :desc "Run spec at point" "t" #'rspec-verify-single
         :desc "Rerun last spec" "r" #'rspec-rerun
         :desc "Toggle spec/implementation" "T" #'rspec-toggle-spec-and-target)))

;; Bundler integration
(use-package! bundler
  :after ruby-mode
  :config
  (map! :map ruby-mode-map
        :localleader
        (:prefix ("b" . "bundler")
         :desc "Bundle install" "i" #'bundle-install
         :desc "Bundle update" "u" #'bundle-update
         :desc "Bundle exec" "e" #'bundle-exec
         :desc "Bundle console" "c" #'bundle-console
         :desc "Bundle open" "o" #'bundle-open)))

;; Web-mode for ERB templates
(use-package! web-mode
  :mode "\\.erb\\'"
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-css-colorization t)
  (setq web-mode-enable-current-element-highlight t)

  ;; Enable eglot for ERB files with HTML language server
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "erb" (file-name-extension buffer-file-name))
                (eglot-ensure)))))

;; Emmet for HTML/ERB expansion
(use-package! emmet-mode
  :hook (web-mode ruby-mode)
  :config
  (setq emmet-expand-jsx-className? t)
  (map! :map emmet-mode-keymap
        :i "TAB" #'emmet-expand-line))

;; SQL mode enhancements for database.yml and migrations
(use-package! sql
  :config
  ;; Set default SQL product for Rails (PostgreSQL is common)
  (setq sql-product 'postgres)

  ;; Keybindings for SQL
  (map! :map sql-mode-map
        :localleader
        :desc "Connect to database" "c" #'sql-connect
        :desc "Send paragraph" "p" #'sql-send-paragraph
        :desc "Send region" "r" #'sql-send-region
        :desc "Send buffer" "b" #'sql-send-buffer))

;; YAML mode for database.yml and other config files
(use-package! yaml-mode
  :mode "\\.ya?ml\\'"
  :config
  (add-hook 'yaml-mode-hook
            (lambda ()
              (define-key yaml-mode-map "\C-m" 'newline-and-indent))))

;; Optimize for Rails projects
(after! projectile
  ;; Add Rails-specific project detection
  (add-to-list 'projectile-project-root-files "Gemfile")
  (add-to-list 'projectile-project-root-files "config.ru")

  ;; Ignore common Rails directories for better performance
  (add-to-list 'projectile-globally-ignored-directories "tmp")
  (add-to-list 'projectile-globally-ignored-directories "log")
  (add-to-list 'projectile-globally-ignored-directories "vendor")
  (add-to-list 'projectile-globally-ignored-directories "public/assets")
  (add-to-list 'projectile-globally-ignored-directories "public/packs")
  (add-to-list 'projectile-globally-ignored-directories "node_modules"))

;; Speed up file navigation in Rails projects
(after! counsel
  (add-to-list 'counsel-projectile-grep-ignored-directories "tmp")
  (add-to-list 'counsel-projectile-grep-ignored-directories "log")
  (add-to-list 'counsel-projectile-grep-ignored-directories "vendor"))

;; Ruby debugging with DAP mode (optional, requires debugger gem)
;; (use-package! dap-mode
;;   :after ruby-mode
;;   :config
;;   (require 'dap-ruby)
;;   (dap-ruby-setup))

;; Use pry for debugging (more common in Rails)
(use-package! inf-ruby
  :config
  ;; Prefer pry over irb when available
  (setq inf-ruby-default-implementation "pry")
  (setq inf-ruby-first-prompt-pattern "^\\[[0-9]+\\] pry\\((.*)\\)[>*\"'] *")
  (setq inf-ruby-prompt-pattern "^\\[[0-9]+\\] pry\\((.*)\\)[>*\"'] *"))

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

(after! copilot
  ;; Clear the warning list to suppress warnings
  (setq copilot-indent-warned-modes '())

  ;; Default fallback
  (setq-default copilot-indent-offset 2))

(after! copilot
  ;; Override the indentation detection function
  (defun copilot--infer-indentation-offset ()
    "Return the indentation offset for the current buffer."
    (or copilot-indent-offset
        (and (boundp 'tab-width) tab-width)
        2)))

(use-package! copilot-chat
  :defer t
  :config
  (setq copilot-chat-auth-hook #'copilot-chat-auth-from-environment)
  ;; Optionally set up keybindings
  (map! :leader
        (:prefix ("x" . "AI")
         :desc "Copilot Chat" "c" #'copilot-chat-run)))

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Configure git-gutter directly
;; (use-package! git-gutter
;;   :config
;;   ;; Enable git-gutter globally
;;   (global-git-gutter-mode +1)

;;   ;; Make sure it's enabled by default in text-mode and prog-mode
;;   (add-hook! (prog-mode text-mode) #'git-gutter-mode)

;;   ;; Update git-gutter when saving and switching windows
;;   (add-hook 'after-save-hook #'git-gutter:update-all-windows)
;;   (add-hook 'focus-in-hook #'git-gutter:update-all-windows)
;;   (add-hook 'window-configuration-change-hook #'git-gutter:update-all-windows))

;; ;; Configure git-gutter-fringe with custom bitmaps
;; (use-package! git-gutter-fringe
;;   :after git-gutter
;;   :config
;;   ;; Ensure proper fringe width
;;   (fringe-mode '(8 . 8))

;;   ;; Define custom fringe bitmaps for better visibility (VSCode style)
;;   (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
;;   (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
;;   (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom)

;;   ;; Set custom colors for the fringe indicators
;;   (custom-set-faces!
;;     '(git-gutter-fr:added ((t (:foreground "green"))))
;;     '(git-gutter-fr:modified ((t (:foreground "yellow"))))
;;     '(git-gutter-fr:deleted ((t (:foreground "red"))))))

;; (add-hook! 'doom-first-input-hook
;;   (global-git-gutter-mode +1))
