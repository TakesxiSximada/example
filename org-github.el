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
  (if-let ((a (car (org-property-values "GITHUB_ISSUE"))))
      (async-shell-command (format "gh issue view %s -c" a))))


(defun org-github-close-issue ()
  (interactive)
  (if-let ((url (car (org-property-values "GITHUB_ISSUE"))))
      (async-shell-command (format "gh issue close %s" url))))


(defun org-github-reopen-issue ()
  (interactive)
  (if-let ((url (car (org-property-values "GITHUB_ISSUE"))))
      (async-shell-command (format "gh issue reopen %s" url))))

;; (process-send-eof
;; (async-shell-command
;; (get-text
;;  (org-get-heading t t)
;;  foooo a
;;  g
;; (org-heading-components )
