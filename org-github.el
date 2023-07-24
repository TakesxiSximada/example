(defun org-github-open-issue (title)
  (interactive "MIssue Title: ")
  (unless (eq major-mode 'org-mode)
    (error "org-github経由でGithub Issueを作成するにはorg-modeである事が必要です。"))

  (unless (yes-or-no-p (format "「%s」 Ok?" title))
    (error "Github Issueの作成を中止します。"))

  (org-insert-heading)
  (insert title)

  (make-process :name "*Org Github*"
		:buffer "*Org Github*"
		:command `("gh" "issue" "create" "--body" "writing..." "--title" ,title)
		:filter (lambda (process output)
			  (when (string-prefix-p "https://github.com" output)
			    (org-set-property "GITHUB_ISSUE" output)))))
(defun org-github-prepare-create-issue ()
  (interactive)

  (org-narrow-to-subtree)

  (let ((temp-file (make-temp-file
		    (expand-file-name "./.tmp-org-github-") nil ".sh" t))
	(org-github-current-title (org-get-heading nil t)))
    (let ((gfm-buf (org-gfm-export-as-markdown)))
      (with-temp-file temp-file
	(progn
	  (insert (format "exec gh issue create --title '%s' --body-file - << EOF\n" org-github-current-title))
	  (insert (with-current-buffer gfm-buf (buffer-string)))
	  (insert "\nEOF\n"))))
    temp-file))

;; (defun org-github-create-issue ()
;;   (interactive)
;;   (if-let ((issue-url (org-entry-get nil "GITHUB_ISSUE")))
;;       (throw 'org-github-error-already-exist-issue "The issue already exists"))

;;   (let ((org-github-current-title (org-get-heading nil t))
;; 	(cmd (format "gh issue create --title '%s' --body-file -"
;; 		     org-github-current-title)))
;;     (when (yes-or-no-p "OK?")
;;       (print "OKOHIOGREHOI"))))




;;   (save-excursion

;;     (save-excursion
;;       (org-gfm-export-as-markdown)  ;; org-modeをmarkdownに変換、バッファも切り替わる
;;       (let ((win (async-shell-command cmd))
;; 	    (proc (get-buffer-process (window-buffer win))))
;; 	(process-send-region proc (point-min) (point-max))
;; 	(process-send-eof proc)))))






;;       (process-send-region
;;        (get-buffer-process
;; 	(async-shell-command cmd)

;;       (let* ((win (async-shell-command cmd)
;;     (gh-window (async-shell-command cmd))
;;           (gh-process (get-buffer-process (window-buffer gh-window)))
;; 	  (process-send-region gh-process (point-min) (point-max))




(defun org-github-fetch-issue-list ()
  (interactive)
  (async-shell-command "gh issue list --json number,title"))

(defun org-github-view-issue ()
  (interactive)
  (if-let ((url (org-entry-get nil "GITHUB_ISSUE")))
      (async-shell-command (format "gh issue view %s -c" url))))


(defun org-github-close-issue ()
  (interactive)
  (if-let ((url (org-entry-get nil "GITHUB_ISSUE")))
      (async-shell-command (format "gh issue close %s" url))))


(defun org-github-reopen-issue ()
  (interactive)
  (if-let ((url (org-entry-get nil "GITHUB_ISSUE")))
      (async-shell-command (format "gh issue reopen %s" url))))

;; (process-send-eof
;; (async-shell-command
;; (get-text
;;  (org-get-heading t t)
;;  foooo a
;;  g
;; (org-heading-components )
