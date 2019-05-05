exception InvalidReferenceInStack
exception InvalidIndexInList
exception NotFound
exception CannotCall

let rec nth_in_list l n = if (n>0) then (match n with
                          |  1 -> List.hd l
                          |  x -> nth_in_list (List.tl l) (n-1)
                          )
                            else raise InvalidReferenceInStack 

let rec first_n_elem l n = if (n<0) then raise InvalidIndexInList else match n with
                          0 -> []
                        | 1 -> [List.hd l]
                        | n -> (List.hd l) :: (first_n_elem (List.tl l) (n-1))

let last_n_elem l n = List.rev (first_n_elem (List.rev l) n)
         

type exptype = Tint | Tbool

type answer = NumVal of int | BoolVal of bool

type frameElem = FuncName of string | LocalVblsList of ((string * answer * exptype ) list) | RetAddr of int 
                 | StaticLink of int | ArgsList of ((string * answer * exptype) list)

type stack = frameElem list

type  exptree =
                V of string (* variables starting with a Capital letter, represented as alphanumeric strings with underscores (_) and apostrophes (') *)
                | Integer of int      (* Integer constant *)
                | Bool of bool     (* Boolean constant *);;

type commands = Assign of string * exptree | FuncCall of (string * (exptree list)) | Return 
                | CallableProc | CallingStack | StaticLinkChain | AccessibleVbls

exception InvalidFunctionName
exception MainFunctionHasNoParent

let parentName s = match s with
                "P" -> "main"
              | "Q" -> "main"
              | "R" -> "P"
              | "S" -> "P"
              | "T" -> "Q"
              | "U" -> "Q"
              | "V" -> "R"
              | "W" -> "T"
              | "main" -> raise MainFunctionHasNoParent
              | _   -> raise InvalidFunctionName

exception MainCannotBeCalledDirectly
let callable a b = if (b="main") then raise MainCannotBeCalledDirectly else match a with
                | "P" -> b="P" || b="R" || b="S" || b="Q"
                | "Q" -> b="Q" || b="T" || b="U" || b="P"
                | "R" -> b="R" || b="V" || b="P" || b="S" || b="Q"
                | "S" -> b="S" || b="P" || b="R" || b="Q"
                | "T" -> b="T" || b="W" || b="Q" || b="U" || b="P"
                | "U" -> b="U" || b="Q" || b="T" || b="P"
                | "V" -> b="V" || b="R" || b="P" || b="S" || b="Q"
                | "W" -> b="W" || b="T" || b="Q" || b="U" || b="P"
                | "main" -> b="P" || b="Q"
                | _   -> raise InvalidFunctionName


let rec find_in_list x l = match l with
                          [] -> raise NotFound
                        | hd::tl -> let (s,a,e) = hd in
                                    if (s=x) then a else (find_in_list x tl)

exception ElementNotFound
exception IllFormedStack
let rec searchLatest x stack head = if head>=1 then
                                    (
                                      let l = (nth_in_list stack head) in
                                      match l with
                                      FuncName(s) -> if s=x then head else (searchLatest x stack (head - 5))
                                      | _ -> raise IllFormedStack
                                    )
                                    else raise ElementNotFound

(*Assuming a can call b, we will try to find out static link of b from a*)
let rec getStaticLink head b stack = let FuncName(a) = (nth_in_list stack head) in
                                     if (a=b) then (let StaticLink(n) = (nth_in_list stack (head - 2)) in  n)
                                     else if ((parentName b) = a) then head
                                     else (searchLatest (parentName b) stack (head - 5))

exception RestrictedAccessToVariable
let rec valueOfVariable x stack head = if head>=1 then
                                      (
                                        try(
                                          match (nth_in_list stack (head+1)) with
                                          LocalVblsList(l) -> find_in_list x l
                                          | _ -> raise IllFormedStack
                                        )
                                        with NotFound -> (
                                          try(
                                            match (nth_in_list stack (head - 1)) with
                                            ArgsList(l) -> find_in_list x l
                                            | _ -> raise IllFormedStack
                                          )
                                          with NotFound -> let StaticLink(n) = (nth_in_list stack (head-2)) in (valueOfVariable x stack n)
                                        )
                                      )
                                      else raise RestrictedAccessToVariable

let rec value x stack head = match x with
                            Integer(i) -> NumVal(i)
                          | Bool(b)    -> BoolVal(b)
                          | V(s)       -> valueOfVariable s stack head

let head = ref 1
let stack = ref ([FuncName("main");LocalVblsList([("a",NumVal(0),Tint);("b",NumVal(0),Tint);("c",NumVal(0),Tint)])])

let rec evalArgList argPassed stack head = match argPassed with
                                          [] -> []
                                        | hd::tl -> (value hd stack head) :: (evalArgList tl stack head)

let getType a = match a with
                NumVal(i) -> Tint
              | BoolVal(b) -> Tbool

exception InvalidArguments
exception MainCannotBeCalled_PleaseReturnToMain

let addFrames funcName argPassed stack head = let a = evalArgList argPassed (!stack) (!head) in
                                              if ((List.length argPassed !=2) || ((getType (nth_in_list a 1)) != Tint) || ((getType (nth_in_list a 2)) != Tint)) then
                                                raise InvalidArguments
                                              else
                                              let staticLink = getStaticLink (!head) funcName (!stack) in
                                              head := (!head) + 5;
                                              match funcName with
                                              "P" -> stack := (!stack) @ ([RetAddr(!head-5);StaticLink(staticLink);ArgsList([("x",(nth_in_list a 1),Tint);("y",(nth_in_list a 2),Tint)]);FuncName(funcName);LocalVblsList([("z",NumVal(0),Tint);("a",NumVal(0),Tint)])])
                                            | "Q" -> stack := (!stack) @ ([RetAddr(!head-5);StaticLink(staticLink);ArgsList([("z",(nth_in_list a 1),Tint);("w",(nth_in_list a 2),Tint)]);FuncName(funcName);LocalVblsList([("x",NumVal(0),Tint);("b",NumVal(0),Tint)])]) 
                                            | "R" -> stack := (!stack) @ ([RetAddr(!head-5);StaticLink(staticLink);ArgsList([("w",(nth_in_list a 1),Tint);("i",(nth_in_list a 2),Tint)]);FuncName(funcName);LocalVblsList([("j",NumVal(0),Tint);("b",NumVal(0),Tint)])]) 
                                            | "S" -> stack := (!stack) @ ([RetAddr(!head-5);StaticLink(staticLink);ArgsList([("c",(nth_in_list a 1),Tint);("k",(nth_in_list a 2),Tint)]);FuncName(funcName);LocalVblsList([("m",NumVal(0),Tint);("n",NumVal(0),Tint)])]) 
                                            | "T" -> stack := (!stack) @ ([RetAddr(!head-5);StaticLink(staticLink);ArgsList([("a",(nth_in_list a 1),Tint);("y",(nth_in_list a 2),Tint)]);FuncName(funcName);LocalVblsList([("i",NumVal(0),Tint);("f",NumVal(0),Tint)])]) 
                                            | "U" -> stack := (!stack) @ ([RetAddr(!head-5);StaticLink(staticLink);ArgsList([("c",(nth_in_list a 1),Tint);("z",(nth_in_list a 2),Tint)]);FuncName(funcName);LocalVblsList([("p",NumVal(0),Tint);("g",NumVal(0),Tint)])]) 
                                            | "V" -> stack := (!stack) @ ([RetAddr(!head-5);StaticLink(staticLink);ArgsList([("m",(nth_in_list a 1),Tint);("n",(nth_in_list a 2),Tint)]);FuncName(funcName);LocalVblsList([("c",NumVal(0),Tint)])]) 
                                            | "W" -> stack := (!stack) @ ([RetAddr(!head-5);StaticLink(staticLink);ArgsList([("m",(nth_in_list a 1),Tint);("p",(nth_in_list a 2),Tint)]);FuncName(funcName);LocalVblsList([("j",NumVal(0),Tint);("h",NumVal(0),Tint)])]) 
                                            | "main" -> raise MainCannotBeCalled_PleaseReturnToMain
                                            | _ -> raise InvalidFunctionName



let returnProcedure stack head = if((!head)>1) then
                                  (
                                    let RetAddr(n) = nth_in_list (!stack) (!head - 3) in
                                    stack := first_n_elem (!stack) (n+1);
                                    head := n
                                  )
                                  else ((print_string ("Returning from Main \n No More Execution Possible \n"));(stack:=[]; head:=(-1)))

let callProcedure s l stack head = let FuncName(p) = (nth_in_list (!stack) (!head)) in
                                    if (callable p s) then (addFrames s l stack head) else raise CannotCall

exception TypeMisMatch
let rec replace x a ty l = match l with
                        [] -> raise NotFound
                      | (s,i,t)::tl -> if(s=x) then (if t=ty then (s,a,t)::tl else (raise TypeMisMatch))
                                    else (s,i,t)::(replace x a ty tl)

let rec assign_variable x stack head a ty = if (!head <1) then raise RestrictedAccessToVariable
                                              else 
                                              (
                                                try
                                                (
                                                  match (nth_in_list (!stack) (!head + 1)) with
                                                  LocalVblsList(l1) -> let l2 = replace x a ty l1 in
                                                                        stack := (first_n_elem (!stack) (!head)) @ [LocalVblsList(l2)] @ (last_n_elem (!stack) ((List.length !stack)-(!head)-1))
                                                  | _ -> raise IllFormedStack
                                                )
                                                with NotFound -> 
                                                              try
                                                              (
                                                                match (nth_in_list (!stack) (!head - 1)) with
                                                                ArgsList(l1) -> let l2 = replace x a ty l1 in
                                                                stack := (first_n_elem (!stack) (!head-2)) @ [ArgsList(l2)] @ (last_n_elem (!stack) ((List.length !stack)-(!head)+1))
                                                              )
                                                              with NotFound -> let StaticLink(n) = (nth_in_list !stack (!head - 2)) in
                                                                                (assign_variable x stack (ref n) a ty)
                                              )

let assign x e stack head = let a = value e (!stack) (!head) in
                            let ty = getType a in
                            (assign_variable x stack head a ty)

let rec showStaticLinks stack head = if ((head)>1) then
                                      (
                                        let StaticLink(n) = nth_in_list (stack) (head-2) in
                                        let FuncName(s) = nth_in_list (stack) (n) in
                                        (print_string (s^"\n")); (showStaticLinks stack (n))
                                      )

let rec callableProcedures a l = if(List.length l)>0 then 
                            match l with
                        | hd::tl -> if (callable a hd ) then (print_string (hd^"\n");(callableProcedures a tl)) 
                                    else (callableProcedures a tl)

let rec accessibleVbls stack head l = if(List.length l)>0 then
                                      (
                                        try
                                        (
                                          let NumVal(v) = valueOfVariable (List.hd l) stack head in
                                          print_string ("Variable: "^(List.hd l)^". Value: "^(string_of_int v)^"\n");
                                          (accessibleVbls stack head (List.tl l))
                                        )
                                        with _ -> (accessibleVbls stack head (List.tl l))
                                      )  

let procedures = ["P";"Q";"R";"S";"T";"U";"V";"W"]
let vbls_list = ["a";"b";"c";"w";"x";"y";"z";"i";"j";"k";"m";"n";"f";"p";"g";"h"]

let rec printList l n= if n > 0 then
                      (
                        let FuncName(s) = nth_in_list l n in
                        print_string (s^"\n");
                        printList l (n-5);
                      )

let main comm = match comm with
                Return -> returnProcedure stack head
              | Assign(x,e) -> assign x e stack head
              | FuncCall(s,l) -> callProcedure s l stack head
              | CallableProc  -> let FuncName(s) = nth_in_list (!stack) (!head) in (callableProcedures s procedures)
              | CallingStack -> printList (!stack) (!head)
              | StaticLinkChain -> showStaticLinks (!stack) (!head)
              | AccessibleVbls -> accessibleVbls (!stack) (!head) vbls_list

(*
  let head = ref 1
let stack = ref ([FuncName("main");LocalVblsList([("a",NumVal(0),Tint);("b",NumVal(0),Tint);("c",NumVal(0),Tint)])])

  main (FuncCall("P",[Integer(8);Integer(5)]));;
  main (FuncCall("Q",[Integer(8);Integer(5)]));;
*)