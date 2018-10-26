;;; config/private/+ui.el -*- lexical-binding: t; -*-

(load! "+bindings")
(load! "+ui")
(load! "+org")

(when IS-WINDOWS
  (load! "+path"))

;; remove doom advice, I don't need deal with comments when newline
(advice-remove #'newline-and-indent #'doom*newline-and-indent)

(after! evil
  (setq evil-want-integration t))

;; Reconfigure packages
(after! evil-escape
  (setq evil-escape-key-sequence "jk"))

(after! projectile
  (setq projectile-require-project-root t))

(after! company
  (setq company-minimum-prefix-length 1
        company-idle-delay 0
        company-tooltip-limit 10
        company-show-numbers t
        company-global-modes '(not comint-mode erc-mode message-mode help-mode gud-mode)
        )
  (map! :map company-active-map
        "M-g" #'company-abort
        "M-d" #'company-next-page
        "M-u" #'company-previous-page))

(def-package! auto-save
  :load-path +my-ext-dir
  :init
  ;; 自动保存计时器
  :config
  (setq +my-auto-save-timer (auto-save-enable))
  (setq auto-save-slient t))

(def-package! visual-regexp
  :commands (vr/query-replace vr/replace)
  )

(after! emacs-snippets
  (add-to-list 'yas-snippet-dirs +my-yas-snipper-dir))


(def-package! company-english-helper
  :commands (toggle-company-english-helper))

(def-package! company-posframe
  :if (display-graphic-p)
  :after company
  :hook (company-mode . company-posframe-mode))


(def-package! scroll-other-window
  :load-path +my-ext-dir
  :config
  (sow-mode 1)
  (map!
   :gnvime "<M-up>"    #'sow-scroll-other-window-down
   :gnvime "<M-down>"  #'sow-scroll-other-window))


(def-package! openwith
  :load-path +my-ext-dir
  :config
  (setq openwith-associations
        '(
          ("\\.pdf\\'" "okular" (file))
          ("\\.docx?\\'" "wps" (file))
          ("\\.pptx?\\'" "wpp" (file))
          ("\\.xlsx?\\'" "et" (file))))
  (add-hook! :append 'emacs-startup-hook #'openwith-mode))

(def-package! isolate
  :config
  (add-to-list 'isolate-pair-list
               '(
                 (from . "os-\\(.*\\)=")
                 (to-left . (lambda(from)
                              (format "#+BEGIN_SRC %s\n" (match-string 1 from))))
                 (to-right . "\n#+END_SRC\n")
                 (condition . (lambda (_) (equal major-mode 'org-mode)))
                 )))

(set-popup-rules!
  '(("^\\*helpful" :size 0.6)
    ("^\\*info\\*$" :size 0.6)
    ("^\\*.*Octave\\*$" :size 0.5 :side right)
    ("^\\*Python*\\*$" :size 0.5 :side right)
    ("^\\*doom \\(?:term\\|eshell\\)" :size 0.5 :side right)))


(set-lookup-handlers! 'emacs-lisp-mode :documentation #'helpful-at-point)

(set-company-backend! '(yaml-mode cmake-mode) 'company-dabbrev)

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

(def-package! awesome-tray
  :disabled t
  :config
  (awesome-tray-mode +1))

(after! tex
  (add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex --synctex=1%(mode)%' %t" TeX-run-TeX nil t))
  (setq-hook! LaTeX-mode TeX-command-default "XeLaTex")
  (setq TeX-save-query nil))

(def-package! pyim
  :disabled t
  :config
  (setq pyim-dcache-directory doom-etc-dir)
  (setq default-input-method "pyim")
  ;; 全拼
  (setq pyim-default-scheme 'quanpin)
  ;; 设置 pyim 探针设置，这是 pyim 高级功能设置，可以实现 *无痛* 中英文切换 :-)
  ;; 我自己使用的中英文动态切换规则是：
  ;; 1. 光标只有在注释里面时，才可以输入中文。
  ;; 2. 光标前是汉字字符时，才能输入中文。
  ;; 3. 使用 M-j 快捷键，强制将光标前的拼音字符串转换为中文。
  (setq-default pyim-english-input-switch-functions
                '(pyim-probe-dynamic-english
                  pyim-probe-isearch-mode
                  pyim-probe-program-mode
                  pyim-probe-org-structure-template))

  (setq-default pyim-punctuation-half-width-functions
                '(pyim-probe-punctuation-line-beginning
                  pyim-probe-punctuation-after-punctuation))
  ;; 开启拼音搜索功能
  ;; (pyim-isearch-mode 1)
  (setq pyim-page-tooltip 'posframe)
  
  (map!
   :i "M-j" #'pyim-convert-code-at-point
   :i "C-;" #'pyim-delete-word-from-personal-buffer
   :i "M-f" #'pyim-forward-word
   :i "M-b" #'pyim-backward-word
   )
  )
