(define gcf (A B)
  (cond (((= 0 B) A)
	 (true (recurse B (rem A B))))))
(gcf 36 24)
