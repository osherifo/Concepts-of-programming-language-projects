data Lambdaterm = V Char | Lambda Char Lambdaterm | App Lambdaterm Lambdaterm deriving (Show)



--isFree :: Lambdaterm -> Bool

isFree exp variable = case exp of 
 (V x)  -> True
 (App x y) -> (isFree x variable) && (isFree y variable)
 (Lambda x y) -> if x==variable then (notcontains y x) else (isFree y variable)
 
notcontains term exp = case term of
 (V x) -> (x/=exp)
 (Lambda x y) -> if x==exp then True else (notcontains y exp)
 (App t1 t2) -> (notcontains t1 exp) && (notcontains t2 exp)

  
 
inc :: Char -> Char
inc a = if a =='z' then 'a' else toEnum ((fromEnum a) + 1)

 
 

reduce(V x) = (V x)

reduce (Lambda x term) = case term of
 (V y)  -> (Lambda x (V y))
 (Lambda y t) -> (Lambda x (reduce ( Lambda y t)))
 (App t (V y)) ->  if (x==y) then (reduce (eta (Lambda x (App t (V x))))) else reduce (Lambda x (reduce (App t (V y)))) 
 (App (V x) (V y)) -> (Lambda x term)
 (App t t2) -> reduce (Lambda x (reduce (App t t2)))
 

 
reduce (App t1 t2) = case t1 of
 (V x) ->  (App (V x) (reduce t2))
 (Lambda x t) ->  if isOmega (App t1 t2) then (App t1 t2)  else reduce (beta (App t1 t2))
 (App t3 t4) -> helpereduce (App (reduce t1)(reduce t2))
 
helpereduce (App t1 t2) = case t1 of
 (V x)-> (App t1 t2)
 (Lambda x t)-> reduce (App t1 t2)
 (App t3 t4)-> (App t1 t2)
 
 


 
 
alpha term subs = case term of
 (V x) -> if x==subs then (V (inc x)) else (V x)
 (Lambda x t) -> if x==subs then (Lambda (inc x) (alphahelper t subs)) else (Lambda x (alpha t subs)) 
 (App t1 t2) -> (App (alpha t1 subs)(alpha t2 subs))

alphahelper term subs = case term of
 (V x) -> if x==subs then (V (inc x)) else (V x)
 (Lambda x t) -> if x==subs then (Lambda x t) else (Lambda x (alphahelper t subs))
 (App t1 t2) -> (App (alphahelper t1 subs)(alphahelper t2 subs))

 
 
 
beta (App (Lambda x (V y)) t) = if x==y then t else (V y)
beta (App (Lambda x (Lambda y t1)) t2) = if x==y then (Lambda y t1) else if isFree t1 y then (Lambda y (beta (App (Lambda x(alpha t1 y)) t2))) else (Lambda y (beta (App(Lambda x t1) t2))) --free captured !!
beta (App (Lambda x (App t1 t2)) t3) = (App (beta (App (Lambda x t1) t3)) (beta (App (Lambda x t2) t3)) )
 
 
eta (Lambda x (App t (V y))) = if isFree t x then alpha t x else t
 
isOmega (App (Lambda a (App (V b)(V c))) (Lambda d (App (V e)(V f))) ) = (a==b && b==c && c==d && d==e && e==f )
isOmega exp = False
