
% this is a library for making functions at run-time.


% (macro Fname () 900) % global variable
% (macro Fdepth () '(@ ,Fname))
% (macro Fdepth () '(r@)) %
% (! 1 (Fname))
(>r 1) %
(macro function_v (X)
       (cond (((= X 0) '(r@))
	      (true
	       '(+ r@ X)))))
(macro function_vars (V N)
       (cond (((= V ()) ())
	      ((= N 0) '(nop r@ !
			  ,(function_vars (cdr V) 1)))
	      (true '(nop ,(function_v N) !
			  ,(function_vars (cdr V) (+ N 1)))))))
(macro function_get (Var Code N)
       %We need to replace each Var in Code with (@ (function_v N)) where Var is the Nth variable in Vars.
       (cond (((= Code ()) ())
	      ((is_list (car Code))
	       (cons (function_get Var (car Code) N)
		      (function_get Var (cdr Code) N)))
	      ((= (car Code) Var)
	       (cons (@ (function_v N))
		     (function_get Var (cdr Code) N)))
	      (true (cons
		      (car Code)
		      (function_get Var (cdr Code) N))))))
(macro function_gets (Vars Code N) 
       (cond (((= Vars ()) Code)
	      ((= N 0) (function_gets
			(cdr Vars)
			(function_get (car Vars) Code 0)
			1))
	      (true (function_gets
		     (cdr Vars)
		     (function_get (car Vars) Code N)
		     (+ N 1))))))
(macro function_codes_cond (Many Code)
       (cond
	(((= Code ()) ())
	 (true (cons (cons (function_codes2
			    Many
			    (car (car Code)))
			   (cons (function_codes_1
				  Many
				  (car (cdr (car Code))))
				 nil))
		     (function_codes_cond Many
					  (cdr Code)))))))
(macro function_codes_2 (Many Code)
       (cond
	(((= Code ()) ())
	 ((is_list (car Code))
	  (cons (function_codes_2 Many (car Code))
		(function_codes_2 Many (cdr Code))))
	 ((= (car Code) call)
	  (cond (((= Many 0) 
		  '(nop ,(cdr Code) 
			call))
		 (true 
		  '(nop ,(cdr Code) (+ r@ Many) >r
			call
			r> drop)))))
	 (true (cons (car Code)
		     (function_codes_2 Many (cdr Code)))))))
(macro function_codes_1 (Many Code)
       (cond
	(((= Code ()) ())
	 ((= (car Code) cond)
	  (function_codes_cond Many (cdr Code)))
	 (true (cons (car Code)
		     (function_codes_2 Many (cdr Code)))))))
(macro length (X)
       (cond (((= X ()) (- (+ 0 78) 78))
	      (true (+ (length (cdr X)) 1 nop)))))
(macro lambda (Vars Code)
       '(nop 
	     start_fun
	     ,(function_vars Vars 0)
	     %,(nop print)
	     ,(function_codes_2 (length Vars)
		    (function_gets (reverse Vars) (Code) 0))
	     end_fun))
%(length (1 1 5))
%(tree '(tree '(+ 1 2)))
%(Fdepth) % 1
%(function_v 3) % 4

%4 3 (function_vars (a b) 0)
%(function_get a '(+ a 1) 0) %900 @ 5 + @
%(function_get a (function_get b (a b) 0) 1)
%(function_gets (a b) '(+ a (+ b 2)) 0)
%(function_codes_2 3 '(+ (+ a b) c))
%(function_codes_1 3 '(+ (+ a b) c))

%3 (function_vars (x) 0)
%(function_codes_1 1 '(function_gets (x) '(+ x 5) 0))
%5 (nop start_fun (function_vars (x) 0) (function_codes_1 1 '(function_gets (x) '(+ x 5) 0)) end_fun)

%(macro apply (F V)
%       (cons call (reverse (cons F (reverse V)))))
(macro execute (F V)
       (cons call (reverse (cons F (reverse V)))))


