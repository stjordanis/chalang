; let is a built-in tool for lisp. for an example, look at let.scm
(macro let (pairs code)
       (cond
	(((= pairs ()) code)
	 (true (let (let2 (car pairs) (cdr pairs))
		 (let2 (car pairs) code))))))
(macro let2 (pair code)
       (let3 (car pair)
	     (car (cdr pair))
	     code))
(macro let3 (ID Value Code)
       (cond (((= () Code) ())
	      ((= ID (car Code))
	       '(cons Value ,(let3 ID Value (cdr Code))))
	      ((is_list (car Code))
	       '(cons ,(let3 ID Value (car Code))
		     ,(let3 ID Value (cdr Code))))
	      (true '(cons ,(car Code)
			  ,(let3 ID Value (cdr Code)))))))
