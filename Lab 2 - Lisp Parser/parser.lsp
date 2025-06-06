;;=====================================================================
;; Aron Cullberg    -   aroncull100                                   
;; Viktor Hajto     -   vikthajt100                                   
;;=====================================================================

;;=====================================================================
;; LISP READER & LEXER - new version 160514
;;=====================================================================

;;=====================================================================
;; Help functions
;;=====================================================================
;; ctos         convert a character to a string
;; str_con      concatenate 2 strings str, c
;; whitespace   is c whitespace?
;;=====================================================================

(defun ctos (c)        (make-string 1 :initial-element c))
(defun str-con (str c) (concatenate 'string str (ctos c)))
(defun whitespace (c)  (member c '(#\Space #\Tab #\Newline #\Return)))

;;=====================================================================
;; get-wspace   remove whitespace
;;=====================================================================

(defun get-wspace (ip)
   (setf c (read-char ip nil 'EOF))
   (cond
           ((whitespace c)  (get-wspace ip))
           (t                             c)
   )
)

;;=====================================================================
;; Read an Identifier         Compare this with C's do-while construct
;;=====================================================================

(defun get-name (ip lexeme c)
   (setf lexeme (str-con lexeme c))
   (setf c      (read-char ip nil 'EOF))
   (cond
                ((alphanumericp c)  (get-name ip lexeme c))
                (t                  (list        c lexeme))
   )
)

;;=====================================================================
;; Read a Number              Compare this with C's do-while construct
;;=====================================================================

(defun get-number (ip lexeme c)
   (setf lexeme (str-con lexeme c))
   (setf c      (read-char ip nil 'EOF))
   (cond
         ((not (null (digit-char-p c)))  (get-number ip lexeme c))
         (t                              (list          c lexeme))
   )
  )

;;=====================================================================
;; Read a single character or ":="
;;=====================================================================

(defun get-symbol (ip lexeme c)
   (setf lexeme (str-con lexeme c))
   (setf c1 c)
   (setf c (read-char ip nil 'EOF))
   (cond
         ((and (char= c1 #\:) (char= c #\=))  (get-symbol ip lexeme c))
         (t                                   (list          c lexeme))
   )
)

;;=====================================================================
;; Read a Lexeme                       lexeme is an "accumulator"
;;                                     Compare this with the C version
;;=====================================================================

(defun get-lex (state)
   (setf lexeme "")
   (setf ip (pstate-stream   state))
   (setf c  (pstate-nextchar state))
   (if (whitespace c) (setf c (get-wspace ip)))
   (cond
         ((eq c 'EOF)                     (list 'EOF ""))
         ((alpha-char-p c)                (get-name   ip lexeme c))
         ((not (null (digit-char-p c)))   (get-number ip lexeme c))
         (t                               (get-symbol ip lexeme c))
   )
)

;;=====================================================================
; map-lexeme(lexeme) returns a list: (token, lexeme)
;;=====================================================================

(defun map-lexeme (lexeme)
(format t "Symbol: ~S ~%" lexeme)
   (list (cond
         ((string=   lexeme "program")  'PROGRAM)
         ((string=   lexeme "var")      'VAR)
         ((string=   lexeme "(")        'LP)
         ((string=   lexeme ")")        'RP)
         ((string=   lexeme ",")        'COMMA)
         ((string=   lexeme ";")        'SCOLON)
         ((string=   lexeme ":")        'COLON)
         ((string=   lexeme "input")    'INPUT)
         ((string=   lexeme "output")   'OUTPUT)
         ((string=   lexeme "integer")  'INTEGER)
         ((string=   lexeme "real")     'REAL)
         ((string=   lexeme "boolean")  'BOOLEAN)
         ((string=   lexeme "begin")    'BEGIN)
         ((string=   lexeme "end")      'END)
         ((string=   lexeme ":=")       'ASSIGN)
         ((string=   lexeme ".")        'FSTOP)
         ((string=   lexeme "+")        'PLUS)
         ((string=   lexeme "*")        'MULTIPLIKATION)

         ((string=   lexeme "")	       'EOF)
         ((is-id     lexeme)            'ID)
         ((is-number lexeme)            'NUM)
         (t                             'UNKNOWN)
         )
    lexeme)
)

;;=====================================================================
; ID is [A-Z,a-z][A-Z,a-z,0-9]*          number is [0-9][0-9]*
;;=====================================================================

(defun is-id (str)
   (and (alpha-char-p (char str 0)) (every #'alphanumericp str))
)

(defun is-number (str)
   (every #'digit-char-p str)
)

;;=====================================================================
; THIS IS THE PARSER PART
;;=====================================================================

;;=====================================================================
; Create a stucture - parse state descriptor
;;=====================================================================
; lookahead is the list (token, lexeme)
; stream    is the input filestream
; nextchar  is the char following the last lexeme read
; status    is the parse status (OK, NOTOK)
; symtab    is the symbol table
;;=====================================================================

(defstruct pstate
    (lookahead)
    (stream)
    (nextchar)
    (status)
    (symtab)
)

;;=====================================================================
; Constructor for the structure pstate - initialise
; stream to the input file stream (ip)
;;=====================================================================

(defun create-parser-state (ip)
   (make-pstate
      :stream        ip
      :lookahead     ()
      :nextchar      #\Space
      :status        'OK
      :symtab        ()
    )
)

;;=====================================================================
; SYMBOL TABLE MANIPULATION
;;=====================================================================

;;=====================================================================
; token  - returns the token  from (token lexeme)(reader)
; lexeme - returns the lexeme from (token lexeme)(reader)
;;=====================================================================

(defun token  (state) ;; *** TO BE DONE ***
   (first (pstate-lookahead state))
)
(defun lexeme (state) ;; *** TO BE DONE ***
   (second (pstate-lookahead state))
)

;;=====================================================================
; symbol table manipulation: add + lookup + display
;;=====================================================================

(defun symtab-add (state id)
   (if (symtab-member state id)
      (semerr1 state)                                                               ; IF TRUE
      (setf (pstate-symtab state) (append (pstate-symtab state) (cons id nil)))    ; IF NOT TRUE A.K.A FALSE (ELSE)
   )
)

(defun symtab-member (state id)
   (member id (pstate-symtab state):test #'string-equal)
)

(defun symtab-display (state)
   (format t "------------------------------------------------------~%")
   (format t "Symbol Table is: ~S ~%" (pstate-symtab state))
   (format t "------------------------------------------------------~%")
)

;;=====================================================================
; Error functions: Syntax & Semantic
;;=====================================================================

(defun synerr1 (state symbol)
    (format t "*** Syntax error:   Expected ~8S found ~8S ~%"
           symbol (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

(defun synerr2 (state)
    (format t "*** Syntax error:   Expected TYPE     found ~S ~%"
           (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

(defun synerr3 (state)
    (format t "*** Syntax error:   Expected OPERAND  found ~S ~%"
           (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

(defun semerr1 (state)
    (format t "*** Semantic error: ~S already declared.~%"
                (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

(defun semerr2 (state)
    (format t "*** Semantic error: ~S not declared.~%"
          (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

; THIS IS OUR BECAUSE OTHERWISE WE CAN'T MATCH THE EXPECTED OUTPUT
(defun semerr3 (state)
    (format t "*** Semantic error: found ~8S expected EOF.~%"
          (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

;;=====================================================================
; The return value from get-token is always a list. (token lexeme)
;;=====================================================================

(defun get-token (state)
  (let    ((result (get-lex state)))
    (setf (pstate-nextchar  state) (first result))
    (setf (pstate-lookahead state) (map-lexeme (second result)))
  )
 )

;;=====================================================================
; match compares lookahead with symbol (the expected token)
; if symbol == lookahead token ==> get next token else Syntax error
;;=====================================================================

(defun match (state symbol)
   (if (eq symbol (token state))
       (get-token  state)
       (synerr1    state symbol)
       )
)

;;=====================================================================
; THE GRAMMAR RULES
;;=====================================================================

;;=====================================================================
; <stat-part>     --> begin <stat-list> end .
; <stat-list>     --> <stat> | <stat> ; <stat-list>
; <stat>          --> <assign-stat>
; <assign-stat>   --> id := <expr>
; <expr>          --> <term>     | <term> + <expr>
; <term>          --> <factor>   | <factor> * <term>
; <factor>        --> ( <expr> ) | <operand>
; <operand>       --> id | number
;;=====================================================================

;; *** TO BE DONE ***
(defun stat-part (state)
   (match state 'BEGIN)
   (stat-list state)
   (match state 'END)
   (match state 'FSTOP)
)

(defun stat-list (state)
   (stat state)
   (if (eq (token state) 'SCOLON) 
      (progn
         (match state 'SCOLON)
         (stat-list state)
      )
   )
)

(defun stat (state)
   (assign-stat state)
)

(defun assign-stat (state)
   (if (eq (token state) 'ID) 
      (if (symtab-member state (lexeme state))
         ()
         (semerr2 state)
      )
   )
   (match state 'ID)
   (match state 'ASSIGN)
   (expr state)
)

(defun expr (state)
   (term state)
   (if (eq(token state) 'PLUS)
      (progn
         (match state 'PLUS)
         (expr state)
      )
   )
)

(defun term (state)
   (factor state)
   (if (eq(token state) 'MULTIPLIKATION)
      (progn
         (match state 'MULTIPLIKATION)
         (term state)
      )
   )

)

(defun factor (state)
   (if (eq(token state) 'LP)
      (progn
         (match state 'LP)
         (expr state)
         (match state 'RP)
      )
      (operand state)
   )
)

(defun operand (state)
   (cond
      ((eq(token state) 'NUM) (match state 'NUM))
      ((eq(token state) 'ID)  (if (symtab-member state (lexeme state))
                                 (match state 'ID)                            ; OP IS DECLARED
                                 (progn (semerr2 state) (match state 'ID))    ; OP IS NOT DECLARED
                              )
      )
      (t                      (synerr3 state)   )
   )
)

;;=====================================================================
; <var-part>     --> var <var-dec-list>
; <var-dec-list> --> <var-dec> | <var-dec><var-dec-list>
; <var-dec>      --> <id-list> : <type> ;
; <id-list>      --> id | id , <id-list>
; <type>         --> integer | real | boolean
;;=====================================================================

;; *** TO BE DONE ***

(defun var-part (state)
   (match state 'VAR)
   (var-dec-list state)
)

(defun var-dec-list (state)
   (var-dec state)
   (if (eq (token state) 'ID) (var-dec-list state))
)

(defun var-dec (state)
   (id-list state)
   (match state 'COLON)
   (typedec state)
   (match state 'SCOLON)
)

(defun id-list (state)
   (if (eq(token state) 'ID) (symtab-add state (lexeme state)))
 (match state 'ID)
 (if (eq(token state) 'COMMA) (progn (match state 'COMMA) (id-list state)) )
)

(defun typedec (state)
   (cond
      ((eq(token state) 'INTEGER)   (match state 'INTEGER))
      ((eq(token state) 'REAL)      (match state 'REAL)) 
      ((eq(token state) 'BOOLEAN)   (match state 'BOOLEAN))
      (t                            (synerr2 state))
   )
)

;;=====================================================================
; <program-header>
;;=====================================================================

;; *** TO BE DONE ***
(defun program-header (state)
   (match state 'program)
   (match state 'id)
   (match state 'LP)
   (match state 'INPUT)
   (match state 'COMMA)
   (match state 'OUTPUT)
   (match state 'RP)
   (match state 'SCOLON)
)

;;=====================================================================
; <program> --> <program-header><var-part><stat-part>
;;=====================================================================
(defun program (state)
   (program-header state)
   (var-part       state)
   (stat-part      state)
   
   (eat state)


   (symtab-display state)
)

(defun eat (state)

   (if (not (eq (token state) 'EOF))
      (progn
         (semerr3 state)
         (get-token state)
         (eat state)
      )
      
   )
)

;;=====================================================================
; THE PARSER - parse a file
;;=====================================================================

;;=====================================================================
; Test parser for file name input
;;=====================================================================

(defun parse (filename)
   (format t "~%------------------------------------------------------")
   (format t "~%--- Parsing program: ~S " filename)
   (format t "~%------------------------------------------------------~%")
   (with-open-file (ip (open filename) :direction :input)
      (setf state (create-parser-state ip))
      (setf (pstate-nextchar state) (read-char ip nil 'EOF))
      (get-token state)
      (program   state)
      )
   (if (eq (pstate-status state) 'OK)
      (format t "Parse Successful. ~%")
      (format t "Parse Fail. ~%")
      )
   (format t "------------------------------------------------------~%")
)

;;=====================================================================
; THE PARSER - parse all the test files
;;=====================================================================

(defun parse-all ()
   (mapcar
      (lambda (p)
         (parse(concatenate 'string "testfiles/" (file-namestring p)))
      )
      (append
         (directory "testfiles/test?.pas")
         (directory "testfiles/testok?.pas")
         (directory "testfiles/fun?.pas")
         (directory "testfiles/sem?.pas")
      )
   )
)

;;=====================================================================
; THE PARSER - test all files
;;=====================================================================

(format t "~S~%" (parse-all))


;;=====================================================================
; THE PARSER - test a single file
;;=====================================================================

; (parse "testfiles/testa.pas")

;;=====================================================================
; THE PARSER - end of code
;;=====================================================================
