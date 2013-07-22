% Author H.-G. Graebe | Univ. Leipzig 
% graebe@informatik.uni-leipzig.de

module cali; 

terpri(); write "CALI 2.2. Last update Febr. 14, 1995"; terpri();

COMMENT

              #########################
              ####                 ####
              ####  HEADER MODULE  ####
              ####                 ####
              #########################

This is the header module of the package CALI, a package for
computational commutative algebra.

Author :        H.-G. Graebe
                Univ. Leipzig
                Institut fuer Informatik
                Augustusplatz 10 - 11
                D - 04109 Leipzig
                Germany

        email : graebe@informatik.uni-leipzig.de


Version : 2.2, finished at Febr. 14, 1995.

See cali.chg for change's documentation.

Please send all comments, bugs, hints, wishes, criticisms etc. to the
above email address.


Abstract :

This package contains algorithms for computations in commutative
algebra closely related to the Groebner algorithm for ideals and
modules. There are facilities for local computations, using a modern
implementation of Mora's standard basis algorithm, that works for
arbitrary term orders. This reflects the full analogy between modules
over local rings and homogeneous (in fact H-local) modules over
polynomial rings.

CALI extends also the term order facilities of the REDUCE internal
groebner package, defining term orders by degree vector lists, and
the rigid implementation of the sugar idea, by a more flexible ecart
vector, in particular useful for local computations. Version 2.2. has
also a common view on normal forms for noetherian and non-noetherian
term orders. 

The package was designed mainly as a symbolic mode programming
environment extending the build-in facilities of REDUCE for the
computational approach to problems arising naturally in commutative
algebra. An algebraic mode interface allows to access (in a more
rigid frame) all important features implemented symbolically.

As main topics CALI contains facilities for

-- defining rings, ideals and modules,

-- computing Groebner bases and local standard bases,

-- computing syzygies, resolutions and (graded) Betti numbers,

-- computing (also weighted) Hilbert series, multiplicities,
	independent sets, dimensions,

-- computing normal forms and representations,

-- computing sums, products, intersections, elimination ideals etc.,

-- primality tests, computation of radicals, unmixed radicals,
	equidimensional parts, primary decompositions etc. of ideals
	and modules,
  
-- advanced applications of Groebner bases (blowup, associated graded
	ring, analytic spread, symmetric algebra, monomial curves), 

-- applications of linear algebra techniques to zerodimensional
	ideals, as e.g. the FGLM change of term orders, border bases
	and affine and projective ideals of sets of points,

-- splitting polynomial systems of equations mixing factorization and
	Groebner algorithm, triangular systems, and different versions
	of the extended Groebner factorizer.

Reduce version required : 

The program was tested under v. 3.5. and 3.4.1., but should work as
well under v. 3.3. 
(I had some trouble with the module dualbases under 3.4.1)

Relevant publications : 

See the bibliography in the manual.


Key words : 

Groebner algorithm for ideals and modules, local standard bases,
Groebner factorizer, extended Groebner factorizer, triangular systems, 
normal forms, ideal and module operations, Hilbert series, independent
sets, dual bases, border bases, affine and projective sets of points, 
free resolution, constructive commutative algebra, primality test,
radical, unmixed radical, equidimensional part, primary decomposition,
blowup, associated graded ring, analytic spread, symmetric algebra,
monomial curves. 
 


To be done :

eo(vars) : test cali!=basering for eliminationorder according to vars 
	-> eliminate

If multivariate factorization is allowed, then one should use
groebf_zeroprimes1(m,nil) instead of prime_zeroprimes1 m.

Remind :

Never "put" variables, that are subject to rebounding via "where" !

end comment;

create!-package( '(
        cali            % This header module.
        bcsf            % Base coeff. arithmetics.
        ring            % Base ring and monomial arithmetics.
        mo              % Monomial arithmetic.
        dpoly           % Distr. polynomial (and vector) arithmetics.
        bas             % Polynomial lists.
        dpmat           % dpmat's arithmetic.
        red             % Normal form algorithms and related topics. 
        groeb           % Groebner algorithm and related topics.
	groebf		% Groebner factorizer and extensions.
        matop           % Module operations on dpmats.
        quot            % Different quotients.
        moid            % Lead. term ideal algorithms.
	hf		% Hilbert series.
        res             % Resolutions.
        intf            % Interface to algebraic mode.
        odim            % Alg. for zerodimensional ideals and
                        %	modules. 
        prime           % Primality test, radical, and primary
                        % decomposition.  
	scripts		% Advanced applications, inspired by the
			%	scripts of Bayer/Stillman.
	calimat		% CALI's extension of the matrix package.
	lf		% The dual bases approach (FGLM etc.).
	triang		% (Zero dimensional) triangular systems.
	),nil);

load!-package 'matrix;

fluid '(
        cali!=basering  % see rings
        cali!=degrees   % see mons in rings
        cali!=monset    % see groeb
        );

                        % Default :
switch  
        hardzerotest,   % (off) see bcsf, try simp for each zerotest.
        red_total,      % (on)  see red, do total reductions. 
        bcsimp,         % (on)  see red, cancel coefficient's gcd.
        noetherian,     % (on)  see interf, test term orders and
                        %                choose non local algorithms.
        factorunits,    % (off) see groeb, try to remove units from
                        %               polynomials by factorization.
        detectunits,    % (off) see groeb, detect generators of the form
                        %               monomial * unit.
	lexefgb;	% (off) see groebf, invoke the extended
			%		Groebner factorizer with pure
			%		lex zerosolve. 

% The first initialization : 

put('cali,'trace,0);    % No tracing.
linelength 79;          % This is much more convenient than 80.

% The new tracing. We hope that this shape will easily interface to a
% forthcoming general trace utility. 

symbolic operator setcalitrace;
symbolic procedure setcalitrace(n); 
% Set trace intensity.
	put('cali,'trace,n);

symbolic operator setcaliprintterms;
symbolic procedure setcaliprintterms(n); 
% Set number of terms to be printed in intermediate output.
  if n<=0 then typerr(n,"number of terms to be printed")
  else put('cali,'printterms,n);  

symbolic operator clearcaliprintterms;
symbolic procedure clearcaliprintterms; 
% Set intermediate output printing to "all".
  << remprop('cali,'printterms); write"Term print bound cleared";
     terpri(); 
  >>;

symbolic procedure cali_trace(); 
% Get the trace intensity.
	get('cali,'trace);

% ---- Some useful things, probably implemented also elsewhere
% ---- in the system.

symbolic procedure first x; car x;
symbolic procedure second x; cadr x;
symbolic procedure third x; caddr x;

symbolic procedure strcat l;
% Concatenate the items in the list l to a string.
  begin scalar u;
  u:=for each x in l join explode x;
  while memq('!!,u) do u:=delete('!!,u);
  while memq('!",u) do u:=delete('!",u);
  return compress append(append('(!"),u),'(!"));
  end;

symbolic procedure numberlistp l;
% l is a list of numbers.
  if null l then t
  else fixp car l and numberlistp cdr l;
  
symbolic procedure merge(l1,l2,fn);
% Returns the (physical) merge of the two sorted lists l1 and l2.
  if null l1 then l2
  else if null l2 then l1
  else if apply2(fn,car l1,car l2) then rplacd(l1,merge(cdr l1,l2,fn))
  else rplacd(l2,merge(l1,cdr l2,fn));

symbolic procedure listexpand(fn,l); eval expand(l,fn);

symbolic procedure listtest(a,b,f);
% Return the first u in a s.th. f(u,b) or nil.
  if null a then nil
  else if apply2(f,car a,b) then if car a=nil then t else car a
  else listtest(cdr a,b,f);
  
symbolic procedure listminimize(a,f);
% Returns a minimal list b such that for all v in a ex. u in b such
% that f(u,v). The elements are in the same order as in a.
  if null a then nil else reverse cali!=min(nil,a,f);

symbolic procedure cali!=min(b,a,f);
  if null a then b
  else if listtest(b,car a,f) or listtest(cdr a,car a,f) then 
        cali!=min(b,cdr a,f)
  else cali!=min(car a . b,cdr a,f);

symbolic procedure makelist u; 'list . u;

symbolic procedure subsetp(u,v); 
% true :<=> u \subset v
  if null u then t else member(car u,v) and subsetp(cdr u,v);

symbolic procedure disjoint(a,b);
  if null a then t else not member(car a,b) and disjoint(cdr a,b);

symbolic procedure print_lf u;
% Line feed after about 70 characters.
  <<if posn()>69 then <<terpri();terpri()>>; prin2 u>>;

symbolic procedure cali_choose(m,k);
% Returns the list of k-subsets of m.
  if (length m < k) then nil
  else if k=1 then for each x in m collect list x
  else nconc(
        for each x in cali_choose(cdr m,k-1) collect (car m . x),
        cali_choose(cdr m,k));

endmodule; % cali - The header module



module bcsf; 

COMMENT


            #######################
            #                     #
            #  BASE COEFFICIENTS  #
            #                     #
            #######################


These base coefficients are standard forms.

A list of REPLACEBY rules may be supplied with the setrules command
that will be applied in an additional simplification process.

This rules list is a list of s.f. pairs, where car should replace cdr.

END COMMENT;

% Standard is :

!*hardzerotest:=nil;

symbolic operator setrules;
symbolic procedure setrules m; setrules!* cdr reval m;

symbolic procedure setrules!* m;
  begin scalar r; r:=ring_names cali!=basering;
  m:=for each x in m collect
        if not eqcar(x,'replaceby) then
                typerr(makelist m,"rules list")
        else (numr simp second x . numr simp third x);
  for each x in m do
    if domainp car x or member(mvar car x,r) then
        rederr"no substitution for ring variables allowed";
  put('cali,'rules,m);
  return getrules();
  end;

symbolic operator getrules;
symbolic procedure getrules();
  makelist for each x in get('cali,'rules) collect
        list('replaceby,prepf car x,prepf cdr x);

symbolic procedure bc!=simp u;
  (if r0 then
  begin scalar r,c; integer i; 
  i:=0; r:=r0;
  while r and (i<1000) do
  << c:=qremf(u,caar r);
     if null car c then r:=cdr r
     else
     << u:=addf(multf(car c,cdar r),cdr c);
        i:=i+1; r:=r0;
     >>;
  >>;
  if (i<1000) then return u
  else rederr"recursion depth of bc!=simp too high"
  end
  else u) where r0:=get('cali,'rules);

symbolic procedure  bc_minus!? u; minusf u;

symbolic procedure  bc_zero!? u; 
    if (null u or u=0) then t
    else if !*hardzerotest and pairp u then 
        null bc!=simp numr simp prepf u
    else nil; 

symbolic procedure  bc_fi a; if a=0 then nil else a;

symbolic procedure  bc_one!? u; (u = 1);

symbolic procedure  bc_inv u; 
% Test, whether u is invertible. Return the inverse of u or nil.
  if (u=1) or (u=-1) then u 
  else begin scalar v; v:=qremf(1,u);
    if cdr v then return nil else return car v;
    end;

symbolic procedure  bc_neg u; negf u;

symbolic procedure  bc_prod (u,v); bc!=simp multf(u,v);

symbolic procedure  bc_quot (u,v); 
  (if null cdr w then bc!=simp car w else typerr(v,"denominator")) 
  where w=qremf(u,v);

symbolic procedure  bc_sum (u,v); addf(u,v);

symbolic procedure  bc_diff(u,v); addf(u,negf v);

symbolic procedure  bc_power(u,n); bc!=simp exptf(u,n);

symbolic procedure  bc_from_a u; bc!=simp numr simp!* u;

symbolic procedure  bc_2a u; prepf u;

symbolic procedure  bc_prin u; 
% Prints a base coefficient in infix form
   ( if domainp u then 
         if dmode!*='!:mod!: then prin2 prepf u
         else printsf u
     else << write"("; printsf u; write")" >>) where !*nat=nil;

symbolic procedure bc_divmod(u,v); % Returns quot . rem.
  qremf(u,v);

symbolic procedure bc_gcd(u,v); gcdf!*(u,v);

symbolic procedure bc_lcm(u,v); 
    car bc_divmod(bc_prod(u,v),bc_gcd(u,v));

endmodule; % bcsf


module ring; 

COMMENT

               ##################
               ##              ##
               ##    RINGS     ##
               ##              ##
               ##################


Informal syntax :

Ring = ('RING (name list) ((degree list list)) deg_type ecart) 
        with deg_type = 'lex or 'revlex.

The term order is defined at first comparing successively degrees and
then by the name list lex. or revlex. For details consult the manual.

(name list) contains a phantom name cali!=mk for the module
component, see below in module mo.

The variable cali!=basering contains the actual base ring.

The ecart is a list of positive integers (the ecart vector for the
given ring) and has
        length = length names cali!=basering.
It is used in several places for optimal strategies (noetherina term
orders ) or to guarantee termination (local term orders).
All homogenizations are executed with respect to that list.

END COMMENT;

symbolic procedure ring_define(n,to,type,ecart); 
    list('ring,'cali!=mk . n, to, type,ecart);

symbolic procedure setring!* c;
  begin 
     if !*noetherian and not ring_isnoetherian c then
        rederr"term order is not noetherian";
     cali!=basering:=c; 
     setkorder ring_all_names c;
     return c;
  end;

symbolic procedure setecart!* e;
  begin scalar r; r:=cali!=basering;
    if not ring_checkecart(e,ring_names r) then
        typerr(e,"ecart vector")
    else cali!=basering:=
        ring_define(ring_names r,ring_degrees r,ring_tag r,e)
  end;          

symbolic procedure ring_2a c;
    makelist {makelist ring_names c,
          makelist for each x in ring_degrees c collect makelist x,
          ring_tag c, makelist ring_ecart c};

symbolic procedure ring_from_a u;
  begin scalar vars,tord,c,r,tag,ecart;
  if not eqcar(u,'list) then typerr(u,"ring") else u:=cdr u;
  vars:=reval car u; tord:=reval cadr u; tag:=reval caddr u;
  if length u=4 then ecart:=reval cadddr u;
  if not(tag memq '(lex revlex)) then typerr(tag,"term order tag");
  if not eqcar(vars,'list) then typerr(vars,"variable list")
  else vars:=cdr vars;
  if tord={'list} then c:=nil
  else if not (c:=ring!=testtord(vars,tord)) then
        typerr(tord,"term order degrees");
  if null ecart then 
     if (null tord)or not ring_checkecart(car tord,vars) then 
                ecart:=for each x in vars collect 1
     else ecart:=car tord
  else if not ring_checkecart(cdr ecart,vars) then
        typerr(ecart,"ecart list")
  else ecart:=cdr ecart;
  r:=ring_define(vars,c,tag,ecart);
  if !*noetherian and not(ring_isnoetherian r) then
        rederr"Term order is non noetherian";
  return r
  end;

symbolic procedure ring!=testtord(vars,u);
% Test the non empty term order degrees for consistency and return
% the symbolic equivalent of u.
  if (ring!=lengthtest(cdr u,length vars +1) 
        and ring!=contenttest cdr u)
            then for each x in cdr u collect cdr x
  else nil;

symbolic procedure ring!=lengthtest(m,v);
% Test, whether m is a list of (algebraic) lists of the length v.
  if null m then t
  else eqcar(car m,'list)
        and (length car m = v)
        and ring!=lengthtest(cdr m,v);

symbolic procedure ring!=contenttest m;
% Test, whether m is a list of (algebraic) number lists.
  if null m then t
  else numberlistp cdar m and ring!=contenttest cdr m;

symbolic procedure ring_names r; % User names only
        cdadr r;

symbolic procedure ring_all_names r; cadr r; % All names

symbolic procedure ring_degrees r; caddr r;

symbolic procedure ring_tag r; cadddr r;

symbolic procedure ring_ecart r; nth(r,5);

% --- Test the term order for the chain condition ------

symbolic procedure ring!=trans d;
% Transpose the degree matrix.
  if (null d)or(null car d) then nil
  else (for each x in d collect car x) . 
                ring!=trans(for each x in d collect cdr x);

symbolic procedure ring!=testlex d;
   if null d then t
   else ring!=testlex1(car d) and ring!=testlex(cdr d);

symbolic procedure ring!=testlex1 d;
   if null d then t
   else if car d=0 then ring!=testlex1(cdr d)
   else (car d>0);

symbolic procedure ring!=testrevlex d;
   if null d then t
   else ring!=testrevlex1(car d) and ring!=testrevlex(cdr d);

symbolic procedure ring!=testrevlex1 d;
   if null d then nil
   else if car d=0 then ring!=testrevlex1(cdr d)
   else (car d>0);

symbolic procedure ring_isnoetherian r;
% Test, whether the term order of the ring r satisfies the chain
% condition.
  if ring_tag r ='revlex then 
                ring!=testrevlex ring!=trans ring_degrees r
  else ring!=testlex ring!=trans ring_degrees r;

symbolic procedure ring!=degpos d;
  if null d then t
  else (car d>0) and ring!=degpos cdr d;

symbolic procedure ring_checkecart(e,vars);
  (length e=length vars) and ring!=degpos e;

% ---- Test noetherianity switching noetherian on : 

put('noetherian,'simpfg,'((t (ring!=test))));

symbolic procedure ring!=test;
  if not ring_isnoetherian cali!=basering then
    << !*noetherian:=nil; 
       rederr"Current term order is not noetherian" 
    >>;

% ---- Different term orders -------------

symbolic operator eliminationorder;
symbolic procedure eliminationorder(v1,v2);
% Elimination order : v1 = all variables; v2 = variables to eliminate.
  if !*mode='algebraic then
	makelist for each x in 
		eliminationorder!*(cdr reval v1,cdr reval v2)  
			collect makelist x
  else eliminationorder!*(v1,v2);

symbolic operator degreeorder;
symbolic procedure degreeorder(vars);
  if !*mode='algebraic then
	makelist for each x in degreeorder!*(cdr reval vars) collect
		makelist x 
  else degreeorder!*(vars);

symbolic operator localorder;
symbolic procedure localorder(vars);
  if !*mode='algebraic then
	makelist for each x in localorder!*(cdr reval vars) collect
		makelist x 
  else localorder!*(vars);

symbolic operator blockorder;
symbolic procedure blockorder(v1,v2);
  if !*mode='algebraic then
	makelist for each x in 
		blockorder!*(cdr reval v1,cdr reval v2)  
			collect makelist x
  else blockorder!*(v1,v2);

symbolic procedure blockorder!*(vars,l);
% l is a list of integers, that sum up to |vars|. 
% Returns the degree vector for the corresponding block order.
  if neq(for each x in l sum x,length vars) then
	rederr"block lengths sum doesn't match variable number"
  else begin scalar u; integer pre,post;
  pre:=0; post:=length vars;
  for each x in l do
  << u:=(append(append(for i:=1:pre collect 0,for i:=1:x collect 1), 
		for i:=1:post-x collect 0)) . u; 
     pre:=pre+x; post:=post-x
  >>;
  return reversip u;
  end;  

symbolic procedure eliminationorder!*(v1,v2);
% Elimination order : v1 = all variables
% v2 = variables to eliminate. 
  { for each x in v1 collect
        if x member v2 then 1 else 0,
    for each x in v1 collect
        if x member v2 then 0 else 1};

symbolic procedure degreeorder!*(vars);
  {for each x in vars collect 1};

symbolic procedure localorder!*(vars);
  {for each x in vars collect -1};

% ---------- Ring constructors -----------------

symbolic procedure ring_rlp(r,u);
% u is a subset of ring_names r. Returns the ring r with the block order
% "first degrevlex on u, then the order on r"
  ring_define(ring_names r,
  (for each x in ring_names r collect if x member u then 1 else 0)
  . append(reverse for each x in u collect 
	for each y in ring_names r collect if x=y then -1 else 0, 
		ring_degrees r), ring_tag r, ring_ecart r);

symbolic procedure ring_lp(r,u);
% u is a subset of ring_names r. Returns the ring r with the block order
% "first lex on u, then the order on r"
  ring_define(ring_names r,
  append(for each x in u collect for each y in ring_names r collect
                if x=y then 1 else 0, ring_degrees r), 
	ring_tag r, ring_ecart r);

symbolic procedure ring_sum(a,b);
% Returns the direct sum of two base rings with degree matrix at
% first b then a and ecart=appended ecart lists.
  begin scalar vars,zeroa,zerob,degs,ecart;
  if not disjoint(ring_names a,ring_names b) then
    rederr"RINGSUM only for disjoint variable sets";
  vars:=append(ring_names a,ring_names b);
  ecart:=append(ring_ecart a,ring_ecart b);
  zeroa:=for each x in ring_names a collect 0;
  zerob:=for each x in ring_names b collect 0;
  degs:=append(
    for each x in ring_degrees b collect append(zeroa,x),
    for each x in ring_degrees a collect append(x,zerob));
  return ring_define(vars, degs, ring_tag a,ecart);
  end;

% --------- First initialization :

setring!* ring_define('(t x y z),'((1 1 1 1)),'revlex,'(1 1 1 1));

!*noetherian:=t;

% -------- End of first initialization ----------------

endmodule;  % ring



module mo; 

COMMENT

               ##################
               ##              ##
               ##  MONOMIALS   ##
               ##              ##
               ##################



Monomials are of the form x^a*e_i with a multipower x^a and a module
component e_i. They belong either to the base ring R (i=0) or to a
free module R^c (c >= i > 0).

All computations are performed with respect to a "current module"
over a "current ring" (=cali!=basering).

To each module component e_i of the current module we assign a
"column degree", i.e. a monomial representing a certain multidegree
of the basis vector e_i. See the module dpmat for more details.
The column degrees of the current module are stored in the assoc.
list cali!=degrees.


Informal syntax :

  <monomial> ::= (<exponential part> . <degree part>)
  < .. part> ::= list of integer

Here exponent lists may have varying length since trailing zeroes are
assumed to be omitted. The zero component of <exp. part> contains the
module component. It correspond to the phantom var. name cali!=mk.

END COMMENT;

% ----------- manipulations of the degree part --------------------

symbolic procedure mo!=sprod(a,b);
% Scalar product of integer lists a and b . 
    if not a or not b then 0
    else (car a)#*(car b) #+ mo!=sprod(cdr a,cdr b);
   
symbolic procedure mo!=deglist(a);
% a is an exponent list. Returns the degree list of a. 
  if null a then
      for each x in ring_degrees cali!=basering collect 0
  else (mo!=sum( 
      for each x in ring_degrees cali!=basering collect 
                mo!=sprod(cdr a,x),
      if b then cddr b else nil)
      where b = assoc(car a,cali!=degrees));
      
symbolic procedure mo_neworder m;
% Deletes trailing zeroes and returns m with new degree part.
    (m1 . mo!=deglist m1) where m1 =mo!=shorten car m;

symbolic procedure mo_degneworder l;
% New degree parts in the degree list l.
  for each x in l collect car x . mo_neworder cdr x;

symbolic procedure mo!=shorten m; 
    begin scalar m1;
    m1:=reverse m; 
    while m1 and eqn(car m1,0) do m1:=cdr m1;
    return reversip m1;
    end;

% ------------- comparisions of monomials -----------------

symbolic procedure mo_zero;  nil . mo!=deglist nil;
% Returns the unit monomial x^0.

symbolic procedure mo_zero!? u; mo!=zero car u;
   
symbolic procedure mo!=zero u; 
    null u or car u = 0 and mo!=zero cdr u;
      
symbolic procedure mo_equal!?(m1,m2);
% Test whether m1 = m2.
    equal(mo!=shorten car m1,mo!=shorten car m2);

symbolic procedure mo_divides!?(m1,m2);
% m1,m2:monomial. true :<=> m1 divides m2
    mo!=modiv1(car m1,car m2);
   
symbolic procedure mo!=modiv1(e1,e2);
    if not e1 then t else if not e2 then nil
    else leq(car e1,car e2) and mo!=modiv1(cdr e1, cdr e2);

symbolic procedure mo_compare(m1,m2);
% compare (m1,m2) . m1 < m2 => -1 | m1 = m2 => 0 | m1 > m2 => +1
   begin scalar a,x;
        x:=mo!=degcomp(cdr m1,cdr m2);
        if x eq 0 then 
            x:=if equal(ring_tag cali!=basering,'revlex) then
                       mo!=revlexcomp(car m1, car m2)
               else mo!=lexcomp(car m1,car m2);
        return x;
   end;

symbolic procedure mo_dlexcomp(a,b); mo!=lexcomp(car a,car b)=1;
% Descending lexicographic order, first by mo_comp.

symbolic procedure mo!=degcomp(d1,d2);
    if null d1 then 0
    else if car d1 = car d2 then mo!=degcomp(cdr d1,cdr d2)
    else if car d1 #< car d2 then -1
    else 1; 
    
symbolic procedure mo!=revlexcomp(e1,e2);
    if length e1 #> length e2 then -1
    else if length e2 #> length e1 then 1
    else - mo!=degcomp(reverse e1,reverse e2);

symbolic procedure mo!=lexcomp(e1,e2);
    if null e1 then 
        if null e2 then 0 else mo!=lexcomp('(0),e2)
    else if null e2 then mo!=lexcomp(e1,'(0))
    else if car e1 = car e2 then mo!=lexcomp(cdr e1,cdr e2)
    else if car e1 #> car e2 then 1
    else -1;

% ---------- manipulation of the module component --------

symbolic procedure mo_comp v; 
% Retuns the module component of v.
    if null car v then 0 else caar v;
    
symbolic procedure mo_from_ei i; 
% Make e_i.
    if i=0 then mo_zero() else (x . mo!=deglist x) where x =list(i);
    
symbolic procedure mo_vdivides!?(v1,v2); 
% Equal module component and v1 divides v2.
   eqn(mo_comp v1,mo_comp v2) and mo_divides!?(v1,v2);
    
symbolic procedure mo_deletecomp v; 
% Delete component part.
   if null car v then v
   else if null cdar v then (nil . mo!=deglist nil)
   else ((x . mo!=deglist x) where x=cons(0,cdar v));
   
symbolic procedure mo_times_ei(i,m); 
% Returns m * e_i or n*e_{i+k}, if m=n*e_k.
   (x . mo!=deglist x) 
   where x=if null car m then list(i) else cons(i #+ caar m,cdar m);

symbolic procedure mo_deg m; cdr m;
% Returns the degree part of m.

symbolic procedure mo_getdegree(v,l);
% Compute the (virtual) degree of the monomial v with respect to the
% assoc. list l of column degrees.   
  mo_deletecomp(if a then mo_sum(v,cdr a) else v) 
  where a =assoc(mo_comp(v),l);
   
% --------------- monomial arithmetics -----------------------

symbolic procedure mo_lcm (m1,m2);
%  Monomial least common multiple.
    begin scalar x,e1,e2;
        e1:=car m1; e2:=car m2;
        while e1 and e2 do
            <<x := (if car e1 #> car e2 then car e1 else car e2) . x;
              e1 := cdr e1; e2 := cdr e2>>;
        x:=append(reversip x,if e1 then e1 else e2); 
        return (mo!=shorten x) . (mo!=deglist x);
    end;

symbolic procedure mo_gcd (m1,m2);
%  Monomial greatest common divisor.
   begin scalar x,e1,e2;
      e1:=car m1; e2:=car m2;
      while e1 and e2 do
         <<x := (if car e1 #< car e2 then car e1 else car e2) . x;
           e1 := cdr e1; e2 := cdr e2>>;
      x:=reversip x; return (mo!=shorten x) . (mo!=deglist x);
   end;

symbolic procedure mo_neg v; 
% Return v^-1.
  (for each x in car v collect -x).(for each x in cdr v collect -x);

symbolic procedure mo_sum(m1,m2);
%  Monomial product.
   ((mo!=shorten x) . (mo!=deglist x))  
                        where x =mo!=sum(car m1,car m2);
 
symbolic procedure mo!=sum(e1,e2); 
    begin scalar x;
      while e1 and e2 do
        <<x := (car e1 #+ car e2) . x; e1 := cdr e1; e2 := cdr e2>>;
      return append(reversip x,if e1 then e1 else e2); 
 end;

symbolic procedure mo_diff (m1,m2); mo_sum(m1,mo_neg m2);

symbolic procedure mo_qrem(m,n);
% m,n monomials. Returns (q . r) with m=n^q*r.
    begin scalar m1,n1,q,q1;
    q:=-1; m1:=cdar m; n1:=cdar n;
    while m1 and n1 and (q neq 0) do
        << if car n1 > 0 then
            << q1:=car m1 / car n1;
               if (q=-1) or (q>q1) then q:=q1;
            >>;
           n1:=cdr n1; m1:=cdr m1;
        >>;
    if n1 or (q=-1) then q:=0;
    return q . mo_diff(m,mo_power(n,q));
    end;

symbolic procedure mo_power(mo,n);
% Monomial power mo^n.
   (for each x in car mo collect n #* x) . 
                (for each x in cdr mo collect n #* x);

symbolic procedure mo!=pair(a,b);
  if null a or null b then nil
  else (car a . car b) . mo!=pair(cdr a,cdr b);

symbolic procedure mo_2list m;
% Returns a list (var name . exp) for the monomial m.
  begin scalar k; k:=car m;
  return for each x in 
    mo!=pair(ring_names cali!=basering, if k then cdr k else nil)
        join if cdr x neq 0 then {x};
  end;


symbolic procedure mo_varexp(var,m);
% Returns the exponent of var:var. name in the monomial m. 
    if not member(var,ring_names cali!=basering) then 
                        typerr(var,"variable name")
  else begin scalar c;
    c:=assoc(var,mo_2list m);
    return if c then cdr c else 0
    end;
 
symbolic procedure mo_inc(m,x,j);
% Return monomial m with power of var. x increased by j.
  begin scalar n,v;
  if not member(x,v:=ring_all_names cali!=basering) then
    typerr(x,"dpoly variable");
  m:=car m; 
  while x neq car v do
    << if m then <<n:=car m . n; m:=cdr m>> else n:=0 . n;
       v:=cdr v;
    >>;
  if m then 
    << n:=(car m #+ j).n; if m:=cdr m then n:=nconc(reverse m,n) >>   
  else n:=j . n;
  while n and (car n = 0) do n:=cdr n;
  n:=reversip n;
  return n . mo!=deglist n
  end;

symbolic procedure mo_linear m;
% Test whether the monomial m is linear and return the corresponding
% variable or nil.
  (if (length u=1 and cdar u=1) then caar u else nil)
  where u=mo_2list m;

symbolic procedure mo_ecart m;
% Returns the ecart of the monomial m.
    if null car m then 0 
    else mo!=sprod(cdar (if a then mo_sum(cdr a,m) else m),
	ring_ecart cali!=basering)
	where a:=atsoc(mo_comp m,cali!=degrees);
    
symbolic procedure mo_radical m;
% Returns the radical of the monomial m.
   (x . mo!=deglist x)
        where x = for each y in car m collect if y=0 then 0 else 1;

symbolic procedure mo_seed(m,s);
% Set var's outside the list s equal to one. 
  begin scalar m1,i,x,v;
  if not subsetp(s,v:=ring_all_names cali!=basering) then
    typerr(s,"dpoly name's list");
  m1:=car m; 
  while m1 and v do
    << x:=cons(if member(car v,s) then car m1 else 0,x); 
       m1:=cdr m1; v:=cdr v 
    >>; 
  while x and eqn(car x,0) do x:=cdr x; 
  x:=reversip x; 
  return  x . mo!=deglist x; 
  end;

symbolic procedure mo_wconvert(m,w);
% Conversion of monomials for weighted Hilbert series. 
% w is a list of (integer) weight lists. 
   ( x . mo!=deglist x) where 
	x = mo!=shorten(0 . for each x in w collect 
		(if car m then mo!=sprod(cdar m,x) else 0));

% ---------------- monomial interface ---------------

symbolic procedure mo_from_a u;
% Convert a kernel to a monomial.
   if not(u member ring_all_names cali!=basering) then 
                typerr(u,"dpoly variable")
   else begin scalar x,y;
          y:=mo!=shorten
              for each x in ring_all_names cali!=basering collect 
                            if x equal u then 1 else 0;
          return  y . mo!=deglist y;
        end;
   
symbolic procedure mo_2a e;
% Convert a monomial to part of algebraic prefix form of a dpoly.
   mo!=expvec2a1(car e,ring_all_names cali!=basering);

symbolic procedure mo!=expvec2a1(u,v);
    if null u then nil
    else if car u = 0 then mo!=expvec2a1(cdr u,cdr v)
    else if car u = 1 then car v . mo!=expvec2a1(cdr u,cdr v)
    else list('expt,car v,car u) . mo!=expvec2a1(cdr u,cdr v);


symbolic procedure mo_prin(e,v);
% Print monomial e in infix form. V is a boolean variable which is
% true if an element in a product has preceded this one
    mo!=dpevlpri1(car e,ring_all_names cali!=basering,v);

symbolic procedure mo!=dpevlpri1(e,u,v);
    if null e then nil
    else if car e = 0 then mo!=dpevlpri1(cdr e,cdr u,v)
    else <<if v then print_lf "*";
           print_lf car u;
           if car e #> 1 then <<print_lf "^"; print_lf car e>>;
           mo!=dpevlpri1(cdr e,cdr u,t)>>;

symbolic procedure mo_support m; 
% Returns the support of the monomial m as a list of var. names
% in the correct order.
   begin scalar u; 
   for each x in ring_names cali!=basering do
    if mo_divides!?(mo_from_a x,m) then u:=x . u;
   return reversip u;
   end;

endmodule;  % mo


module dpoly; 

COMMENT

               ##################
               ##              ##
               ## POLYNOMIALS  ##
               ##              ##
               ##################

Polynomial vectors and polynomials are handled in a unique way using
the module component of monomials to store the vector component. If
the component is 0, we have a polynomial, otherwise a vector. They
are represented in a distributive form (dpoly for short).

Informal syntax of (vector) polynomials :

   <dpoly>   ::= list of <term>s
   <term>    ::= ( <monomial> . <base coefficient> ) 

END COMMENT;

% ----------- constructors and selectors -------------------

symbolic procedure dp_lc p; 
% Leading base coefficient of the dpoly p.
   cdar p;

symbolic procedure dp_lmon p;
% Leading monomial of the dpoly p.
   caar p;

symbolic procedure dp_term (a,e);
%  Constitutes a term from a:base coeff. and e:monomial.
   (e . a);

symbolic procedure dp_from_ei n; 
% Returns e_i as dpoly.
  list dp_term(bc_fi 1,mo_from_ei n);

symbolic procedure dp_fi n;
% dpoly from integer
   if n=0 then nil else
   list dp_term(bc_fi n,mo_zero());

symbolic procedure dp_fbc c;
% Converts the base coefficient c into a dpoly.
   if bc_zero!? c then nil else
   list dp_term(c,mo_zero());

% ------------  dpoly arithmetics ---------------------------

symbolic procedure dp!=comp(i,v); 
   if null v then nil  
   else if eqn(mo_comp dp_lmon v,i) then car v . dp!=comp(i,cdr v)
   else dp!=comp(i,cdr v);

symbolic procedure dp_comp(i,v); 
% Returns the (polynomial) component i of the vector v.
   for each x in dp!=comp(i,v) collect (mo_deletecomp car x) . cdr x;

symbolic procedure dp!=mocompare (t1,t2);
% true <=> term t1 is smaller than term t2 in the current term order.
     eqn(mo_compare (car t1, car t2),1);

symbolic procedure dp_neworder p;
% Returns reordered dpoly p after change of the term order.
   sort(for each x in p collect (mo_neworder car x) . cdr x,
            function dp!=mocompare);

symbolic procedure dp_neg p;
% Returns - p  for the dpoly p.
   for each x in p collect (car x .  bc_neg cdr x);

symbolic procedure dp_times_mo (mo,p);
% Returns p * x^mo for the dpoly p and the monomial mo.
   for each x in p collect (mo_sum(mo,car x) .  cdr x);

symbolic procedure dp_times_bc (bc,p);
% Returns p * bc for the dpoly p and the base coeff. bc.
   for each x in p collect (car x .  bc_prod(bc,cdr x));

symbolic procedure dp_times_bcmo (bc,mo,p);
% Returns p * bc * x^mo for the dpoly p, the monomial mo and the base
% coeff. bc.
   for each x in p collect (mo_sum(mo,car x) .  bc_prod(bc,cdr x));

symbolic procedure dp_times_ei(i,p);
% Returns p * e_i for the dpoly p.
   dp_neworder for each x in p collect (mo_times_ei(i,car x) . cdr x);

symbolic procedure dp_project(p,k);
% Delete all terms x^a*e_i with i>k.
  for each x in p join if mo_comp car x <= k then {x};

symbolic procedure dp_content p; 
% Returns the leading coefficient, if invertible, or the content of
% p. 
  if null p then bc_fi 0
  else begin scalar w; 
        w:=dp_lc p; p:=cdr p;
        while p and not bc_inv w do
         << w:=bc_gcd(w,dp_lc p); p:=cdr p >>;
        return w
        end;

symbolic procedure dp_mondelete(p,s);
% Returns (p.m) with common monomial factor m with support in the
% var. list s deleted. 
   if null p or null s then (p . mo_zero()) else
   begin scalar cmf;
     cmf:=dp!=cmf(p,s); 
     if mo_zero!? cmf then return (p . cmf)
     else return    
       cons(for each x in p collect mo_diff(car x,cmf) . cdr x,cmf)
   end;
        
symbolic procedure dp!=cmf(p,s);   
   begin scalar a;
        a:=mo_seed(dp_lmon p,s); p:=cdr p;
        while p and (not mo_zero!? a) do 
                << a:=mo_gcd(a,mo_seed(dp_lmon p,s)); p:=cdr p >>;
        return a
   end;
   
symbolic procedure dp_unit!? p; 
% Tests whether lt p of the dpoly p is a unit.
% This means : p is a unit, if the t.o. is noetherian
%       or   : p is a local unit, if the t.o. is a tangentcone order.
   p and (mo_zero!? dp_lmon p); 

symbolic procedure dp_simp pol;
% Returns (pol_new . z) with 
%       pol_new having leading coefficient 1 or
%       dp_content pol canceled out 
% and pol_old = z * dpoly_new .

  if null pol then pol . bc_fi 1
  else begin scalar z,z1; 
    if (z:=bc_inv (z1:=dp_lc pol)) then
        return dp_times_bc(z,pol) . z1;

    % -- now we assume that base coefficients are a gcd domain ----    

    z:=dp_content pol;
    if bc_minus!? z1 then z:=bc_neg z;
    pol:=for each x in pol collect 
                car x . car bc_divmod(cdr x,z);
    return pol . z;
    end;
   
symbolic procedure dp_prod(p1,p2);
% Returns p1 * p2 for the dpolys p1 and p2.
    if length p1 <= length p2 then dp!=prod(p1,p2) 
                              else dp!=prod(p2,p1);

symbolic procedure dp!=prod(p1,p2);
  if null p1 or null p2 then nil
  else 
     begin scalar v;
       for each x in p1 do 
                v:=dp_sum( dp_times_bcmo(cdr x,car x, p2 ),v);
       return v;
     end;

symbolic procedure dp_sum(p1,p2);
% Returns p1 + p2 for the dpolys p1 and p2.
    if null p1 then p2
    else if null p2 then p1
    else begin scalar sl,al;
        sl := mo_compare(dp_lmon p1, dp_lmon p2);
        if sl = 1 then return car p1 . dp_sum(cdr p1, p2);
        if sl = -1 then return car p2 . dp_sum(p1, cdr p2); 
        al := bc_sum(dp_lc p1, dp_lc p2);
        if bc_zero!? al then return dp_sum(cdr p1, cdr p2)
        else return dp_term(al,dp_lmon p1) . dp_sum(cdr p1, cdr p2)
        end; 

symbolic procedure dp_diff(p1,p2);
% Returns p1 - p2 for the dpolys p1 and p2.
    dp_sum(p1, dp_neg p2);

symbolic procedure dp_power(p,n);    
% Returns p^n for the dpoly p.
  if (not fixp n) or (n < 0) then typerr(n," exponent")
  else if n=0 then dp_fi 1 
  else if n=1 then p
  else if null cdr p then dp!=power1(p,n)
  else dp!=power(p,n);

symbolic procedure dp!=power1(p,n); % For monomials.
  list dp_term(bc_power(dp_lc p,n),mo_power(dp_lmon p,n));

symbolic procedure dp!=power(p,n);
  if n=1 then p
  else if evenp n then dp!=power(dp_prod(p,p),n/2)
  else dp_prod(p,dp!=power(dp_prod(p,p),n/2));

symbolic procedure dp_tcpart p;
% Return the homogeneous degree part of p of highest degree.
  if null p then nil
  else begin scalar d,u; d:=car mo_deg caar p;
  while p and (d=car mo_deg caar p) do
     << u:=car p . u; p:=cdr p >>;
  return reversip u;
  end;

symbolic procedure dp_deletecomp p;
% delete the component part from all terms.
  dp_neworder for each x in p collect mo_deletecomp car x . cdr x;

symbolic procedure dp_factor p;
  for each y in cdr ((fctrf numr simp dp_2a p) where !*factor=t)
            collect dp_from_a prepf car y;

% ------ Converting prefix forms into dpolys ------------------

symbolic procedure dp_from_a u;
% Converts the algebraic (prefix) form u into a dpoly.  
   if eqcar(u,'list) or eqcar(u,'mat) then typerr(u,"dpoly")
   else if atom u then dp!=a2dpatom u
   else if not atom car u or not idp car u 
                then typerr(car u,"dpoly operator")
   else (if x='dp!=fnpow then dp!=fnpow(dp_from_a cadr u,caddr u)
      else if x then 
            apply(x,list for each y in cdr u collect dp_from_a y)
      else dp!=a2dpatom u)
        where x = get(car u,'dp!=fn);

symbolic procedure dp!=a2dpatom u;
% Converts the atom (or kernel) u into a dpoly.
   if u=0 then nil
   else if numberp u or not member(u, ring_all_names cali!=basering)
                then list dp_term(bc_from_a u,mo_zero())
   else list dp_term(bc_fi 1,mo_from_a u);

symbolic procedure dp!=fnsum u;
% U is a list of dpoly expressions. The result is the dpoly 
% representation for the sum. Analogously for the other symbolic
% procedures below.
   (<<for each y in cdr u do x := dp_sum(x,y); x>>) where x = car u;

put('plus,'dp!=fn,'dp!=fnsum);

put('plus2,'dp!=fn,'dp!=fnsum);

symbolic procedure dp!=fnprod u;
   (<<for each y in cdr u do x := dp_prod(x,y); x>>) where x = car u;

put('times,'dp!=fn,'dp!=fnprod);

put('times2,'dp!=fn,'dp!=fnprod);

symbolic procedure dp!=fndif u; dp_diff(car u, cadr u);

put('difference,'dp!=fn,'dp!=fndif);

symbolic procedure dp!=fnpow(u,n); dp_power(u,n);

put('expt,'dp!=fn,'dp!=fnpow);

symbolic procedure dp!=fnneg u;
   ( if null v then v else dp_term(bc_neg dp_lc v,dp_lmon v) . cdr v)
        where v = car u;

put('minus,'dp!=fn,'dp!=fnneg);

symbolic procedure dp!=fnquot u;
   if null cadr u or not null cdadr u
         or not mo_zero!? dp_lmon cadr u
      then typerr(dp_2a cadr u,"distributive polynomial denominator")
    else dp!=fnquot1(car u,dp_lc cadr u);

symbolic procedure dp!=fnquot1(u,v);
   if null u then u
    else dp_term(bc_quot(dp_lc u,v), dp_lmon u) . 
            dp!=fnquot1(cdr u,v);

put('quotient,'dp!=fn,'dp!=fnquot);

% -------- Converting dpolys into prefix forms -------------
% ------ Authors: R. Gebauer, A. C. Hearn, H. Kredel -------

symbolic procedure dp_2a u;
% Returns the prefix equivalent of the dpoly u.
   if null u then 0 else dp!=replus dp!=2a u;

symbolic procedure dp!=2a u;
   if null u then nil
    else ((if bc_minus!? x then 
                        list('minus,dp!=retimes(bc_2a bc_neg x . y))
           else dp!=retimes(bc_2a x . y))
          where x = dp_lc u, y = mo_2a dp_lmon u)
                 . dp!=2a cdr u;

symbolic procedure dp!=replus u;
   if atom u then u else if null cdr u then car u else 'plus . u;

symbolic procedure dp!=retimes u;
% U is a list of prefix expressions the first of which is a number.
% The result is the prefix representation for their product.
   if car u = 1 then if cdr u then dp!=retimes cdr u else 1
    else if null cdr u then car u
    else 'times . u;

% ----------- Printing routines for dpolys --------------
% ---- Authors: R. Gebauer, A. C. Hearn, H. Kredel ------

symbolic procedure dp_print u;
% Prints a distributive polynomial in infix form.
   << terpri();  dp_print1(u,nil); terpri(); terpri() >>;

symbolic procedure dp_print1(u,v);
% Prints a dpoly in infix form.
% U is a distributive form. V is a flag which is true if a term
% has preceded current form.
   if null u then if null v then print_lf 0 else nil
    else begin scalar bool,w;
       w := dp_lc u;
       if bc_minus!? w then <<bool := t; w := bc_neg w>>;
       if bool then print_lf " - " else if v then print_lf " + ";
       ( if not bc_one!? w or mo_zero!? x then 
            << bc_prin w; mo_prin(x,t)>>
         else mo_prin(x,nil))
           where x = dp_lmon u;
       dp_print1(cdr u,t)
     end;

symbolic procedure dp_print2 u;
% Prints a dpoly with restricted number of terms.
  (if c and (length u>c) then
	begin scalar i,v,x; 
	v:=for i:=1:c collect <<x:=car u; u:=cdr u; x>>;
	dp_print1(v,nil); write" + # ",length u," terms #"; terpri();
	end
  else << dp_print1(u,nil); terpri() >>) 
	where c:=get('cali,'printterms);

% -------------- Auxiliary dpoly operations -------------------

symbolic procedure dp_ecart p; 
% Returns the ecart of the dpoly p.
   if null p then 0 else (dp!=ecart p) - (mo_ecart dp_lmon p);

symbolic procedure dp!=ecart p;
   if null p then 0 
   else max2(mo_ecart dp_lmon p,dp!=ecart cdr p);

symbolic procedure dp_homogenize(p,x);
% Homogenize (according to mo_ecart) the dpoly p using the variable x.
  if null p then p
  else begin integer maxdeg;
    maxdeg:=0;
    for each y in p do maxdeg:=max2(maxdeg,mo_ecart car y);
    return dp!=compact dp_neworder for each y in p collect 
                mo_inc(car y,x,maxdeg-mo_ecart car y) . cdr y;
    end;

symbolic procedure dp_seed(p,s);
% Returns the dpoly p with all vars outside the list s set equal to 1.
  if null p then p
  else dp!=compact dp_neworder 
                for each x in p collect mo_seed(car x,s).cdr x;

symbolic procedure dp!=compact p;
% Collect equal terms in the sorted dpoly p.
  if null p then p else dp_sum(list car p,dp!=compact cdr p);

symbolic procedure dp_xlt(p,x);
% x is the main variable. Returns the leading term of p wrt. x or p,
% if p is free of x. 
  if null p then p
  else begin scalar u,d,m;
    d:=mo_varexp(x,dp_lmon p);
    if d=0 then return p;
    return for each m in p join
	if mo_varexp(x,car m)=d then {mo_inc(car m,x,-d) . cdr m};
    end;

% -- dpoly operations based on computation with ideal bases.

symbolic procedure dp_pseudodivmod(g,f);
% Returns a dpoly list {q,r,z} such that z * g = q * f + r and
% z is a dpoly unit. Computes redpol({[f.e_1]},[g.0]).
% g, f and r must belong to the same free module.
   begin scalar u;
   f:=list bas_make1(1,f,dp_from_ei 1);
   g:=bas_make(0,g);
   u:=red_redpol(f,g);
   return {dp_neg dp_deletecomp bas_rep car u,bas_dpoly car u,cdr u};
   end;

symbolic operator dpgcd;
symbolic procedure dpgcd(u,v);
  if !*mode='algebraic then dp_2a dpgcd!*(dp_from_a u,dp_from_a v)
  else dpgcd!*(u,v);

symbolic procedure dpgcd!*(u,v);
% Compute the gcd of two polynomials by the syzygy method :
% 0 = u*u1 + v*v1 => gcd = u/v1 = -v/u1 .
  if dp_unit!? u or dp_unit!? v then dp_fi 1
  else begin scalar g,w;
    w:=bas_dpoly first dpmat_list 
        syzygies!* dpmat_make(2,0,{bas_make(1,u),bas_make(2,v)},nil,nil);
    return car dp_pseudodivmod(u,dp_comp(2,w));
    end;

endmodule; % dpoly


module bas; 

COMMENT

              #######################
              ####               ####
              ####  IDEAL BASES  #### 
              ####               ####
              #######################


Ideal bases are lists of vector polynomials (with additional
information), constituting the rows of a dpmat (see below).  In a
rep. part there can be stored vectors representing each base element
according to a fixed basis. Usually rep=nil.

Informal syntax :

 <bas>          ::= list of base elements
 <base element> ::= list(nr dpoly length ecart rep)

END COMMENT;


% -------- Reference operators for the base element b ---------

symbolic procedure bas_dpoly b; cadr b;
symbolic procedure bas_dplen b; caddr b;
symbolic procedure bas_nr b; car b;
symbolic procedure bas_dpecart b; cadddr b;
symbolic procedure bas_rep b; nth(b,5);

% ----- Elementary constructors for the base element be --------

symbolic procedure bas_newnumber(nr,be); 
% Returns be with new number part.
   nr . cdr be;

symbolic procedure bas_make(nr,pol); 
% Make base element with rep=nil.
   list(nr,pol, length pol,dp_ecart pol,nil);

symbolic procedure bas_make1(nr,pol,rep); 
% Make base element with prescribed rep.
   list(nr,pol, length pol,dp_ecart pol,rep);

symbolic procedure bas_getelement(i,bas); 
% Returns the base element with number i from bas (or nil).
  if null bas then list(i,nil,0,0,nil)
  else if eqn(i,bas_nr car bas) then car bas
  else bas_getelement(i,cdr bas);
  
% ---------- Operations on base lists ---------------

symbolic procedure bas_sort b; 
% Sort the base list b.
  sort(b,function red_better);

symbolic procedure bas_print u;
% Prints a list of distributive polynomials using dp_print.
  begin terpri();   
     if null u then print 'empty
     else for each v in u do 
            << write bas_nr v, " -->  "; dp_print2 bas_dpoly v >>
  end;

symbolic procedure bas_renumber u; 
% Renumber base list u.
  if null u then nil
  else begin scalar i; i:=0;
      return for each x in u collect <<i:=i+1; bas_newnumber(i,x) >>
  end;

symbolic procedure bas_setrelations u;
% Set in the base list u the relation part rep of base element nr. i
% to e_i (provided i>0).
  for each x in u do 
        if bas_nr x > 0 then rplaca(cddddr x, dp_from_ei bas_nr x);

symbolic procedure bas_removerelations u;
% Remove relation parts.
  for each x in u do rplaca(cddddr x, nil);

symbolic procedure bas_getrelations u;
% Returns the relations of the base list u as a separate base list.
  begin scalar w;
  for each x in u do w:=bas_make(bas_nr x,bas_rep x) . w;
  return reversip w;
  end;

symbolic procedure bas_from_a u;
% Converts the algebraic (prefix) form u to a base list clearing
% denominators. Only for lists.
   bas_renumber for each v in cdr u collect 
        bas_make(0,dp_from_a prepf numr simp v);
   
symbolic procedure bas_2a u;
% Converts the base list u to its algebraic prefix form.
    append('(list),for each x in u collect dp_2a bas_dpoly x);          
          
symbolic procedure bas_neworder u;
% Returns reordered base list u (e.g. after change of term order).
    for each x in u collect 
        bas_make1(bas_nr x,dp_neworder bas_dpoly x,
                                dp_neworder bas_rep x);
    
symbolic procedure bas_zerodelete u;
% Returns base list u with zero elements deleted but not renumbered. 
    if null u then nil
    else if null bas_dpoly car u then bas_zerodelete cdr u
    else car u.bas_zerodelete cdr u;

symbolic procedure bas_simpelement b;
% Returns (b_new . z) with 
%       bas_dpoly b_new having leading coefficient 1 or
%       gcd(dp_content bas_poly,dp_content bas_rep) canceled out 
% and dpoly_old = z * dpoly_new , rep_old= z * rep_new.

  if null bas_dpoly b then b . bc_fi 1
  else begin scalar z,z1,pol,rep; 
    if (z:=bc_inv (z1:=dp_lc bas_dpoly b)) then
        return bas_make1(bas_nr b,
                dp_times_bc(z,bas_dpoly b),
                dp_times_bc(z,bas_rep b)) 
                        . z1;

    % -- now we assume that base coefficients are a gcd domain ----    

    z:=bc_gcd(dp_content bas_dpoly b,dp_content bas_rep b);
    if bc_minus!? z1 then z:=bc_neg z;
    pol:=for each x in bas_dpoly b collect 
                car x . car bc_divmod(cdr x,z);
    rep:=for each x in bas_rep b collect 
                car x . car bc_divmod(cdr x,z);
    return bas_make1(bas_nr b,pol,rep) . z;
    end;
   
symbolic procedure bas_simp u;
% Applies bas_simpelement to each dpoly in the base list u.
   for each x in u collect car bas_simpelement x;

symbolic procedure bas_zero!? b; 
% Test whether all base elements are zero.
   null b or (null bas_dpoly car b and bas_zero!? cdr b);
   
symbolic procedure bas_sieve(bas,vars);
% Sieve out all base elements from the base list bas with leading
% term containing a variable from the list of var. names vars and
% renumber the result.
   begin scalar u,m;  m:=mo_zero(); 
   for each x in vars do
       if member(x,ring_names cali!=basering) then 
            m:=mo_sum(m,mo_from_a x)
       else typerr(x,"variable name");
   return bas_renumber for each x in bas_zerodelete bas join 
        if mo_zero!? mo_gcd(m,dp_lmon bas_dpoly x) then {x};
   end;

symbolic procedure bas_homogenize(b,var);
% Homogenize the base list b using the var. name var.
% Note that the rep. part is correct only upto a power of var !
  for each x in b collect 
      bas_make1(bas_nr x,dp_homogenize(bas_dpoly x,var),
                dp_homogenize(bas_rep x,var));

symbolic procedure bas_dehomogenize(b,var);
% Set the var. name var in the base list b equal to one.
  begin scalar u,v;
  if not member(var,v:=ring_all_names cali!=basering) then
    typerr(var,"dpoly variable");
  u:=setdiff(v,list var); 
  return for each x in b collect         
                bas_make1(bas_nr x,dp_seed(bas_dpoly x,u),
                            dp_seed(bas_rep x,u));
  end;
 
% ---------------- Special tools for local algebra -----------

symbolic procedure bas!=factorunits p;
  if null p then nil
    else bas!=delprod
        for each y in cdr (fctrf numr simp dp_2a p where !*factor=t)
            collect (dp_from_a prepf car y . cdr y);

symbolic procedure bas!=delprod u;
  begin scalar p; p:=dp_fi 1;
     for each x in u do
        if not dp_unit!? car x then p:=dp_prod(p,dp_power(car x,cdr x));
     return p
  end;

symbolic procedure bas!=detectunits p;
  if null p then nil
  else if listtest(cdr p,dp_lmon p,
        function(lambda(x,y);not mo_vdivides!?(y,car x))) then p
  else list dp_term(bc_fi 1,dp_lmon p);

symbolic procedure bas_factorunits b;
  bas_make(bas_nr b,bas!=factorunits bas_dpoly b);

symbolic procedure bas_detectunits b;
  bas_make(bas_nr b,bas!=detectunits bas_dpoly b);

 
endmodule;  % bas  

module dpmat;  

COMMENT

                 #####################
                 ###               ###
                 ###    MATRICES   ###
                 ###               ###
                 #####################

This module introduces special dpoly matrices with its own matrix
syntax.

Informal syntax : 
 
 <matrix> ::= list('DPMAT,#rows,#cols,baslist,column_degrees,gb-tag)

Dpmat's are the central data structure exploited in the modules of
this package. Each such matrix describes a map

                   f : R^rows --> R^cols,

that gives rise for the definition of two modules,

                im f = the submodule of R^cols generated by the rows
                       of the matrix

        and  coker f = R^cols/im f.

Conceptually dpmat's are identified with im f.

END COMMENT;

% ------------- Reference operators ----------------
 
symbolic procedure dpmat_rows m; cadr m;
symbolic procedure dpmat_cols m; caddr m;
symbolic procedure dpmat_list m; cadddr m;
symbolic procedure dpmat_coldegs m; nth(m,5);
symbolic procedure dpmat_gbtag m; nth(m,6);

% ------------- Elementary operations --------------

symbolic procedure dpmat_rowdegrees m;
% Returns the row degrees of the dpmat m as an assoc. list.
  (for each x in dpmat_list m join
        if bas_nr x > 0 then 
                {(bas_nr x).(mo_getdegree(dp_lmon bas_dpoly x,l))})
  where l=dpmat_coldegs m;

symbolic procedure dpmat_make(r,c,bas,degs,gbtag); 
  list('dpmat,r,c,bas,degs,gbtag);

symbolic procedure dpmat_element(r,c,mmat);
% Returns mmat[r,c].
   dp_neworder 
        dp_comp(c, bas_dpoly bas_getelement(r,dpmat_list mmat));

symbolic procedure dpmat_print m; mathprint dpmat_2a m;

symbolic procedure getleadterms!* m;
% Returns the dpmat with the leading terms of m.
  (begin scalar b;
  b:=for each x in dpmat_list m collect
    bas_make(bas_nr x,list(car bas_dpoly x));
  return dpmat_make(dpmat_rows m,dpmat_cols m,b,cali!=degrees,t);
  end) where cali!=degrees:=dpmat_coldegs m;

% -------- Symbolic mode file transfer --------------

symbolic procedure savemat!*(m,name);
% Save the dpmat m under the name <name>.
  begin scalar nat,c;
  if not (stringp name or idp name) then typerr(name,"file name");
  if not eqcar(m,'dpmat) then typerr(m,"dpmat");
  nat:=!*nat; !*nat:=nil; 
  write"Saving as ",name;
  out name$  
  write"algebraic(setring "$
  
  % mathprint prints lists without terminator, but matrices with
  % terminator. 
  
  mathprint ring_2a cali!=basering$ write")$"$ 
  write"algebraic(<<basis :="$ dpmat_print m$ 
  if dpmat_cols m=0 then write"$"$ write">>)$"$
  if (c:=dpmat_coldegs m) then
    << write"algebraic(degrees:="$ 
    mathprint moid_2a for each x in c collect cdr x$ write")$"$ 
    >>;   
  write"end$"$ terpri()$
  shut name; terpri(); !*nat:=nat;
  end;

symbolic procedure initmat!* name;
% Initialize a dpmat from <name>.
  if not (stringp name or idp name) then typerr(name,"file name")
  else begin scalar m,c,d; integer i; 
     write"Initializing ",name; terpri(); 
     in name$ m:=reval 'basis; cali!=degrees:=nil;
     if eqcar(m,'list) then 
        << m:=bas_from_a m; m:=dpmat_make(length m,0,m,nil,nil)>>
     else if eqcar(m,'mat) then 
        << c:=moid_from_a reval 'degrees; i:=0;
           cali!=degrees:=for each x in c collect <<i:=i+1; i . x >>;
           m:=dpmat_from_a m;
        >>   
     else typerr(m,"basis or matrix");
     dpmat_print m;
     return m;
     end;

% ---- Algebraic mode file transfer ---------

symbolic operator savemat;
symbolic procedure savemat(m,name);  
  if !*mode='algebraic then savemat!*(dpmat_from_a m,name)
  else savemat!*(m,name);
  
symbolic operator initmat; 
symbolic procedure initmat name; 
  if !*mode='algebraic then dpmat_2a initmat!* name
  else initmat!* name;

% --------------- Arithmetics for dpmat's ----------------------

symbolic procedure dpmat!=dpsubst(a,b);
% Substitute in the dpoly a each e_i by b_i from the base list b.
   begin scalar v;
   for each x in b do 
        v:=dp_sum(v,dp_prod(dp_comp(bas_nr x,a),bas_dpoly x));
   return v;
   end;

symbolic procedure dpmat_mult(a,b); 
% Returns a * b.
  if not eqn(dpmat_cols a,dpmat_rows b) then 
        rerror('dpmat,1," matrices don't match for MATMULT")
  else dpmat_make( dpmat_rows a, dpmat_cols b, 
        for each x in dpmat_list a collect 
                bas_make(bas_nr x, 
                        dpmat!=dpsubst(bas_dpoly x,dpmat_list b)),
        cali!=degrees,nil) 
        where cali!=degrees:=dpmat_coldegs b;

symbolic procedure dpmat_times_dpoly(f,m);
% Returns f * m for the dpoly f and the dpmat m.
   dpmat_make(dpmat_rows m,dpmat_cols m,
        for each x in dpmat_list m collect
            bas_make1(bas_nr x, dp_prod(f,bas_dpoly x),
                        dp_prod(f,bas_rep x)),
        cali!=degrees,nil) where cali!=degrees:=dpmat_coldegs m;

symbolic procedure dpmat_neg a; 
% Returns - a.
   dpmat_make(
        dpmat_rows a,      
        dpmat_cols a,
        for each x in dpmat_list a collect 
            bas_make1(bas_nr x,dp_neg bas_dpoly x, dp_neg bas_rep x),
        cali!=degrees,dpmat_gbtag a) 
        where cali!=degrees:=dpmat_coldegs a;

symbolic procedure dpmat_diff(a,b); 
% Returns a - b.
  dpmat_sum(a,dpmat_neg b); 

symbolic procedure dpmat_sum(a,b); 
% Returns a + b.
  if not (eqn(dpmat_rows a,dpmat_rows b) 
                and eqn(dpmat_cols a, dpmat_cols b)
                and equal(dpmat_coldegs a,dpmat_coldegs b)) then
        rerror('dpmat,2,"matrices don't match for MATSUM")
  else (begin scalar u,v,w; 
        u:=dpmat_list a; v:=dpmat_list b;
        w:=for i:=1:dpmat_rows a collect
            (bas_make1(i,dp_sum(bas_dpoly x,bas_dpoly y),
                            dp_sum(bas_rep x,bas_rep y))
                        where y= bas_getelement(i,v), 
                              x= bas_getelement(i,u));
        return dpmat_make(dpmat_rows a,dpmat_cols a,w,cali!=degrees,nil);
        end) where cali!=degrees:=dpmat_coldegs a;

symbolic procedure dpmat_from_dpoly p;  
  if null p then dpmat_make(0,0,nil,nil,t)
  else dpmat_make(1,0,list bas_make(1,p),nil,t);

symbolic procedure dpmat_unit(n,degs);
% Returns the unit dpmat of size n.
  dpmat_make(n,n, for i:=1:n collect bas_make(i,dp_from_ei i),degs,t);

symbolic procedure dpmat_unitideal!? m;
  (dpmat_cols m = 0) and null matop_pseudomod(dp_fi 1,m);

symbolic procedure dpmat_transpose m; 
% Returns transposed m with consistent column degrees.
  if (dpmat_cols m = 0) then dpmat!=transpose ideal2mat!* m
  else dpmat!=transpose m;
  
symbolic procedure dpmat!=transpose m;
  (begin scalar b,p,q; 
     cali!=degrees:=
        for each x in dpmat_rowdegrees m collect 
                (car x).(mo_neg cdr x);
     for i:=1:dpmat_cols m do
       << p:=nil; 
          for j:=1:dpmat_rows m do
            << q:=dpmat_element(j,i,m);
               if q then p:=dp_sum(p,dp_times_ei(j,q))
            >>;
          if p then b:=bas_make(i,p) . b;
       >>;
   return dpmat_make(dpmat_cols m,dpmat_rows m,reverse b, 
                        cali!=degrees,nil);
   end) where cali!=degrees:=cali!=degrees;
     
symbolic procedure ideal2mat!* u; 
% Returns u as column vector if dpmat_cols u = 0.
  if dpmat_cols u neq 0 then 
            rerror('dpmat,4,"IDEAL2MAT only for ideal bases")
  else dpmat_make(dpmat_rows u,1,
                 for each x in dpmat_list u collect
                   bas_make(bas_nr x,dp_times_ei(1,bas_dpoly x)),
                nil,dpmat_gbtag u) where cali!=degrees:=nil; 

symbolic procedure dpmat_renumber old; 
% Renumber dpmat_list old. 
% Returns (new . change) with new = change * old.
  if null dpmat_list old then (old . dpmat_unit(dpmat_rows old,nil))
  else (begin scalar i,u,v,w; 
      cali!=degrees:=dpmat_rowdegrees old;
      i:=0; u:=dpmat_list old;
      while u do 
        <<i:=i+1; v:=bas_newnumber(i,car u) . v; 
        w:=bas_make(i,dp_from_ei bas_nr car u) . w  ; u:=cdr u>>;
      return dpmat_make(i,dpmat_cols old, 
                        reverse v,dpmat_coldegs old,dpmat_gbtag old) . 
             dpmat_make(i,dpmat_rows old,reverse w,cali!=degrees,t);
      end) where cali!=degrees:=cali!=degrees;

symbolic procedure mathomogenize!*(m,var); 
% Returns m with homogenized rows using the var. name var.
  dpmat_make(dpmat_rows m, dpmat_cols m, 
        bas_homogenize(dpmat_list m,var), cali!=degrees,nil)
  where cali!=degrees:=dpmat_coldegs m;

symbolic operator mathomogenize;
symbolic procedure mathomogenize(m,v);
% Returns the homogenized matrix of m with respect to the variable v.
  if !*mode='algebraic then
        dpmat_2a mathomogenize!*(dpmat_from_a reval m,v)
  else matdehomogenize!*(m,v); 

symbolic procedure matdehomogenize!*(m,var); 
% Returns m with var. name var set equal to one.
  dpmat_make(dpmat_rows m, dpmat_cols m,
        bas_dehomogenize(dpmat_list m,var), cali!=degrees,nil)
  where cali!=degrees:=dpmat_coldegs m;

symbolic procedure dpmat_sieve(m,vars,gbtag);
% Apply bas_sieve to dpmat_list m. The gbtag slot allows to set the
% gbtag of the result.
  dpmat_make(length x,dpmat_cols m,x,cali!=degrees,gbtag) 
        where x=bas_sieve(dpmat_list m,vars)
  where cali!=degrees:=dpmat_coldegs m;

symbolic procedure dpmat_neworder(m,gbtag);
% Apply bas_neworder to dpmat_list m with current cali!=degrees.
% The gbtag sets the gbtag part of the result.
   dpmat_make(dpmat_rows m,dpmat_cols m,
        bas_neworder dpmat_list m,cali!=degrees,gbtag);

symbolic procedure dpmat_zero!? m; 
% Test whether m is a zero dpmat.
   bas_zero!? dpmat_list m;

symbolic procedure dpmat_project(m,k);
% Project the dpmat m onto its first k components.
  dpmat_make(dpmat_rows m,k,
        for each x in dpmat_list m collect
                bas_make(bas_nr x,dp_project(bas_dpoly x,k)),
        dpmat_coldegs m,nil);        
  
% ---------- Interface to algebraic mode

symbolic procedure dpmat_2a m; 
% Convert the dpmat m to a matrix (c>0) or a polynomial list (c=0) in
% algebraic (pseudo)prefix form.
  if dpmat_cols m=0 then bas_2a dpmat_list m
  else   'mat .
        if dpmat_rows m=0 then list for j:=1:dpmat_cols m collect 0
        else  for i:=1:dpmat_rows m collect 
                for j:=1:dpmat_cols m collect
                    dp_2a dpmat_element(i,j,m);

symbolic procedure dpmat_from_a m; 
% Convert an algebraic polynomial list or matrix expression into a
% dpmat with respect to the current setting of cali!=degrees.
  if eqcar(m,'mat) then
    begin integer i; scalar u,p; m:=cdr m; 
    for each x in m do
      << i:=1; p:=nil;
         for each y in x do 
           << p:=dp_sum(p,dp_times_ei(i,dp_from_a reval y)); i:=i+1 >>;
         u:=bas_make(0,p).u
      >>;
    return dpmat_make(length m,length car m,
                bas_renumber reversip u, cali!=degrees,nil);
    end
  else if eqcar(m,'list) then
    ((begin scalar x;  x:=bas_from_a reval m;
    return dpmat_make(length x,0,x,nil,nil)
    end) where cali!=degrees:=nil)
  else typerr(m,"polynomial list or matrix");

% ---- Substitution in dpmats --------------

symbolic procedure dpmat_sub(a,m);
% a=list of (var . alg. prefix form) to be substituted into the dpmat
% m. 
   dpmat_from_a subeval1(a,dpmat_2a m)
  where cali!=degrees:=dpmat_coldegs m;
  
% ------------- Determinant ------------------------

symbolic procedure dpmat_det m;
% Returns the determinant of the dpmat m.
  if dpmat_rows m neq dpmat_cols m then rederr "non-square matrix"
  else dp_from_a prepf numr detq matsm dpmat_2a m;    

endmodule; % dpmat

module red; 

COMMENT

                    #################    
                    ##             ##   
                    ## NORMAL FORM ##
                    ## ALGORITHMS  ##
                    ##             ##
                    #################

This module contains normal form algorithms for base elements. All
reductions executed on the dpoly part, are repeated on the rep part,
hence tracing them up for further use. We do pseudoreduction, but 
organized following up the multipliers in a different way than in the
version 2.1 :

For total reduction we hide terms prefixing the current lead term on the
negative slots of the rep part. This allows not to follow up the 
multipliers, since head terms are multiplied automatically.

If You nevertheless need the multipliers, You can prepare the base elements
with "red_prepare" to keep track of them using the 0-slot of the rep-part :

	f --> (f,e_0) -NF-> (f',z*e_0) --> (f' . z)

Extract the multiplier back with "red_extract". This allows a unified
treating of the multipliers for both noetherian and non noetherian
term orders. 

For     NF : [f,r] |--> [f',r']         using B={[f_i,r_i]} 
with representation parts r, r_i we get

		f' = z*f + \sum a_i*f_i
                r' = z*r + \sum a_i*r_i

The output trace intensity can be managed with cali_trace() that has
the following meaning : 

       cali_trace() >=  0      no trace
                       10      '.' for each substitution
                       70      trace interreduce!*
                       80      trace redpol
                       90      show substituents

The reduction strategy is first matching in the simplifier (base)
list. It can be changed overloading red_better, the relation
according to what base lists are sorted. Standard is minimal ecart,
breaking ties with minimal length (since such a strategy is good for
both the classical and the local case). 

There are two (head) reduction functions, the usual one and one, that
allows reduction only by reducers with bounded ecart, i.e. where the
ecart of the reducer is leq the ecart of the poly to be reduced. This
allows a unified handling of noetherian and non-noetherian term orders.

Switches :

          red_total :   t      compute total normal forms
                        nil    reduce only until lt is standard 
          bcsimp    :   t      apply bas_simp 


END COMMENT;

% Standard is :

!*red_total:=t;
!*bcsimp:=t;

symbolic procedure red_better(a,b);
% Base list sort criterion. Simplifier lists are sorted such that the
% best substituent comes first. Due to reduction with bounded ecart we
% need no more lowest ecarts first.
  bas_dplen a < bas_dplen b;

% ---- Preparing data for collecting multipliers  ---

symbolic procedure red_prepare model;
% Prepare the zero rep-part to follow up multipliers 
% in the pseudoreductions.
%	  if !*binomial then model else 
  bas_make1(bas_nr model,bas_dpoly model, 
                dp_sum(bas_rep model,dp_from_ei 0));

symbolic procedure red_extract model;
% Returns (model . dpoly), extracting the multiplier part from the 
% zero rep-part.
%    if !*binomial then (model . dp_fi 1) else 
  (bas_make1(bas_nr model, bas_dpoly model,
                dp_diff(bas_rep model,z)) . z
     where z=dp_comp(0,bas_rep model));

% -------- Substitution operations ----------------

symbolic procedure red_subst(model,basel);
%  model and basel = base elements
%  Returns a base element, such that
%       pol_new := z * pol_old - z1 * mo * f_a
%       rep_new := z * rep_old - z1 * mo * rep_a
% with appropriate base coeff. z and z1 and monomial mo.

%  if !*binomial then red!=subst2(model,basel) else 
  red!=subst1(model,basel);

symbolic procedure red!=subst1(model,basel);
    begin scalar polold,polnew,repold,repnew,gcd,mo,fa,z,z1; 
        polold:=bas_dpoly model; z1:=dp_lc polold;
        repold:=bas_rep model;
        fa:=bas_dpoly basel; z:= dp_lc fa;
        if !*bcsimp then      % modify z and z1
          if (gcd:=bc_inv z) then
            << z1:=bc_prod(z1,gcd); z:=bc_fi 1 >>
          else  
            << gcd:=bc_gcd(z,z1);
               z:=car bc_divmod(z,gcd); 
               z1:=car bc_divmod(z1,gcd)
            >>;
        mo:=mo_diff(dp_lmon polold,dp_lmon fa);
        polnew:=dp_diff(dp_times_bc(z,polold),
                                dp_times_bcmo(z1,mo,fa));
        repnew:=dp_diff(dp_times_bc(z,repold),
                                dp_times_bcmo(z1,mo,bas_rep basel));
        if cali_trace() > 79 then 
                << prin2 "---> "; dp_print polnew >>
        else if cali_trace() > 0 then prin2 ".";
        if cali_trace() > 89 then
                << prin2 " uses "; dp_print fa >>;
        return bas_make1(bas_nr model,polnew,repnew);
    end;
  
symbolic procedure red!=subst2(model,basel);
% Only for binomials without representation parts.
    begin scalar m,b,u,r;
    if cali_trace()>0 then prin2 ".";
    m:=bas_dpoly model; b:=bas_dpoly basel;
    if (length b neq 2) or bas_rep model then 
            rederr"switch off binomial";
    u:=mo_qrem(dp_lmon m,dp_lmon b);
    r:=list dp_term(dp_lc m, 
                mo_sum(mo_power(dp_lmon cdr b,car u),cdr u));
    return bas_make(bas_nr model,dp_sum(r,cdr m));
    end;

% ---------------- Top reduction ------------------------

symbolic procedure red_TopRedBE(bas,model);
% Takes a base element model and returns it top reduced with bounded ecart.
  if (null bas_dpoly model) or (null bas) then model
  else begin 
     scalar v,q; 
     if cali_trace()>79 then 
       << write" reduce "; dp_print bas_dpoly model >>; 
     while (q:=bas_dpoly model) and 
                (v:=red_divtestBE(bas,dp_lmon q,bas_dpecart model)) do
                        model:=red_subst(model,v);
     return model;
     end;    
                          
symbolic procedure red_divtestBE(a,b,e);
% Returns the first f in the base list a, such that lt(f) | b 
% and ec(f)<=e, else nil. b is a monomial.
  if null a then nil
  else if (bas_dpecart(car a) <= e) and
        mo_vdivides!?(dp_lmon bas_dpoly car a,b) then car a
  else red_divtestBE(cdr a,b,e);

symbolic procedure red_divtest(a,b);
% Returns the first f in the base list a, such that lt(f) | b else nil.
% b is a monomial.
  if null a then nil
  else if mo_vdivides!?(dp_lmon bas_dpoly car a,b) then car a
  else red_divtest(cdr a,b);

symbolic procedure red_TopRed(bas,model);
% Takes a base element model and returns it top reduced.
% For noetherian term orders this is the classical top reduction; no
% additional simplifiers occur. For local term orders it is Mora's
% reduction by minimal ecart.
  if (null bas_dpoly model) or (null bas) then model
  else begin
     scalar v,q;
        % Make first reduction with bounded ecart.
     model:=red_TopRedBE(bas,model); 
        % Now loop into reduction with minimal ecart.
     while (q:=bas_dpoly model) and (v:=red_divtest(bas,dp_lmon q)) do
         << v:=red_subst(model,v); 
            if not !*noetherian then bas:=red_update(bas,model);
            model:=red_TopRedBE(bas,v);
         >>;
     return model;
     end;

% Management of the simplifier list. Has a meaning only in the 
% non noetherian case.

symbolic procedure red_update(simp,b);
% Update the simplifier list simp with the base element b.
    begin 
    if cali_trace()>59 then
      << terpri(); write "[ec:",bas_dpecart b,"] ->"; 
         dp_print2 bas_dpoly b
      >>
    else if cali_trace()>0 then write"*";
    return merge(list b,
                for each x in simp join
                        if red!=cancelsimp(b,x) then nil else {x},
                function red_better);
    end;

symbolic procedure red!=cancelsimp(a,b);
% Test for updating the simplifier list.
  red_better(a,b) and
        mo_vdivides!?(dp_lmon bas_dpoly a,dp_lmon bas_dpoly b);

% ------------- Total reduction and Tail reduction -----------

Comment 

For total reduction one has to organize recursive calls of TopRed on
tails of the current model. Since we do pseudoreduction, we have to
multiply the prefix terms with the multiplier during recursive calls.
We do that, hiding the prefix terms on rep part components with
negative component number. Retrival may be done not recursively, but
in a single step.

end comment;

symbolic procedure red!=hide p; 
% Hide the terms of the dpoly p. This is involutive !
  for each x in p collect (mo_times_ei(-1,mo_neg car x) . cdr x);

symbolic procedure red!=hideLt model;
  bas_make1(bas_nr model,cdr p,
        dp_sum(bas_rep model, red!=hide({car p})))
  where p=bas_dpoly model;

symbolic procedure red!=recover model;
% The dpoly part of model is empty, but the rep part contains
% hidden terms.
   begin scalar u,v;
     for each x in bas_rep model do
        if mo_comp car x < 0 then u:=x.u else v:=x.v;
     return bas_make1(bas_nr model, dp_neworder reversip red!=hide u,
                reversip v);
   end;

symbolic procedure red_TailRedDriver(bas,model,redfctn);
% Takes a base element model and reduces the tail with the
% top reduce "redfctn" recursively.
  if (null bas_dpoly model) or (null cdr bas_dpoly model) 
                or (null bas) then model 
  else begin
     while bas_dpoly model do
        model:=apply2(redfctn,bas,red!=hideLt(model));
     return red!=recover(model);
     end;

symbolic procedure red_TailRed(bas,model);
% The tail reduction as we understand it at the moment.
  if !*noetherian then
        red_TailRedDriver(bas,model,function red_TopRed)
  else red_TailRedDriver(bas,model,function red_TopRedBE);

symbolic procedure red_TotalRed(bas,model);
% Make a terminating total reduction, i.e. for noetherian term orders
% the classical one and for local term orders tail reduction with
% bounded ecart.
  red_TailRed(bas,red_TopRed(bas,model));
 
% ---------- Reduction of the straightening parts --------

symbolic procedure red_Straight(bas);
% Autoreduce straightening formulae of the base list bas, classical
% in the noetherian case and with bounded ecart in the local case. 
  begin scalar u;
  u:=for each x in bas collect red_TailRed(bas,x);
  if !*bcsimp then u:=bas_simp u;
  return sort(u,function red_better);
  end;
  
symbolic procedure red_collect bas;
% Returns ( bas1 . bas2 ), where bas2 may be reduced with bas1.
    begin scalar bas1,bas2;
    bas1:=listminimize(bas,function (lambda(x,y);
         mo_vdivides!?(dp_lmon bas_dpoly x,dp_lmon bas_dpoly y)));
    bas2:=setdiff(bas,bas1);
    return bas1 . bas2;
    end;

symbolic procedure red_TopInterreduce m;
% Reduce rows of the base list m with red_TopRed until it has pairwise
% incomparable leading terms  
% Compute correct representation parts. Do no tail reduction.

    begin scalar c,w,bas1,pol,rep;
    m:=bas_sort bas_zerodelete m;
    if !*bcsimp then m:=bas_simp m;
    while cdr (c:=red_collect m) do
      << if cali_trace()>69 then
                <<write" interreduce ";terpri();bas_print m>>;
         m:=nil; w:=cdr c; bas1:=car c;
         while w do
           << c:=red_TopRed(bas1,car w);
              if bas_dpoly c then m:=c . m;
              w:=cdr w
            >>;
         if !*bcsimp then m:=bas_simp m;
         m:=merge(bas1,bas_sort m,function red_better);
      >>;
    return m;
    end;

% ----- Interface to the former syntax --------------

symbolic procedure red_redpol(bas,model);
% Returns (reduced model . multiplier)
  begin scalar m;
  m:=red_prepare model;
  return red_extract 
    (if !*red_total then red_TotalRed(bas,m) else red_TopRed(bas,m))
  end;

symbolic procedure red_Interreduce m; 
% Applies to arbitrary term orders.
   begin 
	% Top reduction, producing pairwise incomparable leading terms.
   m:=red_TopInterreduce m; 
   if !*red_total then m:=red_Straight m; % Tail reduction :
   return m;
   end;

endmodule;  % red

module groeb; 

COMMENT

              ##############################
              ##                          ##
              ##      GROEBNER PACKAGE    ##
              ##                          ##
              ##############################

This is now a common package, covering both the noetherian and the
local term orders.

The trace intensity can be managed with cali_trace() by the following
rules :
        
      cali_trace() >=   0      no trace 
                        2      show actual step
                       10      show input and output
                       20      show new base elements
                       30      show pairs
                       40      show actual pairlist
                       50      show S-polynomials

Pair lists have the following informal syntax :

      <spairlist>::= list of spairs 
      < spair >  ::= (komp  groeb!=weight  lcm  p_i  p_j)
               with lcm = lcm(lt(bas_dpoly p_i),lt(bas_dpoly p_j)).


The pair selection strategy is by first matching in the pair list.
It can be changed overloading groeb!=better, the relation according to
what pair lists are sorted. Standard is the sugar strategy.

cali!=monset :

One can manage a list of variables, that are allowed to be canceled
out, if they appear as common factors in a dpoly. This is possible if
these variables are non zero divisors (e.g. for prime ideals) and
affects "pure" Groebner basis computation only.

END COMMENT;


% ############   The outer Groebner engine   #################

put('cali,'groeb!=rf,'groeb!=rf1); % First initialization.

symbolic operator gbtestversion;
symbolic procedure gbtestversion n; % Choose the corresponding driver 
  if member(n,{1,2,3}) then 
	put('cali,'groeb!=rf,mkid('groeb!=rf,n));

symbolic procedure groeb!=postprocess pol;
% Postprocessing for irreducible H-Polynomials. The switches got
% appropriate local values in the Groebner engine. 
  begin  
  if !*bcsimp then pol:=car bas_simpelement pol;
  if not !*noetherian then 
        if !*factorunits then pol:=bas_factorunits pol
        else if !*detectunits then pol:=bas_detectunits pol;
  if cali!=monset then pol:=bas_make(bas_nr pol,
                      car dp_mondelete(bas_dpoly pol,cali!=monset));
  return pol 
  end;

symbolic procedure groeb_stbasis(bas,comp_mgb,comp_ch,comp_syz);
  groeb!=choose_driver(bas,comp_mgb,comp_ch,comp_syz,
				function groeb!=generaldriver);

symbolic procedure 
	groeb!=choose_driver(bas,comp_mgb,comp_ch,comp_syz,driver);
% Returns { mgb , change , syz } with
%       dpmat mgb = (if comp_mgb=true the minimal) 
%               Groebner basis of the dpmat bas.
%       dpmat change defined by   mgb = change * bas
%               if comp_ch = true.
%       dpmat syz = (not interreduced) syzygy matrix of the dpmat bas
%               if comp_syz = true.
% Changes locally !*factorunits, !*detectunits and cali!=monset.

   if dpmat_zero!? bas then 
       {bas,dpmat_unit(dpmat_rows bas,nil),
            dpmat_unit(dpmat_rows bas,nil)}
   else (begin scalar u, gb, syz, change, syz1; 
   
        % ------- Syzygies for the zero base elements.
   if comp_syz then 
   << u:=setdiff(for i:=1:dpmat_rows bas collect i, 
                for each x in dpmat_list bas collect bas_nr x);
      syz1:=for each x in u collect bas_make(0,dp_from_ei x);
   >>;
   
        % ------- Initialize the Groebner computation.
   gb:=append(dpmat_list bas,nil); % make a copy of the base list.
   if comp_ch or comp_syz then 
   << !*factorunits:=!*detectunits:=cali!=monset:=nil;
      bas_setrelations gb;
   >>;
   if cali_trace() > 5 then 
      << terpri(); write" Compute GBasis of"; bas_print gb >>
   else if cali_trace() > 0 then 
      << terpri(); write" Computing GBasis  ";terpri() >>;
   u:=apply(driver,{dpmat_rows bas,dpmat_cols bas,gb,comp_syz}); 
   syz:=second u; 
   if comp_mgb then 
        << u:=groeb_mingb car u;  
           if !*red_total then 
                u:=dpmat_make(dpmat_rows u,dpmat_cols u, 
                            red_straight dpmat_list u,
                            cali!=degrees,t); 
        >>
   else u:=car u;
   cali!=degrees:=dpmat_rowdegrees bas;
   if comp_ch then 
       change:=dpmat_make(dpmat_rows u,dpmat_rows bas, 
                bas_neworder bas_getrelations dpmat_list u, 
                cali!=degrees,nil);
   bas_removerelations dpmat_list u;
   if comp_syz then
   << syz:=nconc(syz,syz1);
      syz:= dpmat_make(length syz,dpmat_rows bas, 
                bas_neworder bas_renumber syz,cali!=degrees,nil);
   >>;
   cali!=degrees:=dpmat_coldegs u;
   return {u,change,syz}
   end) where cali!=degrees:=dpmat_coldegs bas,
                !*factorunits:=!*factorunits, 
                !*detectunits:=!*detectunits,
                cali!=monset:=cali!=monset; 

% #########   The General Groebner driver ###############

Comment        

It returns {gb,syz,trace}  with change on the relation part of gb,
where 
  INPUT  : r, c, gb = rows, columns, base list
  OUTPUT :
       <dpmat> gb is the Groebner basis 
       <base list> syz is the dpmat_list of the syzygy matrix
       <spairlist> trace is the Groebner trace.

There are three different versions of the general driver that branche 
according to a reduction function
        rf : {pol,simp} |---> {pol,simp}
found with get('cali,'groeb!=rf):

1. Total reduction with local simplifier lists. For local term orders
        this is (almost) Mora's first version for the tangent cone.
        
2. Total reduction with global simplifier list. For local term orders
	this is (almost) Mora's SimpStBasis.

3. Total reduction with bounded ecart. This needs no extra simplifier
        list.

end comment;

symbolic procedure groeb!=generaldriver(r,c,gb,comp_syz);
  begin scalar u, q, syz, p, pl, pol, rep, trace, return_by_unit,
                simp, rf, Ccrit;
    Ccrit:=(not comp_syz) and (c<2); % don't reduce main syzygies 
    simp:=sort(listminimize(gb,function red!=cancelsimp),
                function red_better);
    pl:=groeb_makepairlist(gb,Ccrit);
    rf:=get('cali,'groeb!=rf);
    if cali_trace() > 30 then groeb_printpairlist pl; 
    if cali_trace() > 5 then 
        <<terpri(); write" New base elements :";terpri() >>;

    % -------- working out pair list
    while pl and not return_by_unit do
    << % ------- Choose a pair
       p:=car pl; pl:=cdr pl;

       % ------ compute S-polynomial (which is a base element)
       if cali_trace() > 10 then groeb_printpair(p,pl);
       u:=apply2(rf,groeb_spol p,simp);
       pol:=first u; simp:=second u;
       if cali_trace() > 70 then
       << terpri(); write" Reduced S.-pol. : "; 
          dp_print2 bas_dpoly pol
       >>;

       if bas_dpoly pol then 
              % --- the S-polynomial doesn't reduce to zero
       << pol:=groeb!=postprocess pol;
          r:=r+1; 
          pol:=bas_newnumber(r,pol);

                   % --- update the tracelist
          q:=bas_dpoly pol; 
          trace:=list(groeb!=i p,groeb!=j p,r,dp_lmon q) . trace;

          if cali_trace() > 20 then
            << terpri(); write r,". ---> "; dp_print2 q >>;
          if Ccrit and (dp_unit!? q) then return_by_unit:=t;

                   % ----- update
          if not return_by_unit then 
          << pl:=groeb_updatePL(pl,gb,pol,Ccrit);
             if cali_trace() > 30 then
                << terpri(); groeb_printpairlist pl >>;
              gb:=pol.gb;
              simp:=red_update(simp,pol);
          >>;
       >>  

       else % ------ S-polynomial reduces to zero
       if comp_syz then 
             syz:=car bas_simpelement(bas_make(0,bas_rep pol)) . syz
    >>;

    % --------  updating the result
    if cali_trace()>0 then 
    << terpri(); write " Simplifier list has length ",length simp >>;
    if return_by_unit then return 
        % --- no syzygies are to be computed
        {dpmat_from_dpoly pol,nil,reversip trace};
    gb:=dpmat_make(length gb,c,gb,cali!=degrees,t);
    return {gb,syz,reversip trace}
    end;

% --- The different reduction functions.

symbolic procedure groeb!=rf1(pol,simp); { red_TotalRed(simp,pol),simp };

symbolic procedure groeb!=rf2(pol,simp);
  if (null bas_dpoly pol) or (null simp) then {pol,simp}
  else begin scalar v,q;

        % Make first reduction with bounded ecart.
     pol:=red_TopRedBE(simp,pol); 

        % Now loop into reduction with minimal ecart.
     while (q:=bas_dpoly pol) and (v:=red_divtest(simp,dp_lmon q)) do
         << v:=red_subst(pol,v); 
                % Updating the simplifier list could make sense even
                % for the noetherian case, since it is a global list. 
            simp:=red_update(simp,pol);
            pol:=red_TopRedBE(simp,v);
         >>;

        % Now make tail reduction
     if !*red_total and bas_dpoly pol then pol:=red_TailRed(simp,pol);
     return {pol,simp};
     end;

symbolic procedure groeb!=rf3(pol,simp);
% Total reduction with bounded ecart.
  if (null bas_dpoly pol) or (null simp) then {pol,simp}
  else begin
     pol:=red_TopRedBE(simp,pol); 
     if bas_dpoly pol then 
        pol:=red_TailRedDriver(simp,pol,function red_TopRedBE);
     return {pol,simp};
     end;

% #########   The Lazy Groebner driver ###############

Comment 

The lazy groebner driver implements the lazy strategy for local
standard bases, i.e. stepwise reduction of S-Polynomials according to
a refinement of the (ascending) division order on leading terms.

end comment;


symbolic procedure groeb_lazystbasis(bas,comp_mgb,comp_ch,comp_syz);
  groeb!=choose_driver(bas,comp_mgb,comp_ch,comp_syz,
				function groeb!=lazydriver);

symbolic procedure groeb!=lazymocompare(a,b);
% A dpoly with leading monomial a should be processed before dpolys
% with leading monomial b.
  mo_ecart a < mo_ecart b;

symbolic procedure groeb!=queuesort(a,b); 
% Sort criterion for the queue.
  groeb!=lazymocompare(dp_lmon bas_dpoly a,dp_lmon bas_dpoly b); 
  
symbolic procedure groeb!=nextspol(pl,queue);
% True <=> take first pl next.
  if null queue then t
  else if null pl then nil
  else groeb!=lazymocompare(nth(car pl,3),dp_lmon bas_dpoly car queue); 

symbolic procedure groeb!=lazydriver(r,c,gb,comp_syz);
% The lazy version of the driver.
  begin scalar syz, Ccrit, queue, u, v, q, simp, p, pl, pol,
                return_by_unit;
    simp:=sort(listminimize(gb,function red!=cancelsimp),
                function red_better);
    Ccrit:=(not comp_syz) and (c<2); % don't reduce main syzygies
    pl:=groeb_makepairlist(gb,Ccrit);
    if cali_trace() > 30 then groeb_printpairlist pl; 
    if cali_trace() > 5 then 
        <<terpri(); write" New base elements :";terpri() >>;
    
    % -------- working out pair list
    
    while (pl or queue) and not return_by_unit do
      if groeb!=nextspol(pl,queue) then
      << p:=car pl; pl:=cdr pl;
         if cali_trace() > 10 then groeb_printpair(p,pl);
         pol:=groeb_spol p;
         if bas_dpoly pol then % back into the queue
             if Ccrit and dp_unit!? bas_dpoly pol then
                        return_by_unit:=t
             else queue:=merge(list pol, queue, 
                                    function groeb!=queuesort)
         else if comp_syz then % pol reduced to zero.
                syz:=bas_simpelement bas_make(0,bas_rep pol).syz;
      >>
      else 
      << pol:=car queue; queue:=cdr queue; 
           % Try one top reduction step
         if (v:=red_divtestBE(simp,dp_lmon bas_dpoly pol,
			bas_dpecart pol)) then ()
		% do nothing with simp !
         else if (v:=red_divtest(simp,dp_lmon bas_dpoly pol)) then 
                simp:=red_update(simp,pol);
           % else v:=nil;
         if v then % do one top reduction step
         << pol:=red_subst(pol,v);
            if bas_dpoly pol then % back into the queue
                queue:=merge(list pol, queue, 
                                function groeb!=queuesort)
            else if comp_syz then % pol reduced to zero.
                 syz:=bas_simpelement bas_make(0,bas_rep pol).syz;
         >>     
         else % no reduction possible
         << % make a tail reduction with bounded ecart and the
            % usual postprocessing :
            pol:=groeb!=postprocess
		if !*red_total then 
		red_TailRedDriver(gb,pol,function red_TopRedBE)
		else pol;
            if dp_unit!? bas_dpoly pol then return_by_unit:=t
            else % update the computation
            << r:=r+1; pol:=bas_newnumber(r,pol);
               if cali_trace() > 20 then
               << terpri(); write r,". --> "; dp_print2 bas_dpoly pol >>;
               pl:=groeb_updatePL(pl,gb,pol,Ccrit);
               simp:=red_update(simp,pol);
               gb:=pol.gb;
            >>
         >>
      >>;

     % --------  updating the result
  
    if cali_trace()>0 then 
    << terpri(); write " Simplifier list has length ",length simp >>;
    if return_by_unit then return {dpmat_from_dpoly pol,nil,nil}
    else return 
        {dpmat_make(length simp,c,simp,cali!=degrees,t), syz, nil}
    end;

% ################  The Groebner Tools ##############

% ---------- Critical pair criteria -----------------------

symbolic procedure groeb!=critA(p);
% p is a pair list {(i.k):i running} of pairs with equal module component
% number. Choose those pairs among them that are minimal wrt. division order 
% on lcm(i.k).
  listminimize(p,function groeb!=testA);

symbolic procedure groeb!=testA(p,q); mo_divides!?(nth(p,3),nth(q,3));

symbolic procedure groeb!=critB(e,p);
% Delete pairs from p, for which testB is false.
  for each x in p join if not groeb!=testB(e,x) then {x};

symbolic procedure groeb!=testB(e,a);
% e=lt(f_k). Test, whether for a=pair (i j) 
% komp(a)=komp(e) and Syz(i,j,k)=[ 1 * * ].
    (mo_comp e=car a) 
    and mo_divides!?(e,nth(a,3)) 
    and (not mo_equal!?(mo_lcm(dp_lmon bas_dpoly nth(a,5),e),
                        nth(a,3)))
    and (not mo_equal!?(mo_lcm(dp_lmon bas_dpoly nth(a,4),e),
                        nth(a,3)));

symbolic procedure groeb!=critC(p);
% Delete main syzygies.
  for each x in p join if not groeb!=testC1 x then {x};

symbolic procedure groeb!=testC1 el;
    mo_equal!?(
        mo_sum(dp_lmon bas_dpoly nth(el,5),
               dp_lmon bas_dpoly nth(el,4)),
        nth(el,3));

symbolic procedure groeb_updatePL(p,gb,be,Ccrit);
% Update the pairlist p with the new base element be and the old ones
% in the base list gb. Discard pairs where both base elements have 
% number part 0.
    begin scalar p1,k,a,n; n:=(bas_nr be neq 0); 
    a:=dp_lmon bas_dpoly be; k:=mo_comp a;
    for each b in gb do 
        if (k=mo_comp dp_lmon bas_dpoly b)
                and(n or (bas_nr b neq 0)) then 
                        p1:=groeb!=newpair(k,b,be).p1;
    p1:=groeb!=critA(sort(p1,function groeb!=better));
    if Ccrit then p1:=groeb!=critC p1;
    return 
        merge(p1, 
              groeb!=critB(a,p), function groeb!=better);
    end;

symbolic procedure groeb_makepairlist(gb,Ccrit);
    begin scalar newgb,p;
    while gb do
    << p:=groeb_updatePL(p,newgb,car gb,Ccrit); 
       newgb:=car gb .  newgb; gb:=cdr gb 
    >>;
    return p;
    end;

% -------------- Pair Management --------------------

symbolic procedure groeb!=i p; bas_nr nth(p,4);

symbolic procedure groeb!=j p; bas_nr nth(p,5);

symbolic procedure groeb!=better(a,b);
% True if the Spair a is better than the Spair b.
    if (cadr a < cadr b) then t
    else if (cadr a = cadr b) then mo_compare(nth(a,3),nth(b,3))<=0
    else nil;
    
symbolic procedure groeb!=weight(lcm,p1,p2);
    mo_ecart(lcm) + min2(bas_dpecart p1,bas_dpecart p2);

symbolic procedure groeb!=newpair(k,p1,p2);
% Make an spair from base elements with common component number k.
    list(k,groeb!=weight(lcm,p1,p2),lcm, p1,p2)
        where lcm =mo_lcm(dp_lmon bas_dpoly p1,dp_lmon bas_dpoly p2);
 
symbolic procedure groeb_printpairlist p;
    begin
    for each x in p do 
        << write groeb!=i x,".",groeb!=j x; print_lf  " | " >>;
    terpri();
    end;

symbolic procedure groeb_printpair(pp,p);
    begin terpri(); 
    write"Investigate (",groeb!=i pp,".",groeb!=j pp,")  ",
        "Pair list has length ",length p; terpri() 
    end;
    
% ------------- S-polynomial constructions -----------------

symbolic procedure groeb_spol pp;
% Make an S-polynomial from the spair pp, i.e. return
% a base element with 
%   dpoly = ( zi*mi*(red) pi - zj*mj*(red) pj ) 
%    rep  = (zi*mi*rep_i - zj*mj*rep_j),
%
%       where mi=lcm/lm(pi), mj=lcm/lm(pj)
%       and  zi and zj are appropriate scalars.
%
    begin scalar pi,pj,ri,rj,zi,zj,lcm,mi,mj,a,b;
      a:=nth(pp,4); b:=nth(pp,5); lcm:=nth(pp,3);
      pi:=bas_dpoly a; pj:=bas_dpoly b; ri:=bas_rep a; rj:=bas_rep b;
      mi:=mo_diff(lcm,dp_lmon pi); mj:=mo_diff(lcm,dp_lmon pj);
      zi:=dp_lc pj; zj:=bc_neg dp_lc pi;
      a:=dp_sum(dp_times_bcmo(zi,mi, cdr pi),
                dp_times_bcmo(zj,mj, cdr pj));
      b:=dp_sum(dp_times_bcmo(zi,mi, ri),
                dp_times_bcmo(zj,mj, rj));
      a:=bas_make1(0,a,b);
      if !*bcsimp then a:=car bas_simpelement a;
      if cali_trace() > 70 then
         << terpri(); write" S.-pol : "; dp_print2 bas_dpoly a >>;
      return a;
    end;

symbolic procedure groeb_mingb gb;
% Returns the min. Groebner basis dpmat mgb of the dpmat gb
% discarding base elements with bas_nr<=0.
   begin scalar u;
    u:=for each x in car red_collect dpmat_list gb join
                if bas_nr x>0 then {x};
        % Choosing base elements with minimal leading terms only.
    return dpmat_make(length u,dpmat_cols gb,bas_renumber u,
                    dpmat_coldegs gb,dpmat_gbtag gb);
    end;

% ------- Minimizing a basis using its syszgies ---------

symbolic procedure groeb!=delete(l,bas);
% Delete base elements from the base list bas with number in the
% integer list l.
    begin scalar b;
    while bas do
      << if not memq(bas_nr car bas,l) then b:=car bas . b;
         bas:= cdr bas
      >>;
    return reverse b
    end; 

symbolic procedure groeb_minimize(bas,syz);
% Minimize the dpmat pair bas,syz deleting superfluous base elements
% from bas using syzygies from syz containing unit entries.
   (begin scalar drows, dcols, s,s1,i,j,p,q,y;
   cali!=degrees:=dpmat_coldegs syz;
   s1:=dpmat_list syz; j:=0;
   while j < dpmat_rows syz do
     << j:=j+1; 
        if (q:=bas_dpoly bas_getelement(j,s1)) then 
          << i:=0; 
             while leq(i,dpmat_cols syz) and 
                 (memq(i,dcols) or not dp_unit!?(p:=dp_comp(i,q))) 
                        do i:=i+1;
             if leq(i,dpmat_cols syz) then 
               << drows:=j . drows;
                  dcols:=i . dcols; 
                  s1:=for each x in s1 collect
                     if memq(bas_nr x,drows) then x
                     else (bas_make(bas_nr x,
                        dp_diff(dp_prod(y,p),dp_prod(q,dp_comp(i,y))))
                           where y:=bas_dpoly x);             
               >>
          >>
     >>;
   
   % --- s1 becomes the new syzygy part, s the new base part.
   
   s1:=bas_renumber bas_simp groeb!=delete(drows,s1);                 
   s1:=dpmat_make(length s1,dpmat_cols syz,s1,cali!=degrees,nil);
                        % The new syzygy matrix of the old basis.
   s:=dpmat_renumber 
          dpmat_make(dpmat_rows bas,dpmat_cols bas,
                groeb!=delete(dcols,dpmat_list bas),
                dpmat_coldegs bas,nil);
   s1:=dpmat_mult(s1,dpmat_transpose cdr s); 
        % The new syzygy matrix of the new basis, but not yet in the
        % right form since cali!=degrees is empty.
   s:=car s;            % The new basis.
   cali!=degrees:=dpmat_rowdegrees s;
   s1:=interreduce!* dpmat_make(dpmat_rows s1,dpmat_cols s1,
                bas_neworder dpmat_list s1,cali!=degrees,nil);
   return s.s1;
   end) where cali!=degrees:=cali!=degrees;
  
% ------ Computing standard bases via homogenization ----------------
 
symbolic procedure groeb_homstbasis(m,comp_mgb,comp_ch,comp_syz);
  (begin scalar v,c,e,n,to,u;
  c:=cali!=basering; v:=list gensym();
  if not(comp_ch or comp_syz) then cali!=monset:=append(v,cali!=monset);
  setring!* ring_sum(c,ring_define(v,nil,'lex,'(1)));
  cali!=degrees:=mo_degneworder dpmat_coldegs m;
  if cali_trace()>0 then print" Homogenize input ";
  u:=(groeb_stbasis(mathomogenize!*(m,car v),
		comp_mgb,comp_ch,comp_syz) where !*noetherian=t);
  if cali_trace()>0 then print" Dehomogenize output ";
  u:=for each x in u collect if x then matdehomogenize!*(x,car v);
  setring!* c; cali!=degrees:=dpmat_coldegs m;
  return {if first u then dpmat_neworder(first u,t),
		if second u then dpmat_neworder(second u,nil),
		if third u then dpmat_neworder(third u,nil)};
  end) where cali!=basering:=cali!=basering,
		cali!=monset:=cali!=monset,
		cali!=degrees:=cali!=degrees;  


% Two special versions for standard basis computations, not included
% in full generality into the algebraic interface.

symbolic operator homstbasis;
symbolic procedure homstbasis m;
  if !*mode='algebraic then dpmat_2a homstbasis!* dpmat_from_a m
  else homstbasis!* m;

symbolic procedure homstbasis!* m; 
  groeb_mingb car groeb_homstbasis(m,t,nil,nil);

symbolic operator lazystbasis;
symbolic procedure lazystbasis m;
  if !*mode='algebraic then dpmat_2a lazystbasis!* dpmat_from_a m
  else lazystbasis!* m;

symbolic procedure lazystbasis!* m;  
  car groeb_lazystbasis(m,t,nil,nil);

endmodule;  % groeb

module groebf;

Comment

		##############################
		###		   	   ###
		###   GROEBNER FACTORIZER  ###
		###			   ###
		##############################

The Groebner algorithm with factorization and constraint lists.

New in version 2.2 :
   
	syntax for groebfactor
        listgroebfactor!*
        extendedgroebfactor!*

There are two versions of the extended groebner factorizer.
One needs the lex. term order, the other supports arbitrary ones (the
default). Switch between both versions via switch lexefgb.

Internal data structure
        
        result::={dpmat, constraint list }       

        extendedresult::=
                {dpmat, constraint list, (dimension | indepvarset) }

        problem::={dpmat, constraint list, pair list, easydim}

        aggregate::=
        { (list of problems) , (list of results) }

For a system with constraints m=(b,c) V(m)=V(b,c) denotes the zero set
V(b)\setminus D(c).

The Groebner algorithm supports only the classical reduction
principle. 

end comment;

% --- The side effect switching lexefgb on or off :

put('lexefgb,'simpfg,'((t (put 'cali 'efgb 'lex)) 
	(nil (remprop 'cali 'efgb))));


symbolic procedure groebf!=problemsort(a,b); 
% Sorted by ascending easydim to force depth first search.
   (nth(a,4)<nth(b,4))
   or (nth(a,4)=nth(b,4)) and (length second a<= length second b);

symbolic procedure groebf!=resultsort(a,b);
% Sort extendedresults by descending true dimension, assuming the 
% third part being the dimension.
   third a > third b;

put('groebfactor,'psopfn,'intf!=groebfactor);
symbolic procedure intf!=groebfactor m;
  begin scalar bas,con;
  bas:=dpmat_from_a reval first m;
  if length m=1 then con:=nil
  else if length m=2 then
	con:=for each x in cdr reval second m collect dp_from_a x
  else rederr("Syntax : GROEBFACTOR(base list [,constraint list])");
  return makelist 
	for each x in groebfactor!*(bas,con) collect dpmat_2a first x;
  end;

symbolic operator listgroebfactor;
symbolic procedure listgroebfactor l;
% l is a list of polynomial systems. We look for the union of the
% solution sets.
   if !*mode='algebraic then 
	makelist for each x in listgroebfactor!* 
		for each y in cdr reval l collect dpmat_from_a y
	collect dpmat_2a x
   else listgroebfactor!* l;

symbolic procedure listgroebfactor!* l;
% Proceed a whole list of dpmats at once.
   begin scalar gbs;
   gbs:=for each x in 
        groebf!=preprocess(nil,for each x in l collect {x,nil}) 
                collect groebf!=initproblem x;
   gbs:=sort(gbs,function groebf!=problemsort);
   return for each x in groebf!=masterprocess(gbs,nil) collect first x;
   end;

symbolic procedure groebfactor!*(bas,poly);
% Returns a list l of results (b,c) such that
%       V(bas,poly) = \union { V(b,c) : (b,c) \in l }

   if dpmat_cols bas > 0 then
        rederr "GROEBFACTOR only for ideal bases"
   else if null !*noetherian then
        rederr "GROEBFACTOR only for noetherian term orders"
   else if dpmat_zero!? bas then list({bas,poly})
   else begin scalar gbs;
   if cali_trace() > 5 then
   << write"GROEBFACTOR the system "; dpmat_print bas >>;
   gbs:=for each x in groebf!=preprocess(nil,list {bas,poly}) collect
                groebf!=initproblem x;
   gbs:=sort(gbs,function groebf!=problemsort);
   return groebf!=masterprocess(gbs,nil);
   end;

put('extendedgroebfactor,'psopfn,'intf!=extendedgroebfactor);
symbolic procedure intf!=extendedgroebfactor m;
  begin scalar bas,con;
  bas:=dpmat_from_a reval first m;
  if length m=1 then con:=nil
  else if length m=2 then
	con:=for each x in cdr reval second m collect dp_from_a x
  else rederr("Syntax : EXTENDEDGROEBFACTOR(base list [,constraint list])");
  return makelist 
	for each x in extendedgroebfactor!*(bas,con) collect 
		makelist {first x,makelist second x,makelist third x};
  end;

symbolic procedure extendedgroebfactor!*(bas,poly);
% Returns a list l of extendedresults (b,c,vars) in prefix form such that 
%       V(bas,poly) = \union { V(b,c) : (b,c) \in l }
% and b:<\prod c> is puredimensional with independent variable set vars.

   if dpmat_cols bas > 0 then 
        rederr "EXTENDEDGROEBFACTOR only for ideal bases"
   else if null !*noetherian then 
        rederr "EXTENDEDGROEBFACTOR only for noetherian term orders"
   else if dpmat_zero!? bas then 
        list({dpmat_2a bas,nil,ring_names cali!=basering})
   else begin scalar gbs;
   if cali_trace() > 5 then 
   << write"EXTENDEDGROEBFACTOR the system "; dpmat_print bas >>;
   gbs:=for each x in groebf!=preprocess(nil,list {bas,poly}) collect
                groebf!=initproblem x;
   return groebf!=extendedmasterprocess gbs;            
   end;

symbolic procedure groebf!=extendedmasterprocess gbs;
% gbs is a list of problems to process. Returns a list of 
% extendedresults in prefix form.  
% If {m,con,vars} is such an extendedresult then m:<\prod con> is the 
% (puredimensional) recontraction of m\tensor k(vars).
   begin scalar res,res1,u;
   while gbs or res do
     if gbs then
     % The hard postprocessing is done only at the end.
     << gbs:=sort(gbs,function groebf!=problemsort);
        % Convert results to extendedresults and sort them :
        res:=for each x in groebf!=masterprocess(gbs,res) collect
                if (length x=3) then x 
                else {first x,second x,dim!* first x};
        res:=sort(res,function groebf!=resultsort);
        gbs:=nil
      >>
      else % Do the first (hard) postprocessing
      << % process result by result :
         u:=groebf!=postprocess2 car res; res:=cdr res;
         % Extract and preprocess new problems from u.
         % This needs descent by dimension of the results proceeded.
         gbs:=for each x in groebf!=preprocess(res,second u)
                        collect groebf!=initproblem x;
         % Extract extendedresults from u.
         % They may be non-GB wrt t h i s  term order, see above.
         res1:=nconc(first u,res1);
      >>;
   return res1;
   end;

% --------- Another version of the extended Groebner factorizer -------
put('extendedgroebfactor1,'psopfn,'intf!=extendedgroebfactor1);
symbolic procedure intf!=extendedgroebfactor1 m;
  begin scalar bas,con;
  bas:=dpmat_from_a reval first m;
  if length m=1 then con:=nil
  else if length m=2 then
	con:=for each x in cdr reval second m collect dp_from_a x
  else rederr("Syntax : EXTENDEDGROEBFACTOR1(base list [,constraint list])");
  return makelist 
	for each x in extendedgroebfactor1!*(bas,con) collect 
		makelist {first x,makelist second x,makelist third x};
  end;

symbolic procedure extendedgroebfactor1!*(bas,poly);
% Returns a list l of extendedresults (b,c,vars) in prefix form such that 
%       V(bas,poly) = \union { V(b,c) : (b,c) \in l }
% and b:<\prod c> is puredimensional with independent variable set vars.

   if dpmat_cols bas > 0 then 
        rederr "EXTENDEDGROEBFACTOR1 only for ideal bases"
   else if null !*noetherian then 
        rederr "EXTENDEDGROEBFACTOR1 only for noetherian term orders"
   else if dpmat_zero!? bas then 
        list({dpmat_2a bas,nil,ring_names cali!=basering})
   else begin scalar gbs;
   if cali_trace() > 5 then 
   << write"EXTENDEDGROEBFACTOR1 the system "; dpmat_print bas >>;
   gbs:=for each x in groebf!=preprocess(nil,list {bas,poly}) collect
                groebf!=initproblem x;
   return for each x in groebf!=extendedmasterprocess1 gbs collect 
                nth(x,4);
   end;

symbolic procedure groebf!=extendedmasterprocess1 gbs;
% Version that computes the retraction of each intermediate result
% to apply FGB shortcuts. gbs is a list of problems to process. 
% Returns a list of extendedresults in prefix form.  
% If {m,con,vars} is such an extendedresult then m:<\prod con> is the 
% (puredimensional) recontraction of m\tensor k(vars).
% internally they are incorporated into res as
%       {dpmat, nil (since no constraints), dim, prefix form}.
   begin scalar res,u,v,p;
   while gbs or 
        (p:=listtest(res,nil,function (lambda(x,y); length x<4))) do
     if gbs then
     % The hard postprocessing is done only at the end.
     << gbs:=sort(gbs,function groebf!=problemsort);
        % Convert results to extendedresults and sort them :
        res:=for each x in groebf!=masterprocess(gbs,res) collect
                if (length x>2) then x 
                else {first x,second x,dim!* first x};
        res:=sort(res,function groebf!=resultsort);
        gbs:=nil
      >>
      else % Do the first (hard) postprocessing
      << % process result by result :
         u:=groebf!=postprocess2 p; res:=delete(p,res);
         % Extract extendedresults from u and convert them
         % with postprocess3 to quotient ideals.
         v:=for each x in first u collect 
                {groebf!=postprocess3 x, nil, length third x,x};
         for each y in v do 
           if not groebf!=redtest(res,y) then 
                res:=merge({y},groebf!=sieve(res,y),
                        function groebf!=resultsort);
         % Extract and preprocess new problems from u.
         gbs:=for each x in groebf!=preprocess(res,second u) collect 
                        groebf!=initproblem x;
       >>;
   return res;
   end;

% ------- end of the second version ------------------------

symbolic procedure groebf!=masterprocess(gbs,res);
% gbs = list of problems, res = list of results (since several times 
% involved in the extendedmasterprocess).
% Returns a list of results already postprocessed with (the easy)
% groebf!=postpocess1 where the elements surviving from res may
% change only in the constraints part.
   begin scalar u,v;
   while gbs do
   << if cali_trace()>10 then
                print for each x in gbs collect nth(x,4);
      u:=groebf!=slave car gbs; gbs:=cdr gbs;
      if u then % u is an aggregate.
      << % postprocess the result part returning a list of aggregates.
         v:=for each x in second u collect groebf!=postprocess1(res,x);
         % split up into the problems u and results v
         u:=nconc(car u,for each x in v join car x);
         v:=for each x in v join second x;
         for each y in v do 
           if cali_trace() > 5 then
           << write"partial result :"; terpri();
              dpmat_print car y ;
               prin2"constraints : "; 
               for each x in second y do dp_print2 x;
           >>;
         for each y in v do 
           if not groebf!=redtest(res,y) then 
                res:=y . groebf!=sieve(res,y);
         for each x in u do
           if not groebf!=redtest(res,x) then 
                gbs:=merge({x},groebf!=sieve(gbs,x),
                                function groebf!=problemsort);
         if cali_trace()>20 then
            << terpri(); write length gbs," remaining branches. ",
               length res," partial results"; terpri()
            >>;
       >>
      else % branch discarded    
        if cali_trace()>20 then print"Branch discarded";
   >>;
   return res;
   end;

symbolic procedure groebf!=initproblem x;
% Converts a result into a problem.
  list(car x,second x, groeb_makepairlist(dpmat_list car x,t),
                easydim!* car x);

% The following two procedures make destructive changes 
% on the cdr of some of the list elements.

symbolic procedure groebf!=redtest(a,c);
% Ex. u \in a : car u \submodule car c ? 
% If so, update the constraints of u.
  begin scalar u;
  u:=listtest(a,c,function(lambda(x,y); submodulep!*(car x,car y)));
  if u then cdr u:=intersection(second u,second c).cddr u;
  return u;
  end;

symbolic procedure groebf!=sieve(a,c);
% Remove u \in a with car c \submodule car u 
% and update the constraints of c.
  for each x in a join if not submodulep!*(car c,car x) then {x}
     else << cdr c:=intersection(second x,second c).cddr c; >>;

symbolic procedure groebf!=test(con,m);
% nil <=> ex. f \in con : f mod m = 0. m is a baslist.
  if null m then t
  else if dp_unit!? bas_dpoly first m then nil
  else if null con then t
  else begin scalar p; p:=t;
    while p and con do
    << p:=p and bas_dpoly car red_redpol(m,bas_make(0,car con));
       con:=cdr con
    >>;
    return p;
    end;

symbolic procedure groebf!=newcon(r,d);
% r=(m,c) is a result, d a list of polynomials. Returns the 
% (slightly optimized) result list ( (m+(p),c+(q|q<p)) | p \in d ).
  begin scalar m,c,u;
    m:=first r; c:=second r; 
    return for each p in d join
       if not member(p,c) then
       << u:={matsum!* {m, dpmat_from_dpoly(p)}, c}; c:=p.c; {u} >>;
    end;

symbolic procedure groebf!=preprocess(a1,b);
% Try to split (factor) each polynomial in each problem of the list b.
% Returns a list of results.
% a1 is a list of results already computed.

  begin scalar a,c,d,back,u;
    if cali_trace()>20 then prin2"preprocessing started";
    while b do 
    << if cali_trace()>20 then 
       << terpri(); write length a," ready. "; 
          write length b," left."; terpri()
       >>;
       c:=car b; b:=cdr b; 
       if not (null groebf!=test(second c,dpmat_list car c)
            or groebf!=redtest(a1,c) 
            or groebf!=redtest(a,c)) then
       << d:=dpmat_list car c; back:=nil; 
          while d and not back do
          << u:=((fctrf numr simp dp_2a bas_dpoly car d) 
                        where !*factor=t);
             if (length u>2) or (cdadr u>1) then
             << back:=t;
                b:=append(groebf!=newcon(c,
                        for each y in cdr u collect 
                                dp_from_a prepf car y),b);
             >>
             else d:=cdr d
          >>;
          if not back then 
          << if cali_trace()>20 then
             << terpri(); write"Subproblem :"; dpmat_print car c >>;
             if not groebf!=redtest(a,c) then a:=c . groebf!=sieve(a,c);
          >>
       >>
    >>;
    if cali_trace()>20 then prin2"preprocessing finished...";
    return a;
    end;

symbolic procedure groebf!=slave c;
% Proceed upto the first splitting. Returns an aggregate.
  begin integer i; scalar be,back,p,u,v,a,b,gb,pl,nr,pol,con;
   
  back:=nil; 
  gb:=bas_sort dpmat_list first c; 
  con:=second c; pl:=third c; nr:=length gb;
  while pl and not back do
  << p:=car pl; pl:=cdr pl;
     if cali_trace() > 10 then groeb_printpair(p,pl);
              
     pol:=groeb_spol p;
     if cali_trace() > 70 then
     << terpri(); write"S.-pol : "; dp_print2 bas_dpoly pol >>;
     pol:=bas_dpoly car red_redpol(gb,pol);
     if cali_trace() > 70 then
     << terpri(); write"Reduced S.-pol. : "; dp_print2 pol >>;
             
     if pol then 
     << if !*bcsimp then pol:=car dp_simp pol;
        if dp_unit!? pol then 
        << if cali_trace()>20 then print "unit ideal";
           back:=t
        >>
        else
        << % -- factorize pol
           u:=((fctrf numr simp dp_2a pol) where !*factor=t); 
           nr:=nr+1;
           if length cdr u=1 then % only one factor 
           << pol:=dp_from_a prepf caadr u;
              be:=bas_make(nr,pol);
              u:=be.gb;
              if null groebf!=test(con,u) then 
              << back:=t;
                 if cali_trace()>20 then print" zero constraint";
              >>
              else  
              << if cali_trace()>20 then
                 << terpri(); write nr,". "; dp_print2 pol >>;
                 pl:=groeb_updatePL(pl,gb,be,t);
                 if cali_trace() > 30 then
                 << terpri(); groeb_printpairlist pl >>;
                 gb:=merge(list be,gb,function red_better);  
              >>    
           >>   
           else % more than one factor
           << for each x in cdr u do
              << pol:=dp_from_a prepf car x;
                 be:=bas_make(nr,pol);
                 a:=be.gb;
                 if groebf!=test(con,a) then 
                 << if cali_trace()>20 then
                    << terpri(); write nr; write". "; dp_print2 pol >>;
                    p:=groeb_updatePL(append(pl,nil),gb,be,t);
                    if cali_trace() > 30 then
                    << terpri(); groeb_printpairlist p >>;
                    b:=merge(list be,append(gb,nil),
                        function red_better);
                    b:=dpmat_make(length b,0,b,nil,nil);
                    v:={b,con,p}.v;
                 >>
                 else if cali_trace()>20 then print" zero constraint";
                 if not member(pol,con) then con:=pol . con;
              >>;   
              if null v then 
                << if cali_trace()>20 then print "Branch canceled"; 
                   back:=t 
                >>
              else if length v=1 then
              << c:=car v; gb:=dpmat_list first c; con:=second c;
                 pl:=third c; v:=nil;
              >>
              else
              << back:=t;
                 if cali_trace()>20 then
                 << write" Branching into ",length v," parts "; 
                    terpri(); 
                 >>;
              >>;
           >>;
        >>;    
     >>;
  >>;
  if not back then % pl exhausted => new partial result.
      return 
      {nil,list {groeb_mingb dpmat_make(length gb,0,gb,nil,t),con}}
  else if v then return 
        {for each x in v collect 
                {first x,second x,third x,easydim!* first x},
        nil}
  else return nil;
  end;

symbolic procedure groebf!=postprocess1(res,x);
% Easy postprocessing a result. Returns an aggregate.
% res is a list of results, already obtained.

  begin scalar p,r,v; 

     % ---- interreduce and try factorization once more. 

     if !*red_total then
     << v:=groebf!=preprocess(res, 
                list {dpmat_make(dpmat_rows car x,0,
                   red_straight dpmat_list car x,nil,
				dpmat_gbtag car x), 
			second x});  
        if (length v=1) and dpmat_gbtag caar v then r:=v 
        else p:=for each x in v collect groebf!=initproblem x;
     >>
     else r:={x};
     return {p,r};
     end;

symbolic procedure groebf!=postprocess2 m;
  (begin scalar d,vars,u,v,c1,m1,m1a,m2,p,con;
    con:=second m; d:=third m; m:=first m;
    v:=moid_goodindepvarset m; 
    if neq(length v,d) then 
                rederr"In POSTPROCESS2 the dimension is wrong";
    if null v then return 
        {for each x in groebf!=zerosolve(m,con) collect {x,nil,nil},nil};

    % -- Prepare data for change to dimension zero :
    % Recompute gbases wrt. the elimination order for u and
    % take only those components for which v remains independent.

    vars:=ring_names(c1:=cali!=basering);
    u:=setdiff(vars,v);
    if get('cali,'efgb)='lex then setring!* ring_lp(c1,u)
    else setring!* ring_rlp(c1,u);
    m1:=for each u in groebfactor!*(dpmat_neworder(m,nil), 
                for each x in con collect dp_neworder x) collect
        {first u,second u,dim!* first u};
    for each x in m1 do
      if (third x = d) and member(v,indepvarsets!* car x) then m1a:=x.m1a
      else m2:=x.m2;
      % m1a : components with indepvarset v
      % m2  : components with v being dependent variables.

    % -- Change to dimension zero.

    m1:=for each x in m1a collect 
        {dpmat_2a first x,for each p in second x collect dp_2a p};
    if get('cali,'efgb)='lex then 
        setring!* ring_define(u,nil,'lex,for each x in u collect 1)
    else setring!* ring_define(u,degreeorder!* u,'revlex,
                                for each x in u collect 1);
    m1:=for each x in m1 collect 
        {groeb_mingb dpmat_from_a first x,
                for each p in second x collect dp_from_a p};

    % Extract the lc's of the lifted Groebner bases and save them
    % for NewCon on the list m1a, since in the zerodimensional part
    % lc's are assumed to be invertible.
    m1a:=pair(m1a,for each x in m1 collect groebf!=elcbe first x);

    % Compute the zerodimensional TriangSets from m1 and their lists
    % of lc's and prepare them for lifting.
    m1:=for each x in m1 join groebf!=zerosolve(first x,second x);
    m1:=for each x in m1 collect {x,groebf!=elcbe dpmat_from_a x};

    % -- Lift all stuff back to c1.

    setring!* c1; 

    % Extract the TriangSets as extendedresults in prefix form (!).
    m1:=for each x in m1 collect {first x,second x,v};
        
    % List of new problems found during recomputation of GB :
    m2:=for each x in m2 collect
        {dpmat_neworder(first x,nil),
         for each y in second x collect dp_neworder y};

    % List of new problems, derived from nonzero conditions for
    % lc's in dimension zero.
    m1a:=for each x in m1a join 
        groebf!=newcon({dpmat_neworder(first car x,nil),
                 for each p in second car x collect dp_neworder p},
        for each p in cdr x collect dp_from_a p);

comment The list of results :

m1 : The list of TriangSets wrt. v produced in this run. They are in
alg. prefix form to remember that they are Groebner bases only
wrt. the pure lex. term order. 

m2 : Results (in prefix form), for which v is dependent.

m1a : Branches, where some of the critical lc's of the TriangSets vanish.

Both m2 and m1a should be returned in the pool of problems.

end comment;
        
    return {m1,nconc(m1a,m2)};
   end)
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering; 
        
symbolic procedure groebf!=elcbe(m);
% Extract list of leading coefficients in algebraic prefix form
% from base elements of the dpmat m.
   for each x in dpmat_list m join
        if domainp dp_lc bas_dpoly x then {}
        else {bc_2a dp_lc bas_dpoly x};

symbolic procedure groebf!=postprocess3 u;
% Compute for the extendedresult u={m,con,vars} in prefix form
%       m:<\prod con>.
   matqquot!*(dpmat_from_a first u,
        groebf!=prod for each x in second u collect dp_from_a x);

symbolic procedure groebf!=prod l;
  begin scalar p; p:=dp_fi 1;
  l:=listminimize(for each x in l join dp_factor x,function equal);
  for each x in l do p:=dp_prod(x,p);
  return p;
  end;

symbolic procedure groebf!=zerosolve(m,con);
% Hook for the zerodimensional solver.
% Input : m = zerodimensional dpmat (not to be checked), 
%       con = list of dpoly constraints.
% Output : a list of dpmats in prefix form.
  begin scalar u,p;
  % Look up the constraints, since during the change to dimension zero
  % some of them may trivialize :
  con:=for each x in con join if not dp_unit!? x then {x};
  % Factorized radical computation.
  u:=groebf_zeroprimes1(m,con);
  % Apply the zerosolver to each of these results.
  return for each x in u join   
        if get('cali,'efgb)='lex then zerosolve!* x else zerosolve1!* x;
  end;

symbolic procedure groebf_zeroprimes1(m,con);
% Returns a list of gbases for the zerodimensional ideal m, incorporating
% as in the groebner factorizer the factors of the univariate polynomials
% in m. 
  begin scalar m1,m2,p,u,l;
  l:=list {m,con};
  for each x in ring_names cali!=basering do
  << m1:=m2:=nil;
     for each y in l do
     << p:=odim_up(x,first y); u:=dp_factor p;
        if (length u>1) or not equal(first u,p) then 
                m1:=nconc(groebf!=newcon(y,u),m1)
        else m2:=y.m2;
     >>;
     l:=groebf!=masterprocess(
        sort(for each x in m1 collect groebf!=initproblem x,
                function groebf!=problemsort),
        m2);
  >>;
  return for each x in l join 
        if second x then {matqquot!*(first x,groebf!=prod second x)}
        % Here one can use the linear algebra quotient algorithm, since 
        % first x is known to be zerodimensional radical.
        else {first x};
    end;    
   
endmodule; % groebf

module matop; 

COMMENT

              #############################
              ####                     ####
              ####  MATRIX OPERATIONS  ####
              ####                     ####
              #############################


This module contains operations on dpmats, that correspond to module
operations on the corresponding images resp. cokernels.

END COMMENT;

symbolic procedure matop!=testdpmatlist l;
% Test l to be a list of dpmats embedded into a common free module.
  if null l then rederr"Empty DPMAT list"
  else begin scalar c,d;
    for each x in l do
        if not eqcar(x,'dpmat) then typerr(x,"DPMAT");
    c:=dpmat_cols car l; d:=dpmat_coldegs car l;
    for each x in cdr l do
      if not (eqn(c,dpmat_cols x) and equal(d,dpmat_coldegs x)) then
                rederr"Matrices don't match in the DPMAT list";
  end;

symbolic procedure matappend!* l;
% Appends rows of the dpmats in the dpmat list l.
  (begin scalar u,r; 
      matop!=testdpmatlist l;
      cali!=degrees:=dpmat_coldegs car l;
      u:=dpmat_list car l; r:=dpmat_rows car l;
      for each y in cdr l do
        << u:=append(u, for each x in dpmat_list y collect
                        bas_newnumber(bas_nr x + r,x));
           r:=r + dpmat_rows y;
        >>;             
      return dpmat_make(r,dpmat_cols car l,u,cali!=degrees,nil)
   end) where cali!=degrees:=cali!=degrees;

put('matappend,'psopfn,'matop!=matappend);
symbolic procedure matop!=matappend l;
% Append the dpmats in the list l.
  dpmat_2a matappend!* for each x in l collect dpmat_from_a reval x; 

symbolic procedure mat2list!* m; 
% Returns the ideal of all elements of m.
  if dpmat_cols m = 0 then m 
  else (begin scalar x;
    x:=bas_renumber bas_zerodelete
        for i:=1:dpmat_rows m join
        for j:=1:dpmat_cols m collect 
                bas_make(0,dpmat_element(i,j,m));
    return dpmat_make(length x,0,x,nil,
		if dpmat_cols m=1 then dpmat_gbtag m else nil) 
    end) where cali!=degrees:=nil;

symbolic procedure matsum!* l;
% Returns the module sum of the dpmat list l.
  interreduce!* matappend!* l;

put('matsum,'psopfn,'matop!=matsum);
put('idealsum,'psopfn,'matop!=matsum);
symbolic procedure matop!=matsum l;
% Returns the sum of the ideals/modules in the list l.
  dpmat_2a matsum!* for each x in l collect dpmat_from_a reval x; 

symbolic procedure matop!=idealprod2(a,b); 
  if (dpmat_cols a > 0) or (dpmat_cols b > 0 ) then 
                rederr"IDEALPROD only for ideals"
  else (begin scalar x;
    x:=bas_renumber
        for each a1 in dpmat_list a join
        for each b1 in dpmat_list b collect 
            bas_make(0,dp_prod(bas_dpoly a1,bas_dpoly b1));
    return interreduce!* dpmat_make(length x,0,x,nil,nil)
    end) where cali!=degrees:=nil;

symbolic procedure idealprod!* l;
% Returns the product of the ideals in the dpmat list l.
 if null l then rederr"empty list in IDEALPROD"
 else if length l=1 then car l
 else begin scalar u;
    u:=car l;
    for each x in cdr l do u:=matop!=idealprod2(u,x);
    return u;
    end;  

put('idealprod,'psopfn,'matop!=idealprod);
symbolic procedure matop!=idealprod l;
% Returns the product of the ideals in the list l.
  dpmat_2a idealprod!* for each x in l collect dpmat_from_a reval x; 

symbolic procedure idealpower!*(a,n);
  if (dpmat_cols a > 0) or (not fixp n) or (n < 0) then
        rederr" Syntax : idealpower(ideal,integer)"
  else if (n=0) then dpmat_from_dpoly dp_fi 1
  else begin scalar w; w:=a;
  for i:=2:n do w:=matop!=idealprod2(w,a);
  return w;
  end;

symbolic operator idealpower;
symbolic procedure idealpower(m,l);
  if !*mode='algebraic then 
        dpmat_2a idealpower!*(dpmat_from_a reval m,l)
  else idealpower!*(m,l);

symbolic procedure matop!=shiftdegs(d,n);
% Shift column degrees d n places.
   for each x in d collect ((car x + n) . cdr x);

symbolic procedure directsum!* l;
% Returns the direct sum of the modules in the dpmat list l. 
  if null l then rederr"Empty DPMAT list"
  else (begin scalar r,c,u;
    for each x in l do
        if not eqcar(x,'dpmat) then typerr(x,"DPMAT")
        else if dpmat_cols x=0 then 
                rederr"DIRECTSUM only for modules";
    c:=r:=0; % Actual column resp. row index.
    cali!=degrees:=nil;
    for each x in l do
       << cali!=degrees:=append(cali!=degrees,
                        matop!=shiftdegs(dpmat_coldegs x,c));
          u:=append(u, for each y in dpmat_list x collect
                bas_make(bas_nr y + r,dp_times_ei(c,bas_dpoly y)));
          r:=r + dpmat_rows x;
          c:=c + dpmat_cols x;
        >>;             
    return dpmat_make(r,c,u,cali!=degrees,nil)
    end) where cali!=degrees:=cali!=degrees;

put('directsum,'psopfn,'matop!=directsum);
symbolic procedure matop!=directsum l;
% Returns the direct sum of the modules in the list l.
  dpmat_2a directsum!* for each x in l collect dpmat_from_a reval x; 

symbolic operator deleteunits;
symbolic procedure deleteunits m;
  if !*noetherian then m
  else if !*mode='algebraic then dpmat_2a deleteunits!* dpmat_from_a m
  else deleteunits!* m;
  
symbolic procedure deleteunits!* m;
% Delete units from the base elements of the ideal m.
  if !*noetherian or (dpmat_cols m>0) then m
  else dpmat_make(dpmat_rows m,0,
        for each x in dpmat_list m collect 
                bas_factorunits x,nil,dpmat_gbtag m);
    
symbolic procedure interreduce!* m;
  (begin scalar u,c; 
  u:=red_interreduce dpmat_list m;
  return dpmat_make(length u, dpmat_cols m, bas_renumber u,
                cali!=degrees, dpmat_gbtag m) 
  end)  where cali!=degrees:=dpmat_coldegs m;

symbolic operator interreduce;
symbolic procedure interreduce m;
% Interreduce m.
  if !*mode='algebraic then 
        dpmat_2a interreduce!* dpmat_from_a reval m
  else interreduce!* m;

symbolic procedure gbasis!* m; 
% Produce a minimal Groebner or standard basis of the dpmat m.
  if dpmat_gbtag m then m else car groeb_stbasis(m,t,nil,nil);

put('tangentcone,'psopfn,'matop!=tangentcone);
symbolic procedure matop!=tangentcone m;
  begin scalar c;
  intf_test m; m:=car m; intf_get m;
  if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  c:=tangentcone!* c;
  return dpmat_2a c;
  end;

symbolic procedure tangentcone!* m;
% Returns the tangent cone of m, provided the term order has degrees.
% m must be a gbasis.
  if null ring_degrees cali!=basering then
        rederr"tangent cone only for degree orders defined"
  else (begin scalar b;
  b:=for each x in dpmat_list m collect
    bas_make(bas_nr x,dp_tcpart bas_dpoly x);
  return dpmat_make(dpmat_rows m,
        dpmat_cols m,b,cali!=degrees,dpmat_gbtag m);
  end)  where cali!=degrees:=dpmat_coldegs m;


symbolic procedure syzygies1!* bas; 
% Returns the (not yet interreduced first) syzygy module of the dpmat
% bas.
  begin 
  if cali_trace() > 0 then 
    << terpri(); write" Compute syzygies"; terpri() >>; 
  return third groeb_stbasis(bas,nil,nil,t);
  end;

symbolic procedure syzygies!* bas; 
% Returns the interreduced syzygy basis.
  interreduce!* syzygies1!* bas;

symbolic procedure normalform!*(a,b);
% Returns {a1,r,z} with a1=z*a-r*b where the rows of the dpmat a1 are
% the normalforms of the rows of the dpmat a with respect to the
% dpmat b.
   if not(eqn(dpmat_cols a,dpmat_cols b) and 
        equal(dpmat_coldegs a,dpmat_coldegs b)) then 
                rederr"dpmats don't match for NORMALFORM"
   else (begin scalar a1,z,u,r;
      bas_setrelations dpmat_list b;
      a1:=for each x in dpmat_list a collect
        << u:=red_redpol(dpmat_list b,x);
           z:=bas_make(bas_nr x,dp_times_ei(bas_nr x,cdr u)).z;
           car u
        >>;
      r:=bas_getrelations a1; bas_removerelations a1; 
      bas_removerelations dpmat_list b; z:=reversip z;
      a1:=dpmat_make(dpmat_rows a,dpmat_cols a,a1,cali!=degrees,nil);
      cali!=degrees:=dpmat_rowdegrees b;
      r:=dpmat_make(dpmat_rows a,dpmat_rows b,bas_neworder r,
                            cali!=degrees,nil);
      cali!=degrees:=nil;
      z:=dpmat_make(dpmat_rows a,dpmat_rows a,bas_neworder z,nil,nil);
      return  {a1,r,z};
      end)  where cali!=degrees:=dpmat_coldegs b;

symbolic procedure matop_pseudomod(a,b); car mod!*(a,b);
  
symbolic procedure mod!*(a,b);
% Returns the normal form of the dpoly a modulo the dpmat b and the
% corresponding unit produced during pseudo division.
  (begin scalar a1,z,u,r;
      a:=dp_neworder a; % to be on the safe side.
      u:=red_redpol(dpmat_list b,bas_make(0,a));
      return (bas_dpoly car u) . cdr u;
  end)  where cali!=degrees:=dpmat_coldegs b;
      
symbolic operator mod;
symbolic procedure mod(a,b);
% True normal form as s.q. also for matrices.
  if !*mode='symbolic then rederr"only for algebraic mode"
  else begin scalar u;
    b:=dpmat_from_a reval b; a:=reval a;
    if eqcar(a,'list) then 
        if dpmat_cols b>0 then rederr"entries don't match for MOD"
        else a:=makelist for each x in cdr a collect
           << u:=mod!*(dp_from_a x, b); 
              {'quotient,dp_2a car u,dp_2a cdr u}
           >>
    else if eqcar(a,'mat) then 
        begin a:=dpmat_from_a a;
        if dpmat_cols a neq dpmat_cols b then 
                rederr"entries don't match for MOD";
        a:=for each x in dpmat_list a collect mod!*(bas_dpoly x,b);
        a:='mat. 
            for each x in a collect 
              << u:=dp_2a cdr x;
                 for i:=1:dpmat_cols b collect
                    {'quotient,dp_2a dp_comp(i,car x),u}
              >>
        end            
    else if dpmat_cols b>0 then rederr"entries don't match for MOD"
    else << u:=mod!*(dp_from_a a, b); 
            a:={'quotient,dp_2a car u,dp_2a cdr u}
          >>;
    return a;
    end;
    
infix mod;

symbolic operator normalform;
symbolic procedure normalform(a,b);
% Compute a normal form of the rows of a with respect to b :
%   first result = third result * a + second result * b.
  if !*mode='algebraic then
  begin scalar m;
  m:= normalform!*(dpmat_from_a reval a,dpmat_from_a reval b); 
  return {'list,dpmat_2a car m, dpmat_2a cadr m, dpmat_2a caddr m}
  end
  else normalform!*(a,b);

symbolic procedure eliminate!*(m,vars);
% Returns a (dpmat) basis of the elimination module of the dpmat m
% eliminating variables contained in the var. list vars.
% It sets temporary the standard elimination term order, but doesn't
% affect the ecart, and computes a Groebner basis of m.

%  if dpmat_gbtag m and eo(vars) then dpmat_sieve(m,vars,t) else

   (begin scalar c,e,bas,v,r;
   c:=cali!=basering; e:=ring_ecart c;
   v:=ring_names cali!=basering;
   setring!* ring_define(v,eliminationorder!*(v,vars),'revlex,e);
   cali!=degrees:=nil; % No degrees for proper result !!
   bas:=(bas_sieve(dpmat_list 
            car groeb_stbasis(dpmat_neworder(m,nil),t,nil,nil), vars)
            where !*noetherian=t);            
   setring!* c; cali!=degrees:=dpmat_coldegs m;
   return dpmat_make(length bas,dpmat_cols m,bas_neworder bas,
                            cali!=degrees,nil);
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

symbolic operator eliminate;
symbolic procedure eliminate(m,l);
% Returns the elimination ideal/module of m with respect to the
% variables in the list l to be eliminated.
  if !*mode='algebraic then
  begin l:=reval l;
    if not eqcar(l,'list) then typerr(l,"variable list");
    m:=dpmat_from_a m; l:=cdr l;
    return dpmat_2a eliminate!*(m,l);
  end
  else eliminate!*(m,l);

symbolic procedure matintersect!* l;
  if null l then rederr"MATINTERSECT with empty list"
  else if length l=1 then car l
  else (begin scalar c,u,v,p,size;
    matop!=testdpmatlist l;
    size:=dpmat_cols car l;
    v:=for each x in l collect gensym();
    c:=cali!=basering;
    setring!* ring_sum(c,
        ring_define(v,degreeorder!* v,'lex,for each x in v collect 1));
    cali!=degrees:=mo_degneworder dpmat_coldegs car l;
    u:=for each x in pair(v,l) collect
        dpmat_times_dpoly(dp_from_a car x,dpmat_neworder(cdr x,nil));
    p:=dp_fi 1; for each x in v do p:=dp_diff(p,dp_from_a x);
    if size=0 then p:=dpmat_from_dpoly p
    else p:=dpmat_times_dpoly(p,dpmat_unit(size,cali!=degrees));
    p:=gbasis!* matsum!* (p . u);
    p:=dpmat_sieve(p,v,t);
    setring!* c;
    cali!=degrees:=dpmat_coldegs car l;
    return dpmat_neworder(p,t);
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

put('matintersect,'psopfn,'matop!=matintersect);
put('idealintersect,'psopfn,'matop!=matintersect);
symbolic procedure matop!=matintersect l;
% Returns the intersection of the submodules of a fixed free module
% in the list l.
  dpmat_2a matintersect!* for each x in l collect dpmat_from_a reval x; 


% ------- Submodule property and equality test --------------

put('modequalp,'psopfn,'matop!=equalp);
% Test, whether a and b are module equal. 
symbolic procedure matop!=equalp u;
  if length u neq 2 then rederr"Syntax : MODEQUALP(dpmat,dpmat) "
  else begin scalar a,b;
    intf_get first u; intf_get second u;
    if null(a:=get(first u,'gbasis)) then 
	put(first u,'gbasis,a:=gbasis!* get(first u,'basis));  
    if null(b:=get(second u,'gbasis)) then
	put(second u,'gbasis,b:=gbasis!* get(second u,'basis));  
    if modequalp!*(a,b) then return 'yes else return 'no
    end;

symbolic procedure modequalp!*(a,b);
  submodulep!*(a,b) and submodulep!*(b,a);

put('submodulep,'psopfn,'matop!=submodulep);
% Test, whether a is a submodule of b. 
symbolic procedure matop!=submodulep u;
  if length u neq 2 then rederr"Syntax : SUBMODULEP(dpmat,dpmat)"
  else begin scalar a,b;
    intf_get second u; 
    if null(b:=get(second u,'gbasis)) then
	put(second u,'gbasis,b:=gbasis!* get(second u,'basis));  
    a:=dpmat_from_a reval first u;            
    if submodulep!*(a,b) then return 'yes else return 'no
    end;
  
symbolic procedure submodulep!*(a,b);
  if not(dpmat_cols a=dpmat_cols b
     and equal(dpmat_coldegs a,dpmat_coldegs b)) then 
    rederr"incompatible modules in SUBMODULEP"
  else (begin
    a:=for each x in dpmat_list a collect bas_dpoly x;
    return not listtest(a,b,function matop_pseudomod)
    end) where cali!=degrees:=dpmat_coldegs a;

endmodule; % matop

module quot;

COMMENT

                #################
                #               #
                #   QUOTIENTS   #
                #               #
                #################
                
                
This module contains algorithms for different kinds of quotients of
ideals and modules.

END COMMENT;

% -------- Quotient of a module by a polynomial -----------
% Returns m : (f) for a polynomial f.

symbolic operator matquot;
symbolic procedure matquot(m,f);
  if !*mode='algebraic then
     if eqcar(f,'list) or eqcar(f,'mat) then
                rederr("Syntax : matquot(dpmat,dpoly)")
     else dpmat_2a matquot!*(dpmat_from_a reval m,dp_from_a reval f)
  else matquot!*(m,f);

symbolic procedure matquot!*(m,f);
  if dp_unit!? f then m
  else if dpmat_cols m=0 then mat2list!* quot!=quot(ideal2mat!* m,f)
  else quot!=quot(m,f);

symbolic procedure quot!=quot(m,f);
% Note that, if a is a gbasis, then also b.
  begin scalar a,b;
  a:=matintersect!* {m,
    dpmat_times_dpoly(f,dpmat_unit(dpmat_cols m,dpmat_coldegs m))};
  b:=for each x in dpmat_list a collect 
    bas_make(bas_nr x,car dp_pseudodivmod(bas_dpoly x,f));
  return dpmat_make(dpmat_rows a,dpmat_cols a,b,
		dpmat_coldegs m,dpmat_gbtag a);
  end;

% -------- Quotient of a module by an ideal -----------
% Returns m:n as a module.

symbolic operator idealquotient;
symbolic procedure idealquotient(m,n);
  if !*mode='algebraic then
        dpmat_2a idealquotient2!*(dpmat_from_a reval m,
                            dpmat_from_a reval n)
  else idealquotient2!*(m,n);

% -------- Quotient of a module by another module  -----------
% Returns m:n as an ideal in S. m and n must be submodules of a common
% free module.

symbolic operator modulequotient;
symbolic procedure modulequotient(m,n);
  if !*mode='algebraic then 
        dpmat_2a modulequotient2!*(dpmat_from_a reval m,
                            dpmat_from_a reval n)
  else modulequotient2!*(m,n);

% ---- The annihilator of a module, i.e. Ann coker M := M : F ---

symbolic operator annihilator;
symbolic procedure annihilator m;
  if !*mode='algebraic then 
        dpmat_2a annihilator2!* dpmat_from_a reval m
  else annihilator2!* m;
  
% ---- Quotients as M:N = \intersect { M:f | f \in N } ------

symbolic procedure idealquotient2!*(m,n);
  if dpmat_cols n>0 then rederr"Syntax : idealquotient(dpmat,ideal)"
  else if dpmat_cols m=0 then modulequotient2!*(m,n)
  else matintersect!* for each x in dpmat_list n collect
        quot!=quot(m,bas_dpoly x);

symbolic procedure modulequotient2!*(m,n);
  (begin scalar c;
  if not((c:=dpmat_cols m)=dpmat_cols n) then rederr 
    "MODULEQUOTIENT only for submodules of a common free module";
  if not equal(dpmat_coldegs m,dpmat_coldegs n) then
          rederr"matrices don't match for MODULEQUOTIENT";
  if (c=0) then << m:=ideal2mat!* m; n:=ideal2mat!* n >>;
  cali!=degrees:=dpmat_coldegs m;
  n:=for each x in dpmat_list n collect matop_pseudomod(bas_dpoly x,m);
  n:=for each x in n join if x then {x};
  return if null n then dpmat_from_dpoly dp_fi 1
  else matintersect!* for each x in n collect quot!=mquot(m,x);
  end) where cali!=degrees:=cali!=degrees;

symbolic procedure quot!=mquot(m,f);
  begin scalar a,b;
  a:=matintersect!* 
    {m,dpmat_make(1,dpmat_cols m,list bas_make(1,f),dpmat_coldegs m,t)};
  b:=for each x in dpmat_list a collect 
    bas_make(bas_nr x,car dp_pseudodivmod(bas_dpoly x,f));
  return dpmat_make(dpmat_rows a,0,b,nil,nil);
  end;

symbolic procedure annihilator2!* m;
  if dpmat_cols m=0 then m
  else modulequotient2!*(m,dpmat_unit(dpmat_cols m,dpmat_coldegs m));

% -------- Quotients by the general element method --------

symbolic procedure idealquotient1!*(m,n);
  if dpmat_cols n>0 then rederr "second parameter must be an ideal"
  else if dpmat_cols m=0 then modulequotient1!*(m,n)
  else (begin scalar u1,u2,f,v,r,m1; 
  v:=list gensym(); r:=cali!=basering;
  setring!* ring_sum(r,ring_define(v,degreeorder!* v,'revlex,'(1)));
  cali!=degrees:=mo_degneworder dpmat_coldegs m;
  n:=for each x in dpmat_list n collect dp_neworder x;
  u1:=u2:=dp_from_a car v; f:=car n;
  for each x in n do
        << f:=dp_sum(f,dp_prod(u1,x)); u1:=dp_prod(u1,u2) >>;
  m1:=dpmat_sieve(gbasis!* quot!=quot(dpmat_neworder(m,nil),f),v,t);
  setring!* r; cali!=degrees:=dpmat_coldegs m;
  return dpmat_neworder(m1,t);
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

symbolic procedure modulequotient1!*(m,n);
  (begin scalar c,u1,u2,f,v,r,m1;
  if not((c:=dpmat_cols m)=dpmat_cols n) then rederr 
    "MODULEQUOTIENT only for submodules of a common free module";
  if not equal(dpmat_coldegs m,dpmat_coldegs n) then
          rederr"matrices don't match for MODULEQUOTIENT";
  if (c=0) then << m:=ideal2mat!* m; n:=ideal2mat!* n >>;
  cali!=degrees:=dpmat_coldegs m;
  n:=for each x in dpmat_list n collect matop_pseudomod(bas_dpoly x,m);
  n:=for each x in n join if x then {x};
  if null n then return dpmat_from_dpoly dp_fi 1;
  v:=list gensym(); r:=cali!=basering;
  setring!* ring_sum(r,ring_define(v,degreeorder!* v,'revlex,'(1)));
  cali!=degrees:=mo_degneworder cali!=degrees;
  u1:=u2:=dp_from_a car v; f:=dp_neworder car n;
  for each x in n do 
     << f:=dp_sum(f,dp_prod(u1,dp_neworder x)); 
        u1:=dp_prod(u1,u2) 
     >>;
  m1:=dpmat_sieve(gbasis!* quot!=mquot(dpmat_neworder(m,nil),f),v,t);
  setring!* r; cali!=degrees:=dpmat_coldegs m;
  return dpmat_neworder(m1,t);
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

symbolic procedure annihilator1!* m;
  if dpmat_cols m=0 then m
  else modulequotient1!*(m,dpmat_unit(dpmat_cols m,dpmat_coldegs m));

% --------------- Stable quotients ------------------------

symbolic operator matqquot;
symbolic procedure matqquot(m,f);
% Stable quotient of dpmat m with respect to a polynomial f, i.e.
% m : <f> = { v \in F | \exists n : f^n*v \in m } 
  if !*mode='algebraic then
     if eqcar(f,'list) or eqcar(f,'mat) then
                rederr("Syntax : matquot(dpmat,dpoly)")
     else dpmat_2a matqquot!*(dpmat_from_a reval m,dp_from_a reval f)
  else matqquot!*(m,f);

symbolic procedure matqquot!*(m,f);
  if dp_unit!? f then m
  else if dpmat_cols m=0 then 
        mat2list!* quot!=stabquot(ideal2mat!* m,{f})
  else quot!=stabquot(m,{f});

symbolic operator matstabquot;
symbolic procedure matstabquot(m,f);
% Stable quotient of dpmat m with respect to an ideal f.
  if !*mode='algebraic then dpmat_2a 
        matstabquot!*(dpmat_from_a reval m,dpmat_from_a reval f)
  else matstabquot!*(m,f);

symbolic procedure matstabquot!*(m,f);
  if dpmat_cols f > 0 then rederr "stable quotient only by ideals"
  else begin scalar c;
    if (c:=dpmat_cols m)=0 then
        << f:=for each x in dpmat_list f collect 
                    matop_pseudomod(bas_dpoly x,m);
           f:=for each x in f join if x then {x} 
        >>
    else f:=for each x in dpmat_list f collect bas_dpoly x;
    if null f then return
        if c=0 then dpmat_from_dpoly dp_fi 1
        else dpmat_unit(c,dpmat_coldegs m);
    if dp_unit!? car f then return m;
    if c=0 then return mat2list!* quot!=stabquot(ideal2mat!* m,f)
    else return quot!=stabquot(m,f);
    end;

symbolic procedure quot!=stabquot(m,f);
% m must be a module.
  if dpmat_cols m=0 then rederr"quot_stabquot only for cols>0"
  else (begin scalar m1,p,p1,p2,v,v1,v2,c;
    v1:=gensym(); v2:=gensym(); v:={v1,v2};
    setring!* ring_sum(c:=cali!=basering,
        ring_define(v,degreeorder!* v,'lex,'(1 1)));
    cali!=degrees:=mo_degneworder dpmat_coldegs m;
    p1:=p2:=dp_from_a v1; 
    f:=for each x in f collect dp_neworder x;
    p:=car f;
    for each x in cdr f do 
    << p:=dp_sum(dp_prod(p1,x),p); p1:=dp_prod(p1,p2) >>; 
    p:=dp_diff(dp_fi 1,dp_prod(dp_from_a v2,p));
        % p = 1 - v2 * \sum{f_i * v1^i}
    m1:=matsum!* {dpmat_neworder(m,nil), 
	dpmat_times_dpoly(p,
		dpmat_unit(dpmat_cols m,cali!=degrees))};
    m1:=dpmat_sieve(gbasis!* m1,v,t);
    setring!* c; cali!=degrees:=dpmat_coldegs m;
    return dpmat_neworder(m1,t);
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

endmodule; % quot

module moid; 

COMMENT

               ###########################
               ##                       ##
               ##     MONOMIAL IDEALS	##     
               ##                       ##
               ###########################

This module supports computations with leading term ideals. Moideal
monomials are assumed to be without module component, since a module
moideal decomposes into the direct sum of ideal moideals.  

Lit.:
[BS] Bayer, Stillman : J. Symb. Comp. 14 (1992), 31 - 50.

This module contains :
        
        - A moideal prime decomposition along [BS]
       
        - An algorithm to find all strongly independent sets using
                moideal primes (also for modules),
                
        - An algorithm to compute the dimension (dim M := dim in(M))
                based on strongly independent sets.

	- An easy dimension computation, correct for puredimensional
		ideals and modules.

Monomial ideals have the following informal syntax :

        <moideal> ::= list of monomials

To manage module moideals they are stored as assoc. list of 

	(<component number> . <ideal moideal>) 

Moideals are kept ordered with respect to the descending lexicographic
order, see [BS].

END COMMENT;

% ------------- monomial ideal constructors --------------

symbolic procedure moid_from_bas bas; 
% Returns the list of leading monomials of the base list bas
% not removing module components.
   for each x in bas_zerodelete bas collect dp_lmon bas_dpoly x;

symbolic procedure moid_from_dpmat m;
% Returns the assoc. list of moideals of the columns of the dpmat m.
  (if dpmat_cols m = 0 then list (0 . u)
  else for i:=1:dpmat_cols m collect
     i . for each x in u join if mo_comp(x)=i then {mo_deletecomp x})
  where u=moid_from_bas dpmat_list m;

symbolic procedure moid_2a m;
% Convert the moideal m to algebraic mode.
  'list . for each x in m collect dp_2a list dp_term(bc_fi 1,x);  

symbolic procedure moid_from_a m;
% Convert a moideal from algebraic mode.
  if not eqcar(m,'list) then typerr(m,"moideal")
  else for each x in cdr m collect dp_lmon dp_from_a x;

symbolic procedure moid_print m; mathprint moid_2a m;

% ------- moideal arithmetics ------------------------

symbolic procedure moid_sum(a,b); 
% (Reduced) sum of two (v)moideals.
  moid_red append(a,b);

symbolic procedure moid_intersect(a,b);
% Intersection of two (pure !) moideals.
  begin scalar c;
  while b do
    << c:=nconc(for each x in a collect mo_lcm(x,car b),c);
       b:=cdr b
    >>;
  return moid_red c
  end;

symbolic procedure moid_sort m; 
% Sorting by descending (pure) lexicographic order, first by mo_comp.
   sort(m,function mo_dlexcomp);

symbolic procedure moid_red m; 
% Returns a minimal generating set of the (v)moideal m.
  moid!=red moid_sort m;

symbolic procedure moid!=red m;
  begin scalar v;
  while m do 
    << if not moid_member(car m,cdr m) then v:=car m . v;
       m:=cdr m;
    >>;
  return reversip v;
  end;

symbolic procedure moid_member(mo,m);
% true <=> c \in m vdivides mo.
  if null m then nil
  else mo_vdivides!?(car m,mo) or moid_member(mo,cdr m);

symbolic procedure moid_radical u; 
% Returns the radical of the (pure) moideal u.
  moid_red for each x in u collect mo_radical x;

symbolic procedure moid_quot(m,x); 
% The quotient of the moideal m by the monomial x.
  moid_red for each u in m collect mo_diff(u,mo_gcd(u,x));

% --------------- moideal prime decomposition --------------
% Returns the minimal primes of the moideal m as a list of variable
% lists. 

symbolic procedure moid_primes m;
  begin scalar c,m1,m2;
    m:=listminimize(for each x in m collect mo_support x, 
                function subsetp); 
    for each x in m do 
        if length x=1 then m1:=car x . m1 
        else m2:=x . m2;
    return for each x in moid!=primes(m2,ring_names cali!=basering)
        collect append(m1,x);
  end;      
    
symbolic procedure moid!=primes(m,vars);
  if null m then list nil
  else begin scalar b,c,vars1; b:=t;
    for each x in m do b:=b and intersection(x,vars);
    if not b then return nil; 
    return listminimize(
        for each x in intersection(car m,vars) join
        for each y in moid!=primes(moid!=sps(x,cdr m),
              vars:=delete(x,vars)) collect x . y,
        function subsetp);
  end;          
  
symbolic procedure moid!=sps(x,m);
  for each y in m join if not memq(x,y) then {y};


% ------------ (Strongly) independent sets -----------------

symbolic procedure moid_max l;
  if null l then nil
  else car sort(l,function (lambda(x,y);length x >= length y));


symbolic procedure indepvarsets!* m;
% Returns the sets of (strongly) independent variables for the 
% dpmat m. m must be a Groebner basis.  
  begin scalar u,n;
    u:=listminimize(
        for each x in moid_from_dpmat m join moid_primes cdr x,
        function subsetp);
    n:=ring_names cali!=basering;
    return for each x in u collect setdiff(n,x);
  end;

% ---------- Dimension and codimension ------------

symbolic procedure moid_goodindepvarset m;
% Returns the lexicographically last maximal independent set of the
% dpmat m. 
  begin scalar l,n,l1;
    l:=sort(indepvarsets!* m,
                function (lambda(x,y);length x >= length y));
    if null l then return nil;
    n:=length first l;
    l:=for each x in l join if length x = n then {x};
    for each x in reverse ring_names cali!=basering do
        if length l>1 then
        << l1:=for each y in l join if member(x,y) then {y};
           if l1 then l:=l1;
        >>;
    return first l;
    end;

symbolic procedure dim!* m;
% The dpmat m must be a Groebner basis. Computes the dimension of
% Coker m as the greatest size of a strongly independent set.
  if not eqcar(m,'dpmat) then typerr(m,"DPMAT")
  else length moid_max indepvarsets!* m;

symbolic procedure codim!* m; 
  length ring_names cali!=basering - dim!* m;

% ---- An easy independent set procedure -------------

symbolic operator easyindepset;
symbolic procedure easyindepset m;
  if !*mode='algebraic then 
        makelist easyindepset!* dpmat_from_a reval m
  else easyindepset!* m;

symbolic procedure easyindepset!* m;
% Returns a maximal with respect to inclusion independent set for the
% moideal m.
  begin scalar b,c,d;
    m:=for each x in m collect mo_support x;
    b:=c:=ring_names cali!=basering;
    for each x in b do if moid!=ept(d:=delete(x,c),m) then c:=d;
    return setdiff(ring_names cali!=basering,c);
  end;
  
symbolic procedure moid!=ept(l,m);
  if null m then t
  else intersection(l,car m) and moid!=ept(l,cdr m);       

symbolic operator easydim;
symbolic procedure easydim m;
  if !*mode='algebraic then easydim!* dpmat_from_a reval m
  else easydim!* m;

symbolic procedure easydim!* m;
% Returns a lower bound for the dimension. The bound is true for
% unmixed ideals (e.g. primes). m must be a gbasis.
  if not eqcar(m,'dpmat) then typerr(m,"DPMAT")
  else listexpand(function max2,
        for each x in moid_from_dpmat m collect 
            length easyindepset!* cdr x);
  
endmodule; % moid


module hf;

COMMENT

               ###################################
               ##				##
               ##    WEIGHTED HILBERT SERIES	##     
               ##				##
               ###################################

This module supports (weighted) Hilbert series computations and
related topics. It contains

        - Two algorithms computing Hilbert series of ideals and
                modules. 

Lit.: 

[BS]	Bayer, Stillman : J. Symb. Comp. 14 (1992), 31 - 50.

[BCRT]  Bigatti, Conti, Robbiano, Traverso . LNCS 673 (1993), 76 - 88. 
      
The version of the algorithm is chosen through the 'hf!=hf entry on
the property list of 'cali.

END COMMENT;

% Choosing the version of the algorithm and first initialization :

put('cali,'hf!=hf,'hf!=whilb1);

symbolic operator hftestversion;
symbolic procedure hftestversion n; 
  if member(n,{1,2}) then 
	put('cali,'hf!=hf,mkid('hf!=whilb,n));

% --- first variant : [BS]

symbolic procedure hf!=whilb1(m,w);
% Compute the weighted Hilbert series of the moideal m by the rule
% H(m + (M)) = H((M)) - t^ec(m) * H((M):m)
   if null m then dp_fi 1
   else begin scalar m1,m2;
    for each x in m do
        if mo_linear x then m1:=x . m1 else m2:=x . m2;
    if null m2 then return hf!=whilbmon(m1,w)
    else if null cdr m2 then return hf!=whilbmon(car m2 . m1,w)
    else if hf!=powers m2 then return hf!=whilbmon(append(m1,m2),w)
    else return dp_prod(hf!=whilbmon(m1,w),
            dp_diff(hf!=whilb1(cdr m2,w),
                    dp_times_mo(mo_wconvert(car m2,w),
                        hf!=whilb1(moid_quot(cdr m2,car m2),w))));
    end;

symbolic procedure hf!=whilbmon(m,w); 
% Returns the product of the converted dpolys 1 - mo for the 
% monomials mo in m.
   if null m then dp_fi 1
   else begin scalar p; 
    m:=for each x in m collect 
        dp_sum(dp_fi 1,list dp_term(bc_fi(-1),mo_wconvert(x,w)));
    p:=car m;
    for each x in cdr m do p:=dp_prod(p,x);
    return p;
    end;

symbolic procedure hf!=powers m;
% m contains only powers of variables.
  if null m then t
  else (length mo_support car m<2) and hf!=powers cdr m;

Comment 

Second variant : by induction on the number of variables using the
exactness of the sequence 

	0 --> S/(I:(x))[-deg x] --> S/I --> S/(I+(x)) --> 0

[BCRT] do even better, choosing x not as variable, but as splitting
monomial. I hope to return to that later on.

end comment;

symbolic procedure hf!=whilb2(m,w); 
  if null m then dp_fi 1
   else begin scalar m1,m2,x,p;
    for each x in m do
        if mo_linear x then m1:=x . m1 else m2:=x . m2;
    if null m2 then return hf!=whilbmon(m1,w)
    else if null cdr m2 then return hf!=whilbmon(car m2 . m1,w)
    else if hf!=powers m2 then return hf!=whilbmon(append(m1,m2),w)
    else begin scalar x;
        x:=mo_from_a car mo_support car m2;
        p:=dp_prod(hf!=whilbmon(m1,w),
            dp_sum(hf!=whilb2(moid_red(x . m2),w),
            dp_times_mo(mo_wconvert(x,w), 
                hf!=whilb2(moid_quot(m2,x),w))))
        end;
    return p;
    end;
        
% -------- Weighted Hilbert series from a free resolution --------

symbolic procedure hf_whilb3(u,w);
% Weighted Hilbert series numerator from the resolution u.
  begin scalar sgn,p; sgn:=t;
  for each x in u do
    << if sgn then p:=dp_sum(p,hf!=whilb3(x,w))
       else p:=dp_diff(p,hf!=whilb3(x,w));
       sgn:=not sgn;
    >>;
  return p;
  end;

symbolic procedure hf!=whilb3(u,w);
% Convert column degrees of the dpmat u to a generating polynomial.
  (if length c = dpmat_cols u then 
   begin scalar p;
      for each x in c do 
	p:=dp_sum(p,{dp_term(bc_fi 1,mo_wconvert(cdr x,w))});
      return p
   end else dp_fi max(1,dpmat_cols u))
  where c:=dpmat_coldegs u;

% ------- The common interface ----------------

symbolic procedure hf_whilb(m,wt);
% Returns the weighted Hilbert series numerator of the dpmat m as
% a dpoly using the internal Hilbert series computation 
% get('cali,'hf!=hf) for moideals. m must be a Groebner basis.
  (begin scalar fn,w,lt,p,p1; integer i;
  if null(fn:=get('cali,'hf!=hf)) then 
	rederr"No version for the Hilbert function algorithm chosen";
  if dpmat_cols m = 0 then 
	return apply2(fn,moid_from_bas dpmat_list m,wt);
    lt:=moid_from_dpmat m;
    for i:=1:dpmat_cols m do
      << p1:=atsoc(i,lt);
         if null p1 then rederr"WHILB with wrong leading term list"
         else p1:=apply2(fn,cdr p1,wt); 
         w:=atsoc(i,cali!=degrees);
         if w then p1:=dp_times_mo(mo_wconvert(cdr w,wt),p1);
         p:=dp_sum(p,p1);
       >>;
    return p;
    end) where cali!=degrees:=dpmat_coldegs m;

symbolic procedure hf!=whilb2hs(h,w);
% Converts the Hilbert series numerator h into a rational expression
% with denom = prod ( 1-w(x) | x in ringvars ) and cancels common
% factors. Uses gcdf and returns a s.q.
  begin scalar a,b,g,den,num;
  num:=numr simp dp_2a h;       % This is the numerator as a s.f. 
  den:=1;
  for each x in ring_names cali!=basering do
  << a:=numr simp dp_2a hf!=whilbmon({mo_from_a x},w);
     g:=gcdf!*(num,a);
     num:=quotf(num,g); den:=multf(den,quotf(a,g));
  >>;
  return num ./ den;
  end;
  
symbolic procedure weightedhilbertseries!*(m,w); 
% m must be a Gbasis.
  hf!=whilb2hs(hf_whilb(m,w),w);

symbolic procedure hf_whs_from_resolution(u,w); 
% u must be a resolution.
  hf!=whilb2hs(hf_whilb3(u,w),w);

symbolic procedure hilbertseries!* m; 
% m must be a Gbasis.
  weightedhilbertseries!*(m,{ring_ecart cali!=basering});

% --------- Multiplicity and dimension ---------------------

symbolic procedure hf_mult n; 
% Get the sum of the coefficients of the s.f. (car n). For homogeneous
% ideals and "good" weight vectors this is the multiplicity. 
   prepf absf hf!=sum_up car n;

symbolic procedure hf!=sum_up f;
   if numberp f then f else hf!=sum_up car subf(f,list (mvar f . 1));

symbolic procedure hf_dim f; 
% Returns the dimension as the pole order at 1 of the HF f.
  if domainp denr f then 0
  else begin scalar g,x,d; integer n;
    f:=denr f; x:=mvar f; n:=0; d:=(((x.1).-1).1); 
    while null cdr (g:=qremf(f,d)) do
        << n:=n+1; f:=car g >>;
    return n;
    end;      

symbolic procedure degree!* m; hf_mult hilbertseries!* m;

% ------- Algebraic Mode Interface for weighted Hilbert series. 

symbolic operator weightedhilbertseries;
symbolic procedure weightedhilbertseries(m,w);
% m must be a gbasis, w a list of weight lists.
  if !*mode='algebraic then
  begin scalar w1,l;
  w1:=for each x in cdr reval w collect cdr x;
  l:=length ring_names cali!=basering;
  for each x in w1 do 
        if (not numberlistp x) or (length x neq l) 
                then typerr(w,"weight list");
  m:=dpmat_from_a reval m;
  l:=mk!*sq weightedhilbertseries!*(m,w1);
  return l;
  end else weightedhilbertseries!*(m,w);
  
endmodule; % hf


module res; 

COMMENT

          ######################
          ###                ###
          ###   RESOLUTIONS  ###     
          ###                ###
          ######################

This module contains algorithms on complexes, i.e. chains of modules
(submodules of free modules represented as im f of certain dpmat's). 

A chain (in particular a resolution) is a list of dpmat's with the
usual annihilation property of subsequent dpmat's.

This module contains

        - An algorithm to compute a minimal resolution of a dpmat,

        - the same for a local dpmat.
                
        - the extraction of the (graded) Betti numbers from a
                resolution. 
        
This module is just under development.
                        
END COMMENT;

% ------------- Minimal resolutions --------------

symbolic procedure Resolve!*(m,d); 
% Compute a minimal resolution of the dpmat m, i.e. a list of dpmat's
% (s0 s1 s2 ...), where sk is the k-th syzygy module of m, upto the
% d'th part.
  (begin scalar a,u; 
  if dpmat_cols m=0 then
    << cali!=degrees:=nil; m:=ideal2mat!* m>>
  else cali!=degrees:=dpmat_coldegs m; 
  a:=list(m); u:=syzygies!* m;
  while (not dpmat_zero!? u)and(d>1) do
    << m:=u; u:=syzygies!* m; d:=d-1;
       u:=groeb_minimize(m,u); m:=car u; u:=cdr u; a:=m . a; 
    >>;
  return reversip (u.a);
  end) where cali!=degrees:=cali!=degrees;

% ----------------- The Betti numbers -------------

symbolic procedure bettiNumbers!* c;
% Returns the list of Betti numbers of the chain c.
   for each x in c collect dpmat_cols x;

symbolic procedure gradedBettiNumbers!* c;
% Returns the list of degree lists (according to the ecart) of the
% generators of the chain c.
  for each x in c collect
     begin scalar i,d; d:=dpmat_coldegs x;
        return 
    if d then sort(for each y in d collect mo_ecart cdr y,'leq)
        else for i:=1:dpmat_cols x collect 0;
     end;

endmodule; % res


module intf; 

COMMENT 

            #####################################
            ###                               ###
            ###  INTERFACE TO ALGEBRAIC MODE  ###
            ###                               ###
            #####################################


  There are two types of procedures :
  
  The first type takes polynomial lists or polynomial matrices as
  input, converts them into dpmats, computes the result and
  reconverts it to algebraic mode.

  The second type is property driven, i.e. Basis, Gbasis, Syzygies
  etc. are attached via properties to an identifier. 
  For them, the 'ring property watches, that cali!=basering hasn't
  changed (including the term order). Otherwise the results must be
  reevaluated using setideal(name,name) or setmodule(name,name) since
  otherwise results may become wrong.

   The switch "noetherian" controls whether the term order satisfies
   the chain condition (default is "on") and chooses either the
   groebner algorithm or the local standard basis algorithm.

END COMMENT;

% ----- The properties managed upto now ---------

fluid '(intf!=properties);

intf!=properties:='(basis ring gbasis syzygies resolution hs
			independentsets); 

% --- Some useful common symbolic procedures --------------

symbolic procedure intf!=clean u; 
% Removes all properties.
  for each x in intf!=properties do remprop(u,x);

symbolic procedure intf_test m;
  if (length m neq 1)or(not idp car m) then typerr(m,"identifier");
  
symbolic procedure intf_get m;  
% Get the 'basis.
  begin scalar c;
  if not (c:=get(m,'basis)) then typerr(m,"dpmat variable");
  if not equal(get(m,'ring),cali!=basering) then 
                rederr"invalid base ring";
  cali!=degrees:=dpmat_coldegs c;
  return c;
  end;

symbolic procedure intf!=set(m,v);
% Attach the dpmat value v to the variable m.
  << put(m,'ring,cali!=basering);
     put(m,'basis,v);
     if dpmat_cols v = 0 then
       << put(m,'rtype,'list); put(m,'avalue,'list.{dpmat_2a v})>>
     else 
       <<put(m,'rtype,'matrix); put(m,'avalue,'matrix.{dpmat_2a v})>>;
  >>;

% ------ setideal -------------------

put('setideal,'psopfn,'intf!=setideal);
symbolic procedure intf!=setideal u;
% setideal(name,base list)
  begin scalar l;
  if length u neq 2 then rederr "Syntax : setideal(identifier,ideal)"; 
  if not idp car u then typerr(car u,"ideal name");
  l:=reval cadr u;
  if not eqcar(l,'list) then typerr(l,"ideal basis");
  intf!=clean(car u); 
  put(car u,'ring,cali!=basering);
  put(car u,'basis,l:=dpmat_from_a l);
  put(car u,'avalue,'list.{l:=dpmat_2a l});
  put(car u,'rtype,'list);
  return l;
  end;

% --------------- setmodule -----------------------

put('setmodule,'psopfn,'intf!=setmodule);
symbolic procedure intf!=setmodule u;
% setmodule(name,matrix)
  begin scalar l;
  if length u neq 2 then 
        rederr "Syntax : setmodule(identifier,module basis)";
  if not idp car u then typerr(car u,"module name");
  l:=reval cadr u;
  if not eqcar(l,'mat) then typerr(l,"module basis");
  intf!=clean(car u);
  put(car u,'ring,cali!=basering);
  put(car u,'basis,dpmat_from_a l);
  put(car u,'avalue,'matrix.{l});
  put(car u,'rtype,'matrix);
  return l;
  end;

% ------------ setring ------------------------

put('setring,'psopfn,'intf!=setring);
% Setring(vars,term order degrees,tag <,ecart>) sets the internal
% variable cali!=basering. The term order is at first by the degrees
% and then by the tag. The tag must be LEX or REVLEX.
% If ecart is not supplied the ecart is set to the default, i.e. the
% first degree vector (noetherian degree order) or to (1 1 .. 1).
% The ring may also be supplied as a list of its arguments as e.g.
% output by "getring".
symbolic procedure intf!=setring u;
  begin
  if length u = 1 then u:=cdr reval car u;
  if not memq(length u,'(3 4)) then
    rederr "Syntax : setring(vars,term order,tag[,ecart])";
  setring!* ring_from_a ('list . u);
  return ring_2a cali!=basering;
  end;

% ----------- getring --------------------

put('getring,'psopfn,'intf!=getring);
% Get the base ring of an object as the algebraic list
% {vars,tord,tag,ecart}.

symbolic procedure intf!=getring u;
  if null u then ring_2a cali!=basering
  else begin scalar c; c:=get(car u,'ring);
    if null c then typerr(car u,"dpmat variable");
    return ring_2a c;
    end;


% ------- The algebraic interface -------------

symbolic operator ideal2mat;
symbolic procedure ideal2mat m;
% Convert the list of polynomials m into a matrix column.
  if !*mode='symbolic then rederr"only for algebraic mode"
  else if not eqcar(m,'list) then typerr(m,'list)
  else 'mat . for each x in cdr m collect {x};

symbolic operator mat2list;
symbolic procedure mat2list m;
% Flatten the matrix m.
  if !*mode='symbolic then rederr"only for algebraic mode"
  else if not eqcar(m,'mat) then typerr(m,'matrix)
  else 'list . for each x in cdr m join for each y in x collect y;

put('setgbasis,'psopfn,'intf!=setgbasis);
symbolic procedure intf!=setgbasis m;
% Say that the basis is already a Gbasis.
  begin scalar c;
  intf_test m; m:=car m; c:=intf_get m;
  put(m,'gbasis,c); 
  return reval m;
  end;

symbolic operator setdegrees;
symbolic procedure setdegrees m;
% Set a term list as actual column degrees. Execute this before
% setmodule to supply a module with prescribed column degrees.
  if !*mode='symbolic then rederr"only for algebraic mode"
  else begin scalar i,b;
  b:=moid_from_a reval m; i:=0;
  cali!=degrees:= for each x in b collect <<i:=i+1; i . x>>;
  return moid_2a for each x in cali!=degrees collect cdr x;
  end;

put('getdegrees,'psopfn,'intf!=getdegrees);
symbolic procedure intf!=getdegrees m;
  begin
  if m then <<intf_test m; intf_get car m>>;
  return moid_2a for each x in cali!=degrees collect cdr x
  end;

symbolic operator getecart;
symbolic procedure getecart;
  if !*mode='algebraic then makelist ring_ecart cali!=basering
  else ring_ecart cali!=basering;

put('gbasis,'psopfn,'intf!=gbasis);
symbolic procedure intf!=gbasis m;
  begin scalar c,c1;
  intf_test m; m:=car m; c1:=intf_get m;
  if (c:=get(m,'gbasis)) then return dpmat_2a c;
  c:=gbasis!* c1;
  put(m,'gbasis,c); 
  return dpmat_2a c;
  end;

symbolic operator setmonset;
symbolic procedure setmonset m; 
  if !*mode='algebraic then makelist setmonset!* cdr reval m
  else setmonset!* m;

symbolic procedure setmonset!* m;
  if subsetp(m,ring_names cali!=basering) then cali!=monset:=m
  else typerr(m,"monset list");

symbolic operator getmonset;
symbolic procedure getmonset(); makelist cali!=monset;

put('resolve,'psopfn,'intf!=resolve);
symbolic procedure intf!=resolve m;
  begin scalar c,c1,d;
  intf_test m; if length m=2 then d:=reval cadr m else d:=10;
  m:=car m; c1:=intf_get m;
  if ((c:=get(m,'resolution)) and (car c >= d)) then 
        return makelist for each x in cdr c collect dpmat_2a x;
  c:=Resolve!*(c1,d);
  put(m,'resolution,d.c);
  if not get(m,'syzygies) then put(m,'syzygies,cadr c);
  return makelist for each x in c collect dpmat_2a x;
  end;

put('syzygies,'psopfn,'intf!=syzygies);
symbolic procedure intf!=syzygies m;
  begin scalar c,c1;
  intf_test m; m:=car m; c1:=intf_get m;
  if (c:=get(m,'syzygies)) then return dpmat_2a c;
  c:=syzygies!* c1; 
  put(m,'syzygies,c);
  return dpmat_2a c;
  end;

put('indepvarsets,'psopfn,'intf!=indepvarsets);
symbolic procedure intf!=indepvarsets m;
  begin scalar c;
  intf_test m; m:=car m; intf_get m;
  if (c:=get(m,'independentsets)) then 
    return makelist for each x in c collect makelist x;
  if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  c:=indepvarsets!* c;
  put(m,'independentsets,c);
  return makelist for each x in c collect makelist x;
  end;

put('getleadterms,'psopfn,'intf_getleadterms);
symbolic procedure intf_getleadterms m;
  begin scalar c;
  intf_test m; m:=car m; intf_get m;
  if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  c:=getleadterms!* c;
  return dpmat_2a c;
  end;

put('hilbertseries,'psopfn,'intf!=hilbertseries);
symbolic procedure intf!=hilbertseries m;
% Returns the Hilbert series of m.
  begin scalar c;
  intf_test m; m:=car m; intf_get m;
  if (c:=get(m,'hs)) then return mk!*sq c;
  if not(c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  put(m,'hs,c:=hilbertseries!* c);
  return mk!*sq c;
  end;

put('degree,'psopfn,'intf_getmult);
symbolic procedure intf_getmult m;
% Returns the multiplicity of m.
  begin scalar c;
  intf_test m; m:=car m; intf_get m;
  if (c:=get(m,'hs)) then return hf_mult c;
  if not(c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  put(m,'hs,c:=hilbertseries!* c);
  return hf_mult c;
  end;

put('dim,'psopfn,'intf!=dim);
put('codim,'psopfn,'intf!=codim);
symbolic procedure intf!=dim m;
% Returns the dimension of coker m.
  begin scalar c;
  intf_test m; m:=car m; intf_get m;
  if (c:=get(m,'hs)) then return hf_dim c;
  if (c:=get(m,'independentsets)) then return length moid_max c;
  if not(c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  c:=indepvarsets!* c; put(m,'independentsets,c);
  return length moid_max c;
  end;

symbolic procedure intf!=codim m;
% Returns the codimension of coker m.
  length ring_names cali!=basering - intf!=dim m;

put('BettiNumbers,'psopfn,'intf!=BettiNumbers);
symbolic procedure intf!=BettiNumbers m;
  begin scalar c;
  intf_test m; m:=car m; intf_get m;
  if (c:=get(m,'resolution)) then return makelist BettiNumbers!* cdr c
  else rederr"Compute a resolution first";
  end;

put('GradedBettiNumbers,'psopfn,'intf!=GradedBettiNumbers);
symbolic procedure intf!=GradedBettiNumbers m;
  begin scalar c;
  intf_test m; m:=car m; intf_get m;
  if (c:=get(m,'resolution)) then return 
    makelist for each x in GradedBettiNumbers!* cdr c collect makelist x
  else rederr"Compute a resolution first";
  end;

put('degsfromresolution,'psopfn,'intf!=degsfromresolution);
symbolic procedure intf!=degsfromresolution m;
  begin scalar c;
  intf_test m; m:=car m; 
  if not equal(get(m,'ring),cali!=basering) then
        rederr"invalid base ring";
  if not (c:=get(m,'resolution)) then 
        rederr"compute a resolution first";
  return makelist for each x in cdr c collect 
            moid_2a for each y in dpmat_coldegs x collect cdr y;
  end;

symbolic operator sieve;
symbolic procedure sieve(m,vars);
% Sieve out all base elements from m containing one of the variables
% in vars in their leading term.
  if !*mode='algebraic then
        dpmat_2a dpmat_sieve(dpmat_from_a reval m,cdr vars,nil)
  else dpmat_sieve(m,vars,nil);

endmodule; % intf

module odim;

COMMENT

		##########################################
		##					##
		##   Applications to zerodimensional	##
		##	ideals and modules.		##
		##					##
		##########################################

getkbase returns a k-vector space basis of S^c/M,
odim_borderbasis computes a borderbasis of M,
odim_up finds univariate polynomials in zerodimensional ideals.

END COMMENT;

% -------------- Test for zero dimension -----------------
% For a true answer m must be a gbasis. 

put('dimzerop,'psopfn,'odim!=zerop);
symbolic procedure odim!=zerop m; 
  begin scalar c;
  intf_test m; intf_get(m:=car m);
  if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  if dimzerop!* c then return 'yes else return 'no;
  end;

symbolic procedure dimzerop!* m; null odim_parameter m;
  
symbolic procedure odim_parameter m; 
% Return a parameter of the dpmat m or nil, if it is zerodimensional
% or (1).
  odim!=parameter moid_from_dpmat m;

symbolic procedure odim!=parameter m;
  if null m then nil
  else odim!=parameter1 cdar m or odim!=parameter cdr m;

symbolic procedure odim!=parameter1 m;
  if null m then 
	((if u then car u else u)
	where u:= reverse ring_names cali!=basering)
  else if mo_zero!? car m then nil
  else begin scalar b,u;
  u:=for each x in m join if length(b:=mo_support x)=1 then b;
  b:=reverse ring_names cali!=basering; 
  while b and member(car b,u) do b:=cdr b;
  return if b then car b else nil;
  end;

% --- Get a k-base of F/M as a list of monomials ----
% m must be a gbasis for the correct result.

put('getkbase,'psopfn,'odim!=evkbase);
symbolic procedure odim!=evkbase m; 
  begin scalar c;
  intf_test m; intf_get(m:=car m);
  if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  return moid_2a getkbase!* c;
  end;

symbolic procedure getkbase!* m;
  if not dimzerop!* m then rederr"dpmat not zerodimensional"  
  else for each u in moid_from_dpmat m join 
        odim!=kbase(mo_from_ei car u,ring_names cali!=basering,cdr u);

symbolic procedure odim!=kbase(mo,n,m);
  if moid_member(mo,m) then nil
  else mo . for each x on n join
                odim!=kbase(mo_inc(mo,car x,1),append(x,nil),m);

% --- Produce an univariate polynomial inside the ideal m ---

symbolic procedure odim_up(a,m);
% Returns a univariate polynomial (of smallest possible degree if m
% is a gbasis) in the variable a inside the zerodimensional ideal m.
% Uses Buchberger's approach.
  if dpmat_cols m>0 or not dimzerop!* m then 
      rederr"univariate polynomials only for zerodimensional ideals"
  else if not member(a,ring_names cali!=basering) then 
    typerr(a,"variable name")  
  else if dpmat_unitideal!? m then dp_fi 1
  else begin scalar b,v,p,l,q,r;
    % l is a list of ( p(a) . NF p(a) ), sorted by lt NF p(a)
    p:=(dp_fi 1 . dp_fi 1); b:=dpmat_list m;  v:=mo_from_a a;
    while cdr p do
      << l:=merge(list p,l,function odim!=greater);
         q:=dp_times_mo(v,car p); 
         r:=red_redpol(b,bas_make(0,dp_times_mo(v,cdr p)));
         p:=odim!=reduce(dp_prod(cdr r,q) . bas_dpoly car r,l);
      >>;
    return 
    if !*bcsimp then car dp_simp car p
    else car p;
    end;     
                
symbolic procedure odim!=greater(a,b); 
    mo_compare(dp_lmon cdr a,dp_lmon cdr b)=1;

symbolic procedure odim!=reduce(a,l);
  if null cdr a or null l or odim!=greater(a, car l) then a
  else if mo_equal!?(dp_lmon cdr a,dp_lmon cdar l) then
    begin scalar z,z1,z2,b; 
    b:=car l; z1:=bc_neg dp_lc cdr a; z2:=dp_lc cdr b;
    if !*bcsimp then
      << if (z:=bc_inv z1) then <<z1:=bc_fi 1; z2:=bc_prod(z2,z)>>
         else
           << z:=bc_gcd(z1,z2);
              z1:=car bc_divmod(z1,z);
              z2:=car bc_divmod(z2,z);
           >>;
      >>;
    a:=dp_sum(dp_times_bc(z2,car a),dp_times_bc(z1,car b)) .
           dp_sum(dp_times_bc(z2,cdr a),dp_times_bc(z1,cdr b));
    return odim!=reduce(a,cdr l)
    end
  else odim!=reduce(a,cdr l);

% ------------------------- Borderbasis -----------------------

symbolic procedure odim_borderbasis m;
% Returns a border basis of the zerodimensional dpmat m as list of
% base elements.
  if not !*noetherian then
	rederr"BORDERBASIS only for non noetherian term orders"
  else if not dimzerop!* m then
	rederr"BORDERBASIS only for zerodimensional ideals or modules"
  else begin scalar b,v,u,mo,bas;
  bas:=bas_zerodelete dpmat_list m;
  mo:=for each x in bas collect dp_lmon bas_dpoly x;
  v:=for each x in ring_names cali!=basering collect mo_from_a x;
  u:=for each x in bas collect
	{dp_lmon bas_dpoly x,red_tailred(bas,x)};
  while u do
  << b:=append(b,u);
     u:=listminimize(
	for each x in u join
	    for each y in v join
		(begin scalar w; w:=mo_sum(first x,y);
		if not listtest(b,w,function(lambda(x,y);car x=y))
			and not odim!=interior(w,mo) then 
			return {{w,y,bas_dpoly second x}}
		end),
	function(lambda(x,y);car x=car y));
     u:=for each x in u collect 
	{first x, 
	red_tailred(bas,bas_make(0,dp_times_mo(second x,third x)))};
  >>;
  return bas_renumber for each x in b collect second x;
  end;

symbolic procedure odim!=interior(m,mo);
% true <=> monomial m is in the interior of the moideal mo.
  begin scalar b; b:=t;
  for each x in mo_support m do
	b:=b and moid_member(mo_diff(m,mo_from_a x),mo);
  return b;
  end;
         
endmodule; % odim

module prime;

COMMENT 

        ####################################
        #                                  #
        #  PRIME DECOMPOSITION, RADICALS,  #
        #        AND RELATED PROBLEMS      #
        #                                  #
        ####################################
        
        
This module contains algorithms 
    
    - for zerodimensional ideals :
            - to test whether it is radical
            - to compute its radical
            - for a primality test

    - for zerodimensional ideals and modules :
            - to compute its primes
            - to compute its primary decomposition
    
    - for arbitrary ideals :
            - for a primality test
            - to compute its radical
            - to test whether it is radical

    - for arbitrary ideals and modules :   
        - to compute its isolated primes
        - to compute its primary decomposition and
            the associated primes
        - a shortcut for the primary decomposition
            computation for unmixed modules

The algorithms follow

        Seidenberg : Trans. AMS 197 (1974), 273 - 313.
        
        Kredel : in Proc. EUROCAL'87, Lecture Notes in Comp. Sci. 378
                (1986), 270 - 281.
        
        Gianni, Trager, Zacharias : 
                J. Symb. Comp. 6 (1988), 149 - 167.
                
with essential modifications for modules as e.g. presented in

        Rutman : J. Symb. Comp. 14 (1992), 483 - 503

        
END COMMENT;        
        
% ------ The radical of a zerodimensional ideal -----------

symbolic procedure prime!=mksqrfree(pol,x);
% Make the univariate dpoly p(x) squarefree.
  begin scalar p;
    p:=numr simp dp_2a pol;
    return dp_from_a prepf car qremf(p,gcdf!*(p,difff(p,x)))
    end;

put('zeroradical,'psopfn,'prime!=evzero);
symbolic procedure prime!=evzero m; 
  begin scalar c;
  intf_test m; intf_get(m:=car m);
  if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  return dpmat_2a zeroradical!* c;
  end;

symbolic procedure zeroradical!* m;
% Returns the radical of the zerodim. ideal m. m must be a gbasis.
  if dpmat_cols m>0 or not dimzerop!* m then 
        rederr"ZERORADICAL only for zerodimensional ideals"
  else if dpmat_unitideal!? m then m
  else begin scalar u;
    u:=for each x in ring_names cali!=basering collect
        bas_make(0,prime!=mksqrfree(odim_up(x,m),x));
    u:=dpmat_make(length u,0,bas_renumber u,nil,nil);
    return gbasis!* matsum!* {m,u};
    end;    

put('iszeroradical,'psopfn,'prime!=eviszero);
symbolic procedure prime!=eviszero m; 
  begin scalar c;
  intf_test m; intf_get(m:=car m);
  if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  return if iszeroradical!* c then 'yes else 'no;
  end;

symbolic procedure iszeroradical!* m;
% Test whether the zerodim. ideal m is radical. m must be a gbasis.
  if dpmat_cols m>0 or not dimzerop!* m then 
        rederr"ISZERORADICAL only for zerodimensional ideals"
  else if dpmat_unitideal!? m then t
  else begin scalar u,isradical;
    isradical:=t;
    for each x in ring_names cali!=basering do
        isradical:=isradical and 
            null matop_pseudomod(prime!=mksqrfree(odim_up(x,m),x),m);
    return isradical;
    end;    

% ---- The primes of a zerodimensional ideal or module ------

symbolic operator zeroprimes;
symbolic procedure zeroprimes m;
  if !*mode='algebraic then
        makelist for each x in zeroprimes!* dpmat_from_a reval m
                collect dpmat_2a x
  else zeroprimes!* m;

symbolic procedure zeroprimes!* m;
% The primes of the zerodimensional ideal Ann F/M. 
% The unit ideal has no primes.
  listminimize(
        for each x in prime_zeroprimes1 gbasis!* annihilator2!* m 
                join prime!=zeroprimes2 x,
        function submodulep!*)  ;

symbolic procedure prime_iszeroprime m;
% Test a zerodimensiomal ideal to be prime. m must be a gbasis.
  if dpmat_cols m>0 or not dimzerop!* m then 
    rederr "iszeroprime only for zerodimensional ideals"
  else if dpmat_unitideal!? m then rederr"the ideal is the unit ideal"
  else prime!=iszeroprime1 m and prime!=iszeroprime2 m;

symbolic procedure prime_zeroprimes1 m;
% A first approximation to the isolated primes in dim=0 : Factor all
% univariate polynomials in m.
  if dpmat_cols m>0 then rederr"ZEROPRIMES only for ideals"
  else if dpmat_unitideal!? m then nil
  else if not dimzerop!* m then 
        rederr"ZEROPRIMES only for zerodimensional ideals"
  else begin scalar l;
    l:={m};
    for each x in ring_names cali!=basering do
        l:=for each y in l join
            begin scalar u,p;
            u:=dp_factor (p:=odim_up(x,y));
            if (length u=1) and equal(car u,p) then return {y}
            else return for each z in u join
                if not dpmat_unitideal!?(p:=gbasis!* matsum!* 
                        {y,dpmat_from_dpoly z}) then {p};
            end;
    return l;
    end;    
   
symbolic procedure prime!=iszeroprime1 m;
% A first non primality test.
  if dpmat_cols m>0 then rederr"ISZEROPRIME only for ideals"
  else if dpmat_unitideal!? m then nil
  else if not dimzerop!* m then 
        rederr"ISZEROPRIME only for zerodimensional ideals"
  else begin scalar b; b:=t;
    for each x in ring_names cali!=basering do
       b:=b and
            begin scalar u,p;
            u:=dp_factor (p:=odim_up(x,m));
            if (length u=1) and equal(car u,p) then return t
            else return nil
            end;
    return b;
    end;    
   
symbolic procedure prime_gpchange(vars,v,m);
% Change to general position with respect to v. Only for pure lex.
% term order and radical ideal m.
  if null vars or dpmat_unitideal!? m then m
  else begin scalar s,x,a;
    s:=0; x:=mo_from_a car vars;
    a:=list (v.prepf addf(!*k2f v,!*k2f car vars));
            % the substitution rule v -> v + x .
    while not member(x,moid_from_bas dpmat_list m)
                % i.e. m has a leading term equal to x
        and ((s:=s+1) < 10)
                % to avoid too much loops.
        do m:=gbasis!* dpmat_sub(a,m);
    if s=10 then rederr" change to general position failed";
    return prime_gpchange(cdr vars,v,m);
    end;

symbolic procedure prime!=zeroprimes2 m;
% Decompose the radical zerodimensional dmpat ideal m using a general
% position argument.
  (begin scalar c,v,vars,u,d,r;
    c:=cali!=basering; vars:=ring_names c; v:=gensym();
    u:=setdiff(vars,for each x in moid_from_bas dpmat_list m 
                join {mo_linear x});
    if (length u)=1 then return prime!=zeroprimes3(m,first u);
    if ring_tag c='revlex then % for proper ring_sum redefine it.
        r:=ring_define(vars,ring_degrees c,'lex,ring_ecart c)
    else r:=c;
    setring!* ring_sum(r,ring_define(list v,nil,'lex,'(1)));
    cali!=degrees:=nil;
    m:=gbasis!* matsum!* 
                {dpmat_neworder(m,nil), dpmat_from_dpoly dp_from_a v};
    u:=setdiff(v.vars,for each x in moid_from_bas dpmat_list m 
                join {mo_linear x});
    if not dpmat_unitideal!? m then
      << m:=prime_gpchange(u,v,m);
         u:=for each x in prime!=zeroprimes3(m,v) join
             if not dpmat_unitideal!? x and
                not dpmat_unitideal!?(d:=eliminate!*(x,{v})) then {d}
                    % To recognize (1) even if x is not a gbasis.
      >>
    else u:=nil;
    setring!* c;
    return for each x in u collect interreduce!* dpmat_neworder(x,nil);
   end)
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

symbolic procedure prime!=zeroprimes3(m,v);
% m is in general position with univariate polynomial in v.
  begin scalar u,p;
  u:=dpmat_list m;
  while u and not equal(mo_support dp_lmon (p:=bas_dpoly car u),
                        list v) do u:=cdr u;
  if null u then rederr"univariate polynomial not found";
  p:=for each x in cdr ((fctrf numr simp dp_2a p) where !*factor=t) 
        collect dpmat_from_dpoly dp_from_a prepf car x;
  return for each x in p collect matsum!* {m,x};  
  end;

symbolic procedure prime!=iszeroprime2 m;
% Test the radical zerodimensional dmpat ideal m to be prime using a
% general position argument.
  (begin scalar c,v,vars,u,r;
    c:=cali!=basering; vars:=ring_names c; v:=gensym();
    if ring_tag c='revlex then % for proper ring_sum redefine it.
        r:=ring_define(vars,ring_degrees c,'lex,ring_ecart c)
    else r:=c;
    setring!* ring_sum(r,ring_define(list v,nil,'lex,'(1)));
    cali!=degrees:=nil;
    m:=matsum!* {dpmat_neworder(m,nil), dpmat_from_dpoly dp_from_a v};
    m:=prime_gpchange(vars,v,gbasis!* m);  
    u:=prime!=iszeroprime3(m,v);
    setring!* c; return u;
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;
  
symbolic procedure prime!=iszeroprime3(m,v);
  begin scalar u,p;
  u:=dpmat_list m;
  while u and not equal(mo_support dp_lmon (p:=bas_dpoly car u),
                        list v) do u:=cdr u;
  if null u then rederr"univariate polynomial not found";
  if (length(u:=cdr ((fctrf numr simp dp_2a p) where !*factor=t))>1) 
        or (cdar u>1) then return nil
  else return t         
  end;

% - The primary decomposition of a zerodimensional ideal or module -

symbolic procedure prime_polynomial l;
% l is a list of (gbases of) prime ideals.
% Returns a list of (p . f) with p \in l and dpoly f \in all q \in l
% except p.
  for each x in l collect (x . prime!=polynomial(x,delete(x,l)));

symbolic procedure prime!=polynomial(x,l);
% Returns a dpoly f inside all q \in l and outside x.
  if null l then dp_fi 1
  else begin scalar u,p,q;
    p:=prime!=polynomial(x,cdr l);
    if null matop_pseudomod(p,car l) then return p;
    u:=dpmat_list car l;
    while u and null matop_pseudomod(q:=bas_dpoly car u,x) do u:=cdr u;
    if null u then
        rederr"prime ideal separation failed"
    else return dp_prod(p,q);
  end;
  
symbolic operator zeroprimarydecomposition;
symbolic procedure zeroprimarydecomposition m;
% Returns a list of {Q,p} with p a prime ideal and Q a p-primary
% component of m. For m=S^c the list is empty.
  if !*mode='algebraic then
        makelist for each x in 
                zeroprimarydecomposition!* dpmat_from_a reval m
        collect makelist {dpmat_2a first x,dpmat_2a second x}
  else zeroprimarydecomposition!* m;
        
symbolic procedure zeroprimarydecomposition!* m;
% The symbolic counterpart, returns a list of {Q,p}. m is not
% assumed to be a gbasis.
    if not dimzerop!* m then rederr 
 "zeroprimarydecomposition only for zerodimensional ideals or modules"
    else for each f in prime_polynomial
            (for each y in zeroprimes!* m collect gbasis!* y)
        collect {matqquot!*(m,cdr f),car f};

% --------- Primality test for an arbitrary ideal. ---------

put('isprime,'psopfn,'prime!=isprime);
symbolic procedure prime!=isprime m;
  begin scalar c;
    intf_test m; intf_get(m:=car m); 
    if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
    return if isprime!* c then 'yes else 'no;
  end;  

symbolic procedure isprime!* m;
% Test an dpmat ideal m to be prime. m must be a gbasis.
  if dpmat_cols m>0 then rederr"prime test only for ideals"
  else (begin scalar vars,u,v,c1,c2,m1,m2,lc;
    v:=moid_goodindepvarset m; cali!=degrees:=nil; 
    if null v then return prime_iszeroprime m;
    vars:=ring_names(c1:=cali!=basering);
        % Change to dimension zero.
    u:=setdiff(ring_names c1,v); 
    setring!* ring_rlp(c1,u);
    m1:=dpmat_2a gbasis!* dpmat_neworder(m,nil);
    setring!*(c2:= ring_define(u,degreeorder!* u,'revlex, 
                        for each x in u collect 1));
    m1:=groeb_mingb dpmat_from_a m1;
    if dpmat_unitideal!?(m1) then
      << setring!* c1; rederr"Input must be a gbasis" >>;
    lc:=bc_2a prime!=quot m1; setring!* c1; 
        % Test recontraction of m1 to be equal to m.
    m2:=gbasis!* matqquot!*(m,dp_from_a lc);
    if not submodulep!*(m2,m) then return nil;
        % Test the zerodimensional ideal m1 to be prime
    setring!* c2; u:=prime_iszeroprime m1; setring!* c1;
    return u;
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

symbolic operator isolatedprimes;
symbolic procedure isolatedprimes m;
  if !*mode='algebraic then
        makelist for each x in isolatedprimes!* dpmat_from_a reval m
                collect dpmat_2a x
  else isolatedprimes!* m;

symbolic procedure isolatedprimes!* m;
% Returns the isolated primes of the dpmat m as a dpmat list.
  prime!=isoprimes gbasis!* annihilator2!* m;
  
symbolic procedure prime!=isoprimes m;
% m is a gbasis and an ideal.
  if dpmat_zero!? m then nil else
  (begin scalar u,c,v,vars,m1,m2,l,p;
    if null(v:=odim_parameter m) then return 
        for each x in prime_zeroprimes1 m join prime!=zeroprimes2 x;
    vars:=ring_names(c:=cali!=basering); cali!=degrees:=nil;
    u:=delete(v,vars); 
    setring!* ring_rlp(c,u);
    m1:=dpmat_2a gbasis!* dpmat_neworder(m,nil);
    setring!* ring_define(u,degreeorder!* u,
                        'revlex,for each x in u collect 1);
    p:=bc_2a prime!=quot(m1:=groeb_mingb dpmat_from_a m1);
    l:=for each x in prime!=isoprimes m1 collect 
            (dpmat_2a x . bc_2a prime!=quot x); 
    setring!* c;
    l:=for each x in l collect 
                gbasis!* matqquot!*(dpmat_from_a car x,dp_from_a cdr x);
    if dp_unit!?(p:=dp_from_a p) or
        submodulep!*(matqquot!*(m,p),m) or
        dpmat_unitideal!?(m2:=gbasis!* matsum!* {m,dpmat_from_dpoly p})
                then return l
    else return 
        listminimize(append(l,prime!=isoprimes  m2), 
                        function submodulep!*);
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;
    
symbolic procedure prime!=quot m;    
% The lcm of the leading coefficients of m. 
  begin scalar p,u; 
    u:=for each x in dpmat_list m collect dp_lc bas_dpoly x;
    if null u then return bc_fi 1;
    p:=car u; for each x in cdr u do p:=bc_lcm(p,x);
    return p
  end;

% ----------- The radical -------------
% Returns the radical of the dpmat ideal m. 

symbolic operator radical;
symbolic procedure radical m;
  if !*mode='algebraic then
        dpmat_2a radical!* gbasis!* dpmat_from_a reval m
  else radical!* m;

symbolic procedure radical!* m;
% m must be a gbasis. 
  if dpmat_cols m>0 then rederr"RADICAL only for ideals"
  else (begin scalar u,c,v,vars,m1,l,p,p1;
    if null(v:=odim_parameter m) then return zeroradical!* m; 
    vars:=ring_names (c:=cali!=basering); 
    cali!=degrees:=nil; u:=delete(v,vars); 
    setring!* ring_rlp(c,u);
    m1:=dpmat_2a gbasis!* dpmat_neworder(m,nil);
    setring!* ring_define(u,degreeorder!* u,
                        'revlex,for each x in u collect 1);
    p:=bc_2a prime!=quot(m1:=groeb_mingb dpmat_from_a m1);
    l:=radical!* m1; p1:=bc_2a prime!=quot l;
    l:=dpmat_2a l; setring!* c;
    l:=gbasis!* matqquot!*(dpmat_from_a l,dp_from_a p1);
    if dp_unit!?(p:=dp_from_a p) or
    submodulep!*(matqquot!*(m,p),m) then return l
    else << m1:=radical!* gbasis!* matsum!* {m,dpmat_from_dpoly p};
            if submodulep!*(m1,l) then l:=m1
            else if not submodulep!*(l,m1) then 
                    l:= matintersect!* {l,m1};
         >>;
    return l;
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;
    
% -- Primary decomposition for modules without embedded components ---

symbolic operator easyprimarydecomposition;
symbolic procedure easyprimarydecomposition m;
  if !*mode='algebraic then
        makelist for each x in 
                easyprimarydecomposition!* dpmat_from_a reval m
        collect makelist {dpmat_2a first x,dpmat_2a second x}
  else easyprimarydecomposition!* m;

symbolic procedure easyprimarydecomposition!* m;
% Primary decomposition for a module without embedded components.
   begin scalar u; u:=isolatedprimes!* m;
      return if null u then nil
        else if length u=1 then {m,car u}
        else for each f in 
        prime_polynomial(for each y in u collect gbasis!* y)
                    collect {matqquot!*(m,cdr f),car f};
  end;

% ---- General primary decomposition ----------

symbolic operator primarydecomposition;
symbolic procedure primarydecomposition m;
  if !*mode='algebraic then
        makelist for each x in 
                primarydecomposition!* gbasis!* dpmat_from_a reval m
        collect makelist {dpmat_2a first x,dpmat_2a second x}
  else primarydecomposition!* m;

symbolic procedure primarydecomposition!* m;
% Returns the primary decomposition of the dpmat (ideal or module) m
% as a list {Q,p} with a prime ideal p and a p-primary component Q.
% m must be a gbasis.
  if dpmat_cols m=0 then 
    for each x in prime!=decompose1 ideal2mat!* m collect
        {mat2list!* first x,second x}
  else prime!=decompose1 m;        

symbolic procedure prime!=decompose1 m;
  (begin scalar u,c,v,vars,m1,l,p,q;
    if null(v:=odim_parameter m) then 
            return zeroprimarydecomposition!* m; 
    vars:=ring_names (c:=cali!=basering); 
    cali!=degrees:=nil; u:=delete(v,vars); 
    setring!* ring_rlp(c,u);
    m1:=dpmat_2a gbasis!* dpmat_neworder(m,nil);
    setring!* ring_define(u,degreeorder!* u,
                                'revlex,for each x in u collect 1);
    p:=bc_2a prime!=quot(m1:=groeb_mingb dpmat_from_a m1);
    l:=for each x in prime!=decompose1 m1 collect 
          {(dpmat_2a first x . bc_2a prime!=quot first x), 
           (dpmat_2a second x . bc_2a prime!=quot second x)}; 
    setring!* c; 
    l:=for each x in l collect 
    << cali!=degrees:=dpmat_coldegs m;
       {gbasis!* matqquot!*(dpmat_from_a car first x,
                            dp_from_a cdr first x),
        matqquot!*(dpmat_from_a car second x,dp_from_a cdr second x)}
    >>;
    if dp_unit!?(p:=dp_from_a p) or
        submodulep!*(m1:=matqquot!*(m,p),m) then return l
    else 
      << q:=p; 
         while not submodulep!*(m1:=dpmat_times_dpoly(p,m1),m) do
               q:=dp_prod(p,q); 
         l:=listminimize(
                append(l,prime!=decompose1
                    gbasis!* matsum!* {m, dpmat_times_dpoly(q,
                    dpmat_unit(dpmat_cols m,dpmat_coldegs m))}),
                function(lambda(x,y);
                    submodulep!*(car x,car y)));
      >>;
    return l;                 
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

symbolic operator unmixedradical;
symbolic procedure unmixedradical m;
% Returns the radical of the dpmat ideal m.
  if !*mode='algebraic then
        dpmat_2a unmixedradical!* gbasis!* dpmat_from_a reval m
  else unmixedradical!* m;

symbolic procedure unmixedradical!* m;
% m must be a gbasis.
  if dpmat_cols m>0 then rederr"UNMIXEDRADICAL only for ideals"
  else (begin scalar u,c,d,v,vars,m1,l,p,p1;
    if null(v:=moid_goodindepvarset m) then return zeroradical!* m;
    vars:=ring_names (c:=cali!=basering); 
    d:=length v; u:=setdiff(vars,v); 
    setring!* ring_rlp(c,u);
    m1:=dpmat_2a gbasis!* dpmat_neworder(m,nil);
    setring!* ring_define(u,degreeorder!* u,'revlex,
                for each x in u collect 1);
    p:=bc_2a prime!=quot(m1:=groeb_mingb dpmat_from_a m1);
    l:=zeroradical!* m1; p1:=bc_2a prime!=quot l;
    l:=dpmat_2a l; setring!* c;
    l:=matqquot!*(dpmat_from_a l,dp_from_a p1);
    if dp_unit!?(p:=dp_from_a p) then return l
    else << m1:=gbasis!* matsum!* {m,dpmat_from_dpoly p};
            if dim!* m1=d then 
                l:= matintersect!* {l,unmixedradical!* m1};
         >>;
    return l;
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

symbolic operator eqhull;
symbolic procedure eqhull m;
% Returns the radical of the dpmat ideal m.
  if !*mode='algebraic then
        dpmat_2a eqhull!* gbasis!* dpmat_from_a reval m
  else eqhull!* m;

symbolic procedure eqhull!* m;
% m must be a gbasis.
  begin scalar d;
  if (d:=dim!* m)=0 then return m
  else return prime!=eqhull(m,d)
  end;

symbolic procedure prime!=eqhull(m,d);
% d(>0) is the dimension of the dpmat m.
  (begin scalar u,c,v,vars,m1,l,p;
  v:=moid_goodindepvarset m;
  if length v neq d then 
        rederr "EQHULL found a component of wrong dimension";
  vars:=ring_names(c:=cali!=basering); 
  cali!=degrees:=nil; u:=setdiff(ring_names c,v);
  setring!* ring_rlp(c,u);
  m1:=dpmat_2a gbasis!* dpmat_neworder(m,nil);
  setring!* ring_define(u,degreeorder!* u,'revlex,
                                for each x in u collect 1);
  p:=bc_2a prime!=quot(m1:=groeb_mingb dpmat_from_a m1);
  setring!* c; cali!=degrees:=dpmat_coldegs m;
  if submodulep!*(l:=matqquot!*(m,dp_from_a p),m) then return m;
  m1:=gbasis!* matstabquot!*(m,annihilator2!* l);
  if dim!* m1=d then return matintersect!* {l,prime!=eqhull(m1,d)}
  else return l;
   end) 
   where cali!=degrees:=cali!=degrees,
                cali!=basering:=cali!=basering;

endmodule; % prime

module scripts;

COMMENT

               ######################
               ##                  ##
               ##     ADVANCED     ##
               ##   APPLICATIONS   ##
               ##                  ##
               ######################

This module contains several additional advanced applications of
standard basis computations, inspired partly by the scripts
distributed with the commutative algebra package MACAULAY
(Bayer/Stillman/Eisenbud). 

The following topics are currently covered :
        - [BGK]'s heuristic variable optimization 
        - certain stuff on maps (preimage, ratpreimage)
        - ideals of points (in affine and proj. spaces) 
        - ideals of (affine and proj.) monomial curves
        - General Rees rings, associated graded rings, and related
                topics (analytic spread, symmetric algebra)
        - several short scripts (minimal generators, symbolic powers
                of primes, singular locus)        


END COMMENT;

%---------- [BGK]'s heuristic variable optimization ----------

symbolic operator varopt;
symbolic procedure varopt m;
  if !*mode='algebraic then makelist varopt!* dpmat_from_a m
  else varopt!* m;

symbolic procedure varopt!* m;
% Find a heuristically optimal variable order. 
  begin scalar c; c:=mo_zero();
  for each x in dpmat_list m do
    for each y in bas_dpoly x do c:=mo_lcm(c,car y);
  return 
    for each x in 
        sort(mo_2list c,function(lambda(x,y); cdr x>cdr y)) collect 
        car x;
  end;

% ----- Certain stuff on maps -------------

% A ring map is represented as a list 
%   {preimage_ring, image_ring, subst_list},
% where subst_list is a substitution list {v1=ex1,v2=ex2,...} in
% algebraic prefix form, i.e. looks like (list (equal var image) ...)

symbolic operator preimage;
symbolic procedure preimage(m,map);
% Compute the preimage of an ideal m under a (polynomial) ring map. 
  if !*mode='algebraic then
  begin map:=cdr reval map;
     return preimage!*(reval m,
        {ring_from_a first map, ring_from_a second map, third map});
  end
  else preimage!*(m,map);

symbolic procedure preimage!*(m,map);
% m and the result are given and returned in algebraic prefix form.
  if not !*noetherian then
        rederr"PREIMAGE only for noetherian term orders"
  else begin scalar u,oldring,newring,oldnames;
  if not eqcar(m,'list) then rederr"PREIMAGE only for ideals";
  oldring:=first map; newring:=second map; 
  oldnames:=ring_names oldring;
  setring!* ring_sum(newring,oldring);
  u:=bas_renumber for each x in cdr third map collect
  << if not member(second x,oldnames) then 
            typerr(second x,"var. name");
     bas_make(0,dp_diff(dp_from_a second x,dp_from_a third x))
  >>;   
  m:=matsum!* {dpmat_from_a m,dpmat_make(length u,0,u,nil,nil)};
  m:=dpmat_2a eliminate!*(m,ring_names newring); 
  setring!* oldring;
  return m;
  end;

symbolic operator ratpreimage;
symbolic procedure ratpreimage(m,map);
% Compute the preimage of an ideal m under a rational ring map. 
  if !*mode='algebraic then
  begin map:=cdr reval map;
  return ratpreimage!*(reval m,
        {ring_from_a first map, ring_from_a second map, third map});
  end
  else ratpreimage!*(m,map);

symbolic procedure ratpreimage!*(m,map);
% m and the result are given and returned in algebraic prefix form.
  if not !*noetherian then
        rederr"RATPREIMAGE only for noetherian term orders"
  else begin scalar u,oldring,newnames,oldnames,f,g,v,g0;
  if not eqcar(m,'list) then rederr"RATPREIMAGE only for ideals";
  oldring:=first map; v:=gensym();
  newnames:=v . ring_names second map; 
  oldnames:=ring_names oldring; u:=append(oldnames,newnames);
  setring!* ring_define(u,nil,'lex,for each x in u collect 1);
  g0:=dp_fi 1;
  u:=bas_renumber for each x in cdr third map collect
  << if not member(second x,oldnames) then 
            typerr(second x,"var. name");
     f:=simp third x; g:=dp_from_a prepf denr f;
     f:=dp_from_a prepf numr f; g0:=dp_prod(g,g0);
     bas_make(0,dp_diff(dp_prod(g,dp_from_a second x),f))
  >>;   
  u:=bas_make(0,dp_diff(dp_prod(g0,dp_from_a v),dp_fi 1)) . u;
  m:=matsum!* {dpmat_from_a m,dpmat_make(length u,0,u,nil,nil)};
  m:=dpmat_2a eliminate!*(m,newnames);
  setring!* oldring;
  return m;
  end;

% ---- The ideals of affine resp. proj. points. The old stuff, but the
% ---- algebraic interface now uses the linear algebra approach.  

symbolic procedure affine_points1!* m;
  begin scalar names;
  if length(names:=ring_names cali!=basering) neq length cadr m then
        typerr(m,"coordinate matrix");
  m:=for each x in cdr m collect 
         'list . for each y in pair(names,x) collect 
                {'plus,car y,{'minus,reval cdr y}};
  m:=for each x in m collect dpmat_from_a x;          
  m:=matintersect!* m;
  return m;
  end;

symbolic procedure scripts!=ideal u;
  'list . for each x in cali_choose(u,2) collect
        {'plus,{'times, car first x,cdr second x},
        {'minus,{'times, car second x,cdr first x}}};

symbolic procedure proj_points1!* m;
  begin scalar names,x0,u;
  if length(names:=ring_names cali!=basering) neq length cadr m then
        typerr(m,"coordinate matrix");
  m:=for each x in cdr m collect scripts!=ideal pair(names,x);
  m:=for each x in m collect interreduce!* dpmat_from_a x;
  m:=matintersect!* m;
  return m;
  end;

% ----- Affine and proj. monomial curves ------------

symbolic operator affine_monomial_curve;
symbolic procedure affine_monomial_curve(l,R);
% l is a list of integers, R contains length l ring var. names.
% Returns the generators of the monomial curve (t^i : i\in l) in R.
  if !*mode='algebraic then
        dpmat_2a affine_monomial_curve!*(cdr reval l,cdr reval R)
  else affine_monomial_curve!*(l,R);

symbolic procedure affine_monomial_curve!*(l,R);
  if not numberlistp l then typerr(l,"number list")
  else if length l neq length R then
        rederr"number of variables doesn't match"
  else begin scalar u,t0,v;
    v:=list gensym(); 
    r:=ring_define(r,{l},'revlex,l);
    setring!* ring_sum(r,ring_define(v,degreeorder!* v,'lex,'(1)));
    t0:=dp_from_a car v; 
    u:=bas_renumber for each x in pair(l,ring_names r) collect
        bas_make(0,dp_diff(dp_from_a cdr x,dp_power(t0,car x)));
    u:=dpmat_make(length u,0,u,nil,nil);
    u:=(eliminate!*(u,v) where cali!=monset=ring_names cali!=basering);
    setring!* r;
    return dpmat_neworder(u,dpmat_gbtag u);
    end;

symbolic operator proj_monomial_curve;
symbolic procedure proj_monomial_curve(l,R);
% l is a list of integers, R contains length l ring var. names.
% Returns the generators of the monomial curve 
% (s^(d-i)*t^i : i\in l) in R where d = max { x : x \in l}
  if !*mode='algebraic then
        dpmat_2a proj_monomial_curve!*(cdr reval l,cdr reval R)
  else proj_monomial_curve!*(l,R);

symbolic procedure proj_monomial_curve!*(l,R);
  if not numberlistp l then typerr(l,"number list")
  else if length l neq length R then
        rederr"number of variables doesn't match"
  else begin scalar u,t0,t1,v,d;
    t0:=gensym(); t1:=gensym(); v:={t0,t1};
    d:=listexpand(function max2,l);
    r:=ring_define(r,degreeorder!* r,'revlex,for each x in r collect 1);
    setring!* ring_sum(r,ring_define(v,degreeorder!* v,'lex,'(1 1)));
    t0:=dp_from_a t0; t1:=dp_from_a t1;
    u:=bas_renumber for each x in pair(l,ring_names r) collect
        bas_make(0,dp_diff(dp_from_a cdr x,
                dp_prod(dp_power(t0,car x),dp_power(t1,d-car x))));
    u:=dpmat_make(length u,0,u,nil,nil);
    u:=(eliminate!*(u,v) where cali!=monset=ring_names cali!=basering);
    setring!* r;
    return dpmat_neworder(u,dpmat_gbtag u);
    end;

% -- General Rees rings, associated graded rings, and related topics --

symbolic operator blowup;
symbolic procedure blowup(m,n,vars);
% vars is a list of var. names for the ring R 
%       of the same length as dpmat_list n.
% Returns an ideal J such that (S+R)/J == S/M [ N.t ] 
%       ( with S = the current ring ) 
% is the blow up ring of the ideal N over S/M. 
% (S+R) is the new current ring.
  if !*mode='algebraic then
        dpmat_2a blowup!*(dpmat_from_a reval m,dpmat_from_a reval n,
                cdr reval vars)
  else blowup!*(M,N,vars);

symbolic procedure blowup!*(M,N,vars);
  if (dpmat_cols m > 0)or(dpmat_cols n > 0) then
        rederr"BLOWUP defined only for ideals"
  else if not !*noetherian then
        rederr"BLOWUP only for noetherian term orders"
  else begin scalar u,s,t0,v,r1;
    if length vars neq dpmat_rows n then 
        rederr {"ring must have",dpmat_rows n,"variables"};
    u:=for each x in dpmat_rowdegrees n collect mo_ecart cdr x;
    r1:=ring_define(vars,list u,'revlex,u);
    s:=ring_sum(cali!=basering,r1); v:=list(gensym()); 
    setring!* ring_sum(s,ring_define(v,degreeorder!* v,'lex,'(1))); 
    t0:=dp_from_a car v;
    n:=for each x in 
            pair(vars,for each y in dpmat_list n collect bas_dpoly y)
            collect dp_diff(dp_from_a car x, 
                            dp_prod(dp_neworder cdr x,t0));
    m:=bas_renumber append(bas_neworder dpmat_list m,
            for each x in n collect bas_make(0,x)); 
    m:=(eliminate!*(interreduce!* dpmat_make(length m,0,m,nil,nil),v) 
        where cali!=monset=nil);
    setring!* s;
    return dpmat_neworder(m,dpmat_gbtag m);
    end;
  
symbolic operator assgrad;
symbolic procedure assgrad(m,n,vars);
% vars is a list of var. names for the ring T 
%       of the same length as dpmat_list n.
% Returns an ideal J such that (S+T)/J == (R/N + N/N^2 + ... )
%       ( with R=S/M and S the current ring )
% is the associated graded ring of the ideal N over R.
% (S+T) is the new current ring.
  if !*mode='algebraic then
        dpmat_2a assgrad!*(dpmat_from_a reval m,dpmat_from_a reval n,
                cdr reval vars)
  else assgrad!*(M,N,vars);

symbolic procedure assgrad!*(M,N,vars);
  if (dpmat_cols m > 0)or(dpmat_cols n > 0) then
        rederr"ASSGRAD defined only for ideals"
  else begin scalar u;
    u:=blowup!*(m,n,vars);
    return matsum!* {u,dpmat_neworder(n,nil)};
    end;

symbolic operator analytic_spread;
symbolic procedure analytic_spread m;
% Returns the analytic spread of the ideal m.
  if !*mode='algebraic then analytic_spread!* dpmat_from_a reval m
  else analytic_spread!* m;

symbolic procedure analytic_spread!* m;
   if (dpmat_cols m>0) then rederr"ANALYTIC SPREAD only for ideals"
   else (begin scalar r,m1,vars;
   r:=ring_names cali!=basering;
   vars:=for each x in dpmat_list m collect gensym();
   m1:=blowup!*(dpmat_from_dpoly nil,m,vars);
   return dim!* gbasis!* matsum!*{m1,dpmat_from_a('list . r)};
   end) where cali!=basering=cali!=basering;

symbolic operator sym;
symbolic procedure sym(M,vars);
% vars is a list of var. names for the ring R 
%       of the same length as dpmat_list M.
% Returns an ideal J such that (S+R)/J == Sym(M)
%       ( with S = the current ring )
% is the symmetric algebra of M over S.
% (S+R) is the new current ring.
  if !*mode='algebraic then 
        dpmat_2a sym!*(dpmat_from_a M,cdr reval vars)
  else sym!*(m,vars);

symbolic procedure sym!*(m,vars);
% The symmetric algebra of the dpmat m.
   if not !*noetherian then
        rederr"SYM only for noetherian term orders"
   else begin scalar n,u,s,r1;
    if length vars neq dpmat_rows m then 
        rederr {"ring must have",dpmat_rows m,"variables"};
    cali!=degrees:=dpmat_coldegs m;
    u:=for each x in dpmat_rowdegrees m collect mo_ecart cdr x;
    r1:=ring_define(vars,list u,'revlex,u); n:=syzygies!* m;
    setring!* ring_sum(cali!=basering,r1);
    return mat2list!* interreduce!* 
                dpmat_mult(dpmat_neworder(n,nil),
                        ideal2mat!* dpmat_from_a('list . vars));
    end;

% ----- Several short scripts ----------

% ------ Minimal generators of an ideal or module.
symbolic operator minimal_generators;
symbolic procedure minimal_generators m;
  if !*mode='algebraic then
        dpmat_2a minimal_generators!* dpmat_from_a reval m
  else minimal_generators!* m;

symbolic procedure minimal_generators!* m;
  car groeb_minimize(m,syzygies!* m);

% ------- Symbolic powers of prime (or unmixed) ideals 
symbolic operator symbolic_power;
symbolic procedure symbolic_power(m,d);
  if !*mode='algebraic then
        dpmat_2a symbolic_power!*(dpmat_from_a m,reval d)
  else symbolic_power!*(m,d); 

symbolic procedure symbolic_power!*(m,d); 
  eqhull!* idealpower!*(m,d);

% ---- non zero divisor property -----------

put('nzdp,'psopfn,'scripts!=nzdp);
symbolic procedure scripts!=nzdp m;
  if length m neq 2 then rederr"Syntax : nzdp(dpoly,dpmat)"
  else begin scalar f,b;
    f:=reval car m; intf_get second m;
    if null(b:=get(second m,'gbasis)) then 
	put(second m,'gbasis,b:=gbasis!* get(second m,'basis));  
    return if nzdp!*(dp_from_a f,b) then 'yes else 'no;
    end;

symbolic procedure nzdp!*(f,m); 
% Test dpoly f for a non zero divisor on coker m. m must be a gbasis.
  submodulep!*(matqquot!*(m,f),m);  

endmodule; % scripts

module calimat;

Comment 

                #######################
                #                     # 
                #  MATRIX SUPPLEMENT  #
                #                     #
                #######################

Supplement to the REDUCE matrix package.
Matrices are transformed into nested lists of s.q.'s.

end comment;

% ------ The Jacobian matrix -------------

symbolic operator matjac;
symbolic procedure matjac(m,l);
% Returns the Jacobian matrix from the ideal m in prefix form
% (given as an algebraic mode list) with respect to the var. list l.
   if not eqcar(m,'list) then typerr(m,"ideal basis")
   else if not eqcar(l,'list) then typerr(l,"variable list")
   else 'mat . for each x in cdr l collect
        for each y in cdr m collect prepsq difff(numr simp reval y,x);

% ---------- Random linear forms -------------

symbolic operator random_linear_form;
symbolic procedure random_linear_form(vars,bound);
% Returns a random linear form in algebraic prefix form.
  if not eqcar(vars,'list) then typerr(vars,"variable list")
  else 'plus . for each x in cdr vars collect 
        {'times,random(2*bound)-bound,x};

% ----- Singular locus -----------

symbolic operator singular_locus;
symbolic procedure singular_locus(m,c);
  if !*mode='algebraic then 
	(if not numberp c then 
	rederr"Syntax : singular_locus(polynomial list, codimension)" 
	else dpmat_2a singular_locus!*(m,c))
  else singular_locus!*(m,c);
  
symbolic procedure singular_locus!*(m,c);
% m must be a complete intersection of codimension c given as a list
% of polynomials in prefix form. Returns the singular locus computing
% the corresponding jacobian. 
  matsum!* {dpmat_from_a m, mat2list!* dpmat_from_a
	minors(matjac(m,makelist ring_names cali!=basering),c)};

% ------------- Minors --------------

symbolic operator minors;
symbolic procedure minors(m,k);
% Returns the matrix of k-minors of the matrix m. 
  if not eqcar(m,'mat) then typerr(m,"matrix")
  else begin scalar r,c;
  m:=for each x in cdr m collect for each y in x collect simp y;
  r:=cali_choose(for i:=1:length m collect i,k);
  c:=cali_choose(for i:=1:length car m collect i,k);
  return 'mat . for each x in r collect for each y in c collect 
        mk!*sq detq calimat!=submat(m,x,y);
  end;

symbolic operator ideal_of_minors;
symbolic procedure ideal_of_minors(m,k);
% The ideal of the k-minors of the matrix m.
  if !*mode='algebraic then dpmat_2a ideal_of_minors!*(m,k)
  else ideal_of_minors!*(m,k);

symbolic procedure ideal_of_minors!*(m,k);
  if not eqcar(m,'mat) then typerr(m,"matrix") else
  interreduce!* mat2list!* dpmat_from_a minors(m,k);

symbolic procedure calimat!=submat(m,x,y);
  for each a in x collect for each b in y collect nth(nth(m,a),b);

symbolic procedure calimat!=sum(a,b);
  for each x in pair(a,b) collect 
  for each y in pair(car x,cdr x) collect addsq(car y,cdr y);

symbolic procedure calimat!=neg a;
  for each x in a collect for each y in x collect negsq y;

symbolic procedure calimat!=tp a; 
  tp1 append(a,nil); % since tp1 is destructive.

symbolic procedure calimat!=zero!? a; 
  begin scalar b; b:=t;
  for each x in a do for each y in x do b:=b and null car y;
  return b;
  end;

% -------------- Pfaffians ---------------

symbolic procedure calimat!=skewsymmetric!? m; 
  calimat!=zero!? calimat!=sum(m,calimat!=tp m);

symbolic operator pfaffian;
symbolic procedure pfaffian m; 
% The pfaffian of a skewsymmetric matrix m.
  if not eqcar(m,'mat) then typerr(m,"matrix") else
  begin scalar m1;
  m1:=for each x in cdr m collect for each y in x collect simp y;
  if not calimat!=skewsymmetric!? m1 then typerr(m,"skewsymmetic matrix");
  return mk!*sq calimat!=pfaff m1;
  end;

symbolic procedure calimat!=pfaff m;
  if length m=1 then nil . 1
  else if length m=2 then cadar m
  else begin scalar a,b,p,c,d,ind,sgn;
      b:=for each x in cdr m collect cdr x;
      a:=cdar m; ind:=for i:=1:length a collect i;
      p:=nil . 1;
      for i:=1:length a do 
      << c:=delete(i,ind); d:=calimat!=pfaff calimat!=submat(b,c,c);
         if sgn then d:=negsq d; sgn:=not sgn;
         p:=addsq(p,multsq(nth(a,i),d));
      >>;
      return p;
      end;

symbolic operator ideal_of_pfaffians;
symbolic procedure ideal_of_pfaffians(m,k);
% The ideal of the 2k-pfaffians of the skewsymmetric matrix m.
  if !*mode='algebraic then dpmat_2a ideal_of_pfaffians!*(m,k)
  else ideal_of_pfaffians!*(m,k);

symbolic procedure ideal_of_pfaffians!*(m,k);
% The same, but for a dpmat m.
  if not eqcar(m,'mat) then typerr(m,"matrix") else
  begin scalar m1,u;
  m1:=for each x in cdr m collect for each y in x collect simp y;
  if not calimat!=skewsymmetric!? m1 then typerr(m,"skewsymmetic matrix");
  u:=cali_choose(for i:=1:length m1 collect i,2*k);
  return interreduce!* dpmat_from_a makelist
        for each x in u collect 
                prepsq calimat!=pfaff calimat!=submat(m1,x,x);
  end;

endmodule; % calimat

module lf;

COMMENT
              ###############################
              ####			 ####
              ####  DUAL BASES APPROACH  ####
              ####			 ####
              ###############################

The general idea for the dual bases approach :

Given a finite collection of linear functionals L : M=S^n --> k^N, we
want to compute a basis for Ker L as in 

[MMM] : Marinari et al., Proc. ISSAC'91, p. 55-63 

This generalizes the approach from 

[FGLM] : Faugere, Gianni, Lazard, Mora: JSC 16 (1993), 329 - 344. 

L is given through values on the generators, 
	{[e_i,L(e_i)], i=1 ... n}, 
and an evaluation function evlf([p,L(p)],x), that evaluates L(p*x)
from L(p) for p in M and the variable x .

We process a queue of elements of M with increasing leading terms,
evaluating each time L on them. Different to [MMM] the queue is stored
as 

   {[p,L(p)], l=list of potential multipliers, lt(p*(x:=first l))} 

for the potential evaluation of L(p*x) and sorted by the term order
wrt. the third slot. Since we proceed by increasing lt, Gaussian
elimination doesn't disturb leading terms. Hence leading terms of the
result are linearly independent and thus the result a Groebner basis.  

This approach applies to very different problem settings, see
[MMM]. CALI manages this variety of applications through different
values on the property list of 'cali.

There are general entries with information about the computation
        'varlessp -- a sort predicate for lf variable names
        'evlf     -- the evaluation function
and special entries, depending on the problem to be solved. 

[p,L(p)] is handled as data type lf (linear functions)
	< dpoly > . < list of (var. name).(base coeff.) >
The lf cdr list is the list of the values of the linear functionals
on the given car lf dpoly.

evlf(lf,var) evaluates lf*var and returns a new lf.

There are the following order functions :
        varlessp        = (cdr lf) variable order
        lf!=sort        = lf queue order
        term order      = (car lf) dpoly order

end comment;

symbolic procedure lf_dualbasis(q);
% q is the dual generator set given as a list of input lf values. 
% l is the queue to be processed and updated, g the list of kernel
%	elements, produced so far.
  begin scalar g,l,q,r,p,v,u,vars,rf,q1;
  v:=ring_names cali!=basering; 
  if null(rf:=get('cali,'evlf)) then 
	rederr"For DUALBASIS no evaluation function defined";
  for each ev1 in q do
     if lf!=zero ev1 then 
     << if cali_trace()>20 then dp_print2 car q; g:=car q . g >>
     else 
     << vars:=v; q1:=ev1.q1;
        while vars do 
        << l:={ev1, vars, mo_from_a car vars}.l; vars:=cdr vars >>;
     >>;
  q:=sort(q1,function lf!=less); % The reducer in triangular order.
  l:=sort(l, function lf!=sort); % The queue in increasing term order.
  while l do
  << r:=car l; l:=cdr l;
     vars:=second r; r:=car r;
     p:=lf!=reduce(apply2(rf,r,car vars),q); 
     if lf!=zero p then 
     << if cali_trace()>20 then dp_print2 car p; g:=car p . g >>
     else 
     << q:=merge({p},q,function lf!=less); 
        u:=nil; v:=dp_lmon car p;
        while vars do 
        << u:={p,vars,mo_sum(v,mo_from_a car vars)}.u; 
           vars:=cdr vars 
        >>;
        l:=merge(sort(u,function lf!=sort),l,function lf!=sort);
     >>;
  >>;
  g:=bas_renumber bas_zerodelete for each x in g collect bas_make(0,x);
  return interreduce!* groeb_mingb dpmat_make(length g,0,g,nil,t);
  end;

symbolic procedure lf!=sort(a,b); 
% Term order on the third slot. Niermann proposes another order here.
  mo_compare(third a,third b)=-1;

symbolic procedure lf_dualhbasis(q,s);
% The homogenized version. 
% s is the length of the dual homogenized basis. 
% For modules with column degrees not yet correct. 
  begin scalar a,d,g,l,l1,r,p,v,u,vars,rf,q1;
  v:=ring_names cali!=basering; d:=0;  
  if null(rf:=get('cali,'evlf)) then 
	rederr"For DUALHBASIS no evaluation function defined";
  for each ev1 in q do
     if lf!=zero ev1 then 
     << if cali_trace()>20 then dp_print2 car q; g:=car q . g >>
     else 
     << vars:=v; q1:=ev1.q1;
        while vars do 
        << l:={ev1, vars, mo_from_a car vars}.l; vars:=cdr vars >>;
     >>;
  q:=sort(q1,function lf!=less); % The reducer in triangular order.
  l1:=sort(l,function lf!=sort); % The queue in increasing term order. 
  repeat
  << % Initialize the computation of the next degree.
     l:=l1; q:=l1:=nil; d:=d+1;
     while l do
     << r:=car l; l:=cdr l;
        vars:=second r; r:=car r;
        p:=lf!=reduce(apply2(rf,r,car vars),q);
        if lf!=zero p then 
        << if cali_trace()>20 then dp_print2 car p; 
           g:=bas_make(0,car p) . g 
        >>
        else 
        << q:=merge({p},q,function lf!=less); 
	   u:=nil; v:=dp_lmon car p;
           while vars do 
           << u:={p,vars,mo_sum(v,mo_from_a car vars)}.u; 
              vars:=cdr vars 
           >>;
           l1:=merge(sort(u,function lf!=sort),l1,function lf!=sort);
        >>;
        g:=bas_renumber bas_zerodelete g;
        a:=dpmat_make(length g,0,g,nil,t);
     >>;
  >>
  until (d>=s) or ((dim!* a = 1) and (length q = s));
  return interreduce!* groeb_mingb a;
  end;

symbolic procedure lf!=compact u; 
% Sort the cdr of the lf u and remove zeroes.
  sort(for each x in u join if not bc_zero!? cdr x then {x},
	function (lambda(x,y); apply2(get('cali,'varlessp),car x,car y)));

symbolic procedure lf!=zero l; null cdr l;

symbolic procedure lf!=sum(a,b); 
  dp_sum(car a,car b) . lf!=sum1(cdr a,cdr b);

symbolic procedure lf!=times_bc(z,a);
  dp_times_bc(z,car a) . lf!=times_bc1(z,cdr a);

symbolic procedure lf!=times_bc1(z,a);
  if bc_zero!? z then nil
  else for each x in a collect car x . bc_prod(z,cdr x);

symbolic procedure lf!=sum1(a,b);
  if null a then b
  else if null b then a
  else if equal(caar a,caar b) then
        (if bc_zero!? u then lf!=sum1(cdr a,cdr b)
        else (caar a . u).lf!=sum1(cdr a,cdr b))
        where u:=bc_sum(cdar a,cdar b)
  else if apply2(get('cali,'varlessp),caar a,caar b) then 
        (car a).lf!=sum1(cdr a,b)
  else (car b).lf!=sum1(a,cdr b);

symbolic procedure lf!=simp a;
  if null cdr a then car dp_simp car a. nil
  else begin scalar z;
    if (z:=bc_inv lf!=lc a) then return lf!=times_bc(z,a);
    z:=dp_content car a;
    for each x in cdr a do z:=bc_gcd(z,cdr x);
    return (for each x in car a collect car x . bc_quot(cdr x,z)) .
        (for each x in cdr a collect car x . bc_quot(cdr x,z));
    end;

% Leading variable and coefficient assuming cdr a nonempty :

symbolic procedure lf!=lvar a; caadr a;
symbolic procedure lf!=lc a; cdadr a;

symbolic procedure lf!=less(a,b); 
        apply2(get('cali,'varlessp),lf!=lvar a,lf!=lvar b);

symbolic procedure lf!=reduce(a,l);
  if lf!=zero a or null l or lf!=less(a, car l) then a
  else if (lf!=lvar a = lf!=lvar car l) then 
    begin scalar z,z1,z2,b;
    b:=car l; z1:=bc_neg lf!=lc a; z2:=lf!=lc b;
    if !*bcsimp then
      << if (z:=bc_inv z1) then <<z1:=bc_fi 1; z2:=bc_prod(z2,z)>>
         else
           << z:=bc_gcd(z1,z2);
              z1:=bc_quot(z1,z);
              z2:=bc_quot(z2,z);
           >>;
      >>;
    a:=lf!=sum(lf!=times_bc(z2,a),lf!=times_bc(z1,b));
    if !*bcsimp then a:=lf!=simp a;
    return lf!=reduce(a,cdr l)
    end
  else lf!=reduce(a,cdr l);

% ------------ Application to point evaluation -------------------

% cali has additionally 'varnames and 'sublist.
% It works also for symbolic matrix entries.

symbolic operator affine_points;
symbolic procedure affine_points m;
% m is an algebraic matrix, which rows are the coordinates of points
% in the affine space with Spec = the current ring.
  if !*mode='algebraic then dpmat_2a affine_points!* reval m
  else affine_points!* m;

symbolic procedure affine_points!* m;
  begin scalar names;
  if length(names:=ring_names cali!=basering) neq length cadr m then
        typerr(m,"coordinate matrix");
  put('cali,'sublist,for each x in cdr m collect pair(names,x));
  put('cali,'varnames, names:=for each x in cdr m collect gensym());
  put('cali,'varlessp,'lf!=pointvarlessp);
  put('cali,'evlf,'lf!=pointevlf);
  return lf_dualbasis(
        { dp_fi 1 . lf!=compact 
                for each x in names collect (x . bc_fi 1) });
  end;

symbolic operator proj_points;
symbolic procedure proj_points m;
% m is an algebraic matrix, which rows are the coordinates of _points
% in the projective space with Proj = the current ring.
  if !*mode='algebraic then dpmat_2a proj_points!* reval m
  else proj_points!* m;

symbolic procedure proj_points!* m;
% Points must be different in proj. space. This will not be tested !
  begin scalar u,names;
  if length(names:=ring_names cali!=basering) neq length cadr m then
        typerr(m,"coordinate matrix");
  put('cali,'sublist,u:=for each x in cdr m collect pair(names,x));
  put('cali,'varnames, names:=for each x in cdr m collect gensym());
  put('cali,'varlessp,'lf!=pointvarlessp);
  put('cali,'evlf,'lf!=pointevlf);
  return lf_dualhbasis(
        { dp_fi 1 . lf!=compact 
                for each x in names collect (x . bc_fi 1) },
        length u);
  end;

symbolic procedure lf!=pointevlf(p,x);
   begin scalar q; p:=dp_2a (q:=dp_prod(car p,dp_from_a x));
   return q . lf!=compact 
        pair(get('cali,'varnames),
        for each x in get('cali,'sublist) collect 
                bc_from_a subeval1(x,p));
   end;

symbolic procedure lf!=pointvarlessp(x,y); not ordp(x,y);

% ------ Application to Groebner bases under term order change ----

% ----- The version with borderbases :

% cali has additionally 'oldborderbasis.

put('change_termorder,'psopfn,'lf!=change_termorder);
symbolic procedure lf!=change_termorder m;
  begin scalar c,r;
  if (length m neq 2) then 
	rederr "Syntax : Change_TermOrder(dpmat identifier, new ring)";
  if (not idp car m) then typerr(m,"dpmat identifier");
  r:=ring_from_a reval second m; 
  m:=car m; intf_get m;
  if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  c:=change_termorder!*(c,r);
  return dpmat_2a c;
  end;

symbolic procedure change_termorder!*(m,r);
% m must be a zerodimensional gbasis with respect to the current term
% order, r the new ring (with the same var. names). 
% This procedure sets r as the current ring and computes a gbasis 
% of m with respect to r.
  if (dpmat_cols m neq 0) or not dimzerop!* m then 
        rederr("CHANGE_TERMORDER only for zerodimensional ideals")
  else if ring_names r neq ring_names cali!=basering then
        typerr(makelist ring_names r,"variable names")
  else begin scalar b; 
  if cali_trace()>20 then print"Precomputing the border basis";
  b:=for each x in odim_borderbasis m collect bas_dpoly x;
  if cali_trace()>20 then print"Borderbasis computed";
  setring!* r;
  put('cali,'oldborderbasis, for each x in b collect 
        {mo_neworder dp_lmon x, dp_lc x,dp_neg dp_neworder cdr x});
  put('cali,'varlessp,'lf!=tovarlessp);
  put('cali,'evlf,'lf!=toevlf);
  return lf_dualbasis({dp_fi 1 . dp_fi 1})
  end;

symbolic procedure lf!=tovarlessp(a,b); mo_compare(a,b)=1;

symbolic procedure lf!=toevlf(p,x);
  begin scalar a,b,c,d;
  x:=mo_from_a x; c:=get('cali,'oldborderbasis);
  p:=dp_times_mo(x,car p).dp_times_mo(x,cdr p); 
	% Now reduce the terms in cdr p with the old borderbasis.
  for each x in cdr p do 
      % b is the list of terms already in canonical form,
      % a is a list of (can. form) . (bc_quot), where bc_quot is
      %         a pair of bc's interpreted as a rational multiplier
      %         for the can. form.
      if d:=assoc(car x,c) then a:=(third d . (cdr x . second d)) .a 
      else b:=x.b;
  a:=for each x in a collect car x . lf!=reducebc cdr x;
  d:=lf!=denom a;
  a:=for each x in a collect 
                dp_times_bc(bc_quot(bc_prod(d,cadr x),cddr x),car x);
  b:=dp_times_bc(d,reversip b);
  for each x in a do b:=dp_sum(x,b);
  return dp_times_bc(d,car p) . b;
  end;

symbolic procedure lf!=reducebc z;
  begin scalar g;
  if g:=bc_inv cdr z then return bc_prod(g,car z) . bc_fi 1;
  g:=bc_gcd(car z,cdr z);
  return bc_quot(car z,g) . bc_quot(cdr z,g);
  end;
  
symbolic procedure lf!=denom a;
  if null a then bc_fi 1
  else if null cdr a then cddar a
  else bc_lcm(cddar a,lf!=denom cdr a);

% ----- The version without borderbases :

% cali has additionally 'oldring, 'oldbasis

put('change_termorder1,'psopfn,'lf!=change_termorder1);
symbolic procedure lf!=change_termorder1 m;
  begin scalar c,r;
  if (length m neq 2) then 
	rederr "Syntax : Change_TermOrder1(dpmat identifier, new ring)";
  if (not idp car m) then typerr(m,"dpmat identifier");
  r:=ring_from_a reval second m; 
  m:=car m; intf_get m;
  if not (c:=get(m,'gbasis)) then 
	put(m,'gbasis,c:=gbasis!* get(m,'basis));
  c:=change_termorder1!*(c,r);
  return dpmat_2a c;
  end;

symbolic procedure change_termorder1!*(m,r);
% m must be a zerodimensional gbasis with respect to the current term
% order, r the new ring (with the same var. names). 
% This procedure sets r as the current ring and computes a gbasis 
% of m with respect to r.
  if (dpmat_cols m neq 0) or not dimzerop!* m then 
        rederr("change_termorder1 only for zerodimensional ideals")
  else if ring_names r neq ring_names cali!=basering then
        typerr(makelist ring_names r,"variable names")
  else begin scalar c,d; 
  c:=if dpmat_cols m=0 then {dp_fi 1}
        else for k:=1:dpmat_cols m collect dp_from_ei k;
  put('cali,'varlessp,'lf!=tovarlessp1);
  put('cali,'evlf,'lf!=toevlf1);
  put('cali,'oldring,cali!=basering);
  put('cali,'oldbasis,m);
  setring!* r;
  d:=if dpmat_cols m=0 then {dp_fi 1}
        else for k:=1:dpmat_cols m collect dp_from_ei k;
  return lf_dualbasis(pair(d,c))
  end;

symbolic procedure lf!=tovarlessp1(a,b); 
  (mo_compare(a,b)=1) 
  where cali!=basering=get('cali,'oldring);

symbolic procedure lf!=toevlf1(p,x);
% p = ( a . b ). Returns (c*a*x,d) where (d.c)=mod!*(b*x,m). 
  begin scalar a,b,c,d;
  a:=dp_times_mo(mo_from_a x,car p);
  (<< b:=dp_times_mo(mo_from_a x,cdr p);
      b:=mod!*(b,get('cali,'oldbasis));
      d:=car b; c:=dp_lc cdr b;
   >>) where cali!=basering:=get('cali,'oldring);
  return dp_times_bc(c,a) . d;
  end;

endmodule; % lf

module triang;

COMMENT

		##########################################
		##					##
		##    Solving zerodimensional systems   ##
		##	    Triangular systems		##
		##					##
		##########################################


Zerosolve returns lists of dpmats in prefix form, that consist of
triangular systems in the sense of Lazard, provided the input is
radical. For the corresponding definitions and concepts see

[Lazard] D. Lazard: Solving zero dimensional algebraic systems.
		J. Symb. Comp. 13 (1992), 117 - 131.
and 

[EFGB] H.-G. Graebe: Triangular systems and factorized Groebner
		bases. Report Nr. 7 (1995), Inst. f. Informatik,
			Univ. Leipzig. 


The triangularization of zerodim. ideal bases is done by Moeller's 
approach, see
	
[Moeller] H.-M. Moeller : On decomposing systems of polynomial
	equations with finitely many solutions. 
	J. AAECC 4 (1993), 217 - 230. 
 
We present three implementations :
	-- the pure lex gb (zerosolve)
	-- the "slow turn to pure lex" (zerosolve1)
and
	-- the mix with [FGLM] (zerosolve2)

END COMMENT;

symbolic procedure triang!=trsort(a,b); 
  mo_dlexcomp(dp_lmon a,dp_lmon b);

symbolic procedure triang!=makedpmat x;
  makelist for each p in x collect dp_2a p;

% =================================================================
% The pure lex approach.

symbolic operator zerosolve;
symbolic procedure zerosolve m;  
  if !*mode='algebraic then makelist zerosolve!* dpmat_from_a m 
  else zerosolve!* m;

symbolic procedure zerosolve!* m;
% Solve a zerodimensional dpmat ideal m, first groebfactor it and then
% triangularize it. Returns a list of dpmats in prefix form. 
 if (dpmat_cols m>0) or (dim!* m>0) then
        rederr"ZEROSOLVE only for zerodimensional ideals"
 else if not !*noetherian or ring_degrees cali!=basering then
        rederr"ZEROSOLVE only for pure lex. term orders"
 else for each x in groebfactor!*(m,nil) join triang_triang car x;

symbolic procedure triang_triang m;
% m must be a zerodim. ideal gbasis (recommended to be radical)
% wrt. a pure lex term order.
% Returns a list l of dpmats in triangular form.
 if (dpmat_cols m>0) or (dim!* m>0) then
        rederr"Triangularization only for zerodimensional ideals"
 else if not !*noetherian or ring_degrees cali!=basering then
        rederr"Triangularization only for pure lex. term orders"
 else for each x in triang!=triang(m,ring_names cali!=basering) collect
                triang!=makedpmat x;
     
symbolic procedure triang!=triang(A,vars);
% triang!=triang(A,vars)={f1.x for x in triang!=triang(B,cdr vars)} 
%                       \union triang!=triang(A:<B>,vars)
% where A={f1,...,fr}, B={f2~,...fr~}, see [Moeller].
% Returns a list of polynomial lists.
  if dpmat_unitideal!? A then nil
  else begin scalar x,f1,m1,m2,B;
    x:=car vars;
    m1:=sort(for each x in dpmat_list A collect bas_dpoly x,
                function triang!=trsort);
    if length m1 = length vars then return {m1};
    f1:=car m1;
    m2:=for each y in cdr m1 collect bas_make(1,dp_xlt(y,x));
    B:=interreduce!* dpmat_make(length m2,0,m2,nil,nil);
    return append(
    for each u in triang!=triang(B,cdr vars) collect (f1 . u),
                triang!=triang(matstabquot!*(A,B),vars));
    end;

% =================================================================
% Triangularization wrt. an arbitrary term order

symbolic operator zerosolve1;
symbolic procedure zerosolve1 m;  
  if !*mode='algebraic then makelist zerosolve1!* dpmat_from_a m 
  else zerosolve1!* m;

symbolic procedure zerosolve1!* m;
   for each x in groebfactor!*(m,nil) join triang_triang1 car x;

symbolic procedure triang_triang1 m;
% m must be a zerodim. ideal gbasis (recommended to be radical)
% Returns a list l of dpmats in triangular form.
 if (dpmat_cols m>0) or (dim!* m>0) then
        rederr"Triangularization only for zerodimensional ideals"
 else if not !*noetherian then
        rederr"Triangularization only for noetherian term orders"
 else for each x in triang!=triang1(m,ring_names cali!=basering) collect
                triang!=makedpmat x;
     
symbolic procedure triang!=triang1(A,vars);
% triang!=triang(A,vars)={f1.x for x in triang!=triang1(B,cdr vars)} 
%                       \union triang!=triang1(A:<B>,vars)
% where A={f1,...,fr}, B={f2~,...fr~}, see [Moeller].
% Returns a list of polynomial lists.
  if dpmat_unitideal!? A then nil
  else if length vars = 1 then {{bas_dpoly first dpmat_list A}}
  else (begin scalar u,x,f1,m1,m2,B,vars1,res;
    x:=car vars; vars1:=ring_names cali!=basering;
    setring!* ring_define(vars1,eliminationorder!*(vars1,{x}),
                        'revlex,ring_ecart cali!=basering);    
    a:=groebfactor!*(dpmat_neworder(a,nil),nil);
    % Constraints in dimension zero may be skipped :
    a:=for each x in a collect car x;
    for each u in a do
    << m1:=sort(for each x in dpmat_list u collect bas_dpoly x,
                function triang!=trsort);
       f1:=car m1;
       m2:=for each y in cdr m1 collect bas_make(1,dp_xlt(y,x));
       B:=interreduce!* dpmat_make(length m2,0,m2,nil,nil);
       res:=nconc(append(
       for each v in triang!=triang1(B,cdr vars) collect (f1 . v),
                triang!=triang1a(matstabquot!*(u,B),vars)),res);
    >>;
    return res;                
    end) where cali!=basering=cali!=basering;

symbolic procedure triang!=triang1a(A,vars);
% triang!=triang(A,vars)={f1.x for x in triang!=triang1(B,cdr vars)} 
%                       \union triang!=triang1(A:<B>,vars)
% where A is already a gr basis wrt. the elimination order.
% Returns a list of polynomial lists.
  if dpmat_unitideal!? A then nil
  else if length vars = 1 then {{bas_dpoly first dpmat_list A}}
  else begin scalar u,x,f1,m1,m2,B,vars1;
    x:=car vars; 
    m1:=sort(for each x in dpmat_list a collect bas_dpoly x,
                function triang!=trsort);
    f1:=car m1;
    m2:=for each y in cdr m1 collect bas_make(1,dp_xlt(y,x));
    B:=interreduce!* dpmat_make(length m2,0,m2,nil,nil);
    return append(
       for each u in triang!=triang1(B,cdr vars) collect (f1 . u),
                triang!=triang1a(matstabquot!*(A,B),vars));
    end;

% =================================================================
% Triangularization wrt. an arbitrary term order and FGLM approach.

symbolic operator zerosolve2;
symbolic procedure zerosolve2 m;  
  if !*mode='algebraic then makelist zerosolve2!* dpmat_from_a m 
  else zerosolve2!* m;

symbolic procedure zerosolve2!* m;
% Solve a zerodimensional dpmat ideal m, first groebfactoring it and
% secondly triangularizing it.
   for each x in groebfactor!*(m,nil) join triang_triang2 car x;

symbolic procedure triang_triang2 m;
% m must be a zerodim. ideal gbasis (recommended to be radical)
% Returns a list l of dpmats in triangular form.
 if (dpmat_cols m>0) or (dim!* m>0) then
        rederr"Triangularization only for zerodimensional ideals"
 else if not !*noetherian then
        rederr"Triangularization only for noetherian term orders"
 else for each x in triang!=triang2(m,ring_names cali!=basering) 
	collect triang!=makedpmat x;
     
symbolic procedure triang!=triang2(A,vars);
% triang!=triang(A,vars)={f1.x for x in triang!=triang2(B,cdr vars)} 
%                       \union triang!=triang2(A:<B>,vars)
% where A={f1,...,fr}, B={f2~,...fr~}, see [Moeller].
% Returns a list of polynomial lists.
  if dpmat_unitideal!? A then nil
  else if length vars = 1 then {{bas_dpoly first dpmat_list A}}
  else (begin scalar u,x,f1,m1,m2,B,vars1,vars2,extravars,res,c1;
    x:=car vars; vars1:=ring_names cali!=basering;
    extravars:=dpmat_from_a('list . (vars2:=setdiff(vars1,vars)));
    % We need this to make A truely zerodimensional.
    c1:=ring_define(vars1,eliminationorder!*(vars1,{x}),
                        'revlex,ring_ecart cali!=basering);    
    a:=matsum!* {extravars,a};
    u:=change_termorder!*(a,c1);
    a:=groebfactor!*(dpmat_sieve(u,vars2,nil),nil);
    % Constraints in dimension zero may be skipped :
    a:=for each x in a collect car x;
    for each u in a do
    << m1:=sort(for each x in dpmat_list u collect bas_dpoly x,
                function triang!=trsort);
       f1:=car m1;
       m2:=for each y in cdr m1 collect bas_make(1,dp_xlt(y,x));
       B:=interreduce!* dpmat_make(length m2,0,m2,nil,nil);
       res:=nconc(append(
       for each v in triang!=triang2(B,cdr vars) collect (f1 . v),
                triang!=triang2a(matstabquot!*(u,B),vars)),res);
    >>;
    return res;                
    end) where cali!=basering=cali!=basering;

symbolic procedure triang!=triang2a(A,vars);
% triang!=triang(A,vars)={f1.x for x in triang!=triang2(B,cdr vars)} 
%                       \union triang!=triang2(A:<B>,vars)
% where A is already a gr basis wrt. the elimination order.
% Returns a list of polynomial lists.
  if dpmat_unitideal!? A then nil
  else if length vars = 1 then {{bas_dpoly first dpmat_list A}}
  else begin scalar u,x,f1,m1,m2,B,vars1;
    x:=car vars; 
    m1:=sort(for each x in dpmat_list a collect bas_dpoly x,
                function triang!=trsort);
    f1:=car m1;
    m2:=for each y in cdr m1 collect bas_make(1,dp_xlt(y,x));
    B:=interreduce!* dpmat_make(length m2,0,m2,nil,nil);
    return append(
       for each u in triang!=triang2(B,cdr vars) collect (f1 . u),
                triang!=triang2a(matstabquot!*(A,B),vars));
    end;

endmodule; % triang

end;
