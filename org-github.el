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


(defun org-github-edit-issue ()
  "Github Issueの更新を開始する"
  (interactive)
  (org-mark-subtree)
  (edit-indirect-region (region-beginning) (region-end) t))



(defun org-github-edit-issue-save ()
  "更新したGithub Issueを保存する"
  (interactive)
  (if-let ((url (org-entry-get nil "GITHUB_ISSUE"))
           (title (org-get-heading nil t)))
      (save-excursion
	(org-gfm-export-as-markdown)

	(let ((proc (make-process :name "*Org Github*"
                                  :buffer "*Org Github*"
                                  :command `("gh" "issue" "edit" ,url "--title" ,title "--body-file" "-" ))))
          (process-send-region proc (point-min) (point-max))
          (process-send-eof proc)
          (process-send-eof proc)))
    (edit-indirect-commit)))

(defun org-github-yank-url ()
  "そのorgにひもづくGithub URLをリングバッファにコピーする"
  (interactive)
  (if-let ((url (org-entry-get nil "GITHUB_ISSUE")))
      (kill-new url)))


(defun org-github-prepare-create-issue ()
  "旧関数、issue作成用のbashスクリプトを出力する"
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
