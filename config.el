;;; config/private/+ui.el -*- lexical-binding: t; -*-

(load! "+bindings")
(load! "+ui")
(load! "+org")

;; remove doom advice, I don't need deal with comments when newline
(advice-remove #'newline-and-indent #'doom*newline-indent-and-continue-comments)


;; Reconfigure packages
(after! evil-escape
  (setq evil-escape-key-sequence "jk"))

  
(after! projectile
  (setq compilation-read-command nil)  ; no prompt in projectile-compile-project
  (projectile-register-project-type 'cmake '("CMakeLists.txt")
                                    :configure "cmake %s"
                                    :compile "cmake --build Debug"
                                    :test "ctest")

  (setq projectile-require-project-root t)
  (setq projectile-project-root-files-top-down-recurring
        (append '("compile_commands.json")
                projectile-project-root-files-top-down-recurring)))

(after! company
  (setq company-minimum-prefix-length 1
        company-idle-delay 0
        company-tooltip-limit 10
        company-show-numbers t
        company-global-modes '(not comint-mode erc-mode message-mode help-mode gud-mode)
        ))


(after! yasnippet
  (add-to-list 'yas-snippet-dirs #'+my-private-snippets-dir nil #'eq))



(after! format
  (set-formatter!
    'clang-format
    '("clang-format"
      ("-assume-filename=%S" (or (buffer-file-name) ""))
      "-style=Google"))
  :modes
  '((c-mode ".c")
    (c++-mode ".cpp")
    (java-mode ".java")
    (objc-mode ".m")
    ))

(after! ws-butler
  (setq ws-butler-global-exempt-modes
        (append ws-butler-global-exempt-modes
                '(prog-mode org-mode))))


(after! tex
  (add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex --synctex=1%(mode)%' %t" TeX-run-TeX nil t))
  (setq-hook! LaTeX-mode TeX-command-default "XeLaTex")

  (setq TeX-save-query nil)

  (when (fboundp 'eaf-open)
    (add-to-list 'TeX-view-program-list '("eaf" TeX-eaf-sync-view))
    (add-to-list 'TeX-view-program-selection '(output-pdf "eaf"))))



(after! eshell
  (setq eshell-directory-name (expand-file-name "eshell" doom-etc-dir)))

(global-auto-revert-mode 0)

(after! lsp
  (setq lsp-auto-guess-root t))

(after! lsp-ui
  (add-hook! 'lsp-ui-mode-hook #'lsp-ui-doc-mode)
  (setq
   lsp-ui-doc-use-webkit nil
   lsp-ui-doc-max-height 20
   lsp-ui-doc-max-width 50
   lsp-ui-sideline-enable nil
   lsp-ui-peek-always-show t)
  (map!
   :map lsp-ui-peek-mode-map
   "h" #'lsp-ui-peek--select-prev-file
   "j" #'lsp-ui-peek--select-next
   "k" #'lsp-ui-peek--select-prev
   "l" #'lsp-ui-peek--select-next-file))

(after! ccls
  (setq ccls-initialization-options `(:cache (:directory ,(expand-file-name "~/Code/ccls_cache"))
                                             :compilationDatabaseDirectory "build"))

  (setq ccls-sem-highlight-method 'font-lock)
  (ccls-use-default-rainbow-sem-highlight)
  (evil-set-initial-state 'ccls-tree-mode 'emacs))


(use-package! visual-regexp
  :commands (vr/query-replace vr/replace))

(use-package! package-lint
  :commands (package-lint-current-buffer))

(use-package! auto-save
  :load-path +my-ext-dir
  :config
  (setq +my-auto-save-timer nil)
  (setq auto-save-slient t))


(use-package! company-english-helper
  :commands (toggle-company-english-helper))


(use-package! openwith
  :load-path +my-ext-dir
  :config
  (setq openwith-associations
        '(
          ("\\.pdf\\'" "okular" (file))
          ("\\.docx?\\'" "wps" (file))
          ("\\.pptx?\\'" "wpp" (file))
          ("\\.xlsx?\\'" "et" (file))))
  (add-hook! 'emacs-startup-hook :append #'openwith-mode))



(use-package! eaf
  :load-path "/home/xhcoding/Code/ELisp/emacs-application-framework/"
  :commands (eaf-open)
  :config
  (evil-set-initial-state 'eaf-mode 'emacs))

(after! pyim
  (setq pyim-page-tooltip 'posframe)

  (setq-default pyim-english-input-switch-functions
                '(
                  pyim-probe-dynamic-english
                  pyim-probe-isearch-mode
                  pyim-probe-program-mode
                  pyim-probe-org-structure-template))

  (setq-default pyim-punctuation-half-width-functions
                '(pyim-probe-punctuation-line-beginning
                  pyim-probe-punctuation-after-punctuation))

  (map! :gnvime
        "M-l" #'pyim-convert-string-at-point))

(after! geiser
  (setq-default geiser-default-implementation 'chez))

(use-package! keyfreq)

(use-package! evil-matchit)

(use-package! nsis-mode
  :mode ("\.[Nn][Ss][HhIi]\'". nsis-mode))

(use-package! groovy-mode
  :mode ("\.groovy\'" . groovy-mode))

;; server
(setq server-auth-dir (expand-file-name doom-etc-dir))
(setq server-name "emacs-server-file")
(server-start)

(when (eq system-type 'windows-nt)
  (setq locale-coding-system 'gb18030)  ;此句保证中文字体设置有效
  (setq w32-unicode-filenames 'nil)       ; 确保file-name-coding-system变量的设置不会无效
  (setq file-name-coding-system 'gb18030) ; 设置文件名的编码为gb18030
  )
