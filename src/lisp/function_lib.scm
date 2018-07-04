% this is a library for making functions at run-time.

% uses the r-stack to store the memory locations
% for the input of the functions we are currently
% processing. So the r-stack is used as a function
% call stack, one additional thing is pushed every
% time a function is called, and one thing is
% removed every time a function returns.

(>r 1)

(macro _function_v (X)
       % look up a pointer to the xth variable being stored for the current function being processed
       (cond (((= X 0) '(r@))
	      (true
	       '(+ r@ X)))))
(macro _function_vars (V N)
       % store the inputs of the function into variables,
       % the top of the r stack points to these variables.
       (cond (((= V ()) ())
	      ((= 0 N) '(nop r@ !
			  ,(_function_vars (cdr V) 1)))
	      (true '(nop ,(_function_v N) !
			  ,(_function_vars (cdr V) (+ N 1)))))))
(macro _function_get* (Var Code N)
       %Replace each Var in Code with the input to the function
       (cond (((= Code ()) ())
	      ((is_list (car Code))
	       (cons (_function_get* Var (car Code) N)
		      (_function_get* Var (cdr Code) N)))
	      ((= (car Code) Var)
	       (cons '(@ (_function_v N))
		     (_function_get* Var (cdr Code) N)))
	      (true (cons
		      (car Code)
		      (_function_get* Var (cdr Code) N))))))
(macro _function_gets (Vars Code N)
       % repeatedly use _function_get* to replace
       % each Var in Code with the inputs to the function,
       % which are stored in the vm as variables.
       (cond (((= Vars ()) Code)
	      (true (_function_gets
		     (cdr Vars)
		     (_function_get* (car Vars) Code N)
		     ,(+ N 1))))))
(macro _call_stack* (Many Code)
       % functions need to be able to call other functions.
       % if function A calls function B, then when our
       % program returns from function B, we need to
       % remember the inputs for all the variables in
       % function A, so we can process the rest of
       % function A correctly.
       (cond
	(((= Code ()) ())
	 ((is_list (car Code))
	  (cons (_call_stack* Many (car Code))
		(_call_stack* Many (cdr Code))))
	 ((= (car Code) call)
	  (cond (((= Many 0) Code)
		 (true 
		  '(nop ,(cdr Code) (+ r@ Many) >r
			call
			r> drop)))))
	 (true 
	  (cons (car Code)
		(_call_stack* Many (cdr Code)))))))
(macro _length (X)
       %returns the length of list X at compile-time
       (cond (((= X ()) 0)
	      (true (+ (_length (cdr X)) 1)))))
(macro lambda (Vars Code)
       '(nop 
	     start_fun
	     ,(_function_vars Vars 0)
	     %,(nop print)
	     (_call_stack* ,(_length Vars)
			  ,(_function_gets (reverse Vars)
					   (Code)
					   0))
	     end_fun))
%(_length (1 1 5 1 1 1 1))
%(tree '(tree '(+ 1 2)))
%(Fdepth) % 1
%(_function_v 3) % 4

%4 3 (_function_vars (a b) 0)
%(_function_get* a '(+ a 1) 0) %900 @ 5 + @
%(_function_get* a (_function_get* b (a b) 0) 1)
%(_function_gets (a b) '(+ a (+ b 2)) 0)
%(_call_stack* 3 '(+ (+ a b) c))
%(function_codes_1 3 '(+ (+ a b) c))

%3 (_function_vars (x) 0)
%5 (nop start_fun (_function_vars (x) 0) (function_codes_1 1 '(_function_gets (x) '(+ x 5) 0)) end_fun)

%(macro apply (F V)
%       (cons call (reverse (cons F (reverse V)))))
(macro execute (F V)
       (cons call (reverse (cons F (reverse V)))))


