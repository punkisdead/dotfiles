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

(setq doom-font (font-spec :family "JetBrains Mono" :size 15)
      doom-big-font (font-spec :family "MesloLGS NF" :size 24))

(setq doom-theme 'doom-one)

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

;;(require 'eglot)

;; This is optional. It automatically runs `M-x eglot` for you whenever you are in `elixir-mode`:
;;(add-hook 'elixir-mode-hook 'eglot-ensure)

;; Be sure to edit the path appropriately; use the `.bat` script instead for Windows:
;;(add-to-list 'eglot-server-programs '(elixir-mode "~/.config/emacs/site-lisp/elixir-ls-v0.28.0/language_server.sh"))

(after! lsp-mode
  (setq lsp-elixir-server-command '("~/.config/emacs/site-lisp/elixir-ls-v0.28.0/language_server.sh")))

;; Increase the file watch threshold to prevent warnings in large projects
(after! lsp-mode
  (setq lsp-file-watch-threshold 5000)) ;; Adjust this number based on your needs

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
