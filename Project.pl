% Author:
% Date: 11-Mar-13

exams(csen403,1,0,0).
exams(csen401,1,0,1).
exams(elect401,1,0,1).
exams(comm401,1,1,1).
exams(math401,1,1,0).


location(theory,[h11,h12,h13]).
location(mcq,[h1,h2]).
location(practical,[c7201,c7203]).

enroll(hazem, csen403).
enroll(omar, csen403).
enroll(nada, csen403).
enroll(salma, csen403).
enroll(magd, csen403).
enroll(nouran, csen403).
enroll(lobna, csen403).
enroll(heba, csen403).


enroll(eslam, csen401).
enroll(hussein, csen401).
enroll(nadine, csen401).
enroll(yasmine, csen401).
enroll(ali, csen401).
enroll(nader, csen401).



enroll(hazem, elect401).
enroll(omar, elect401).
enroll(nada, elect401).
enroll(salma, elect401).
enroll(magd, elect401).
enroll(ahmed, elect401).
enroll(heba, elect401).



enroll(hazem, comm401).
enroll(omar, comm401).
enroll(nada, comm401).
enroll(lobna, comm401).
enroll(heba, comm401).


enroll(hazem, math401).
enroll(omar, math401).
enroll(nada, math401).
enroll(salma, math401).
enroll(magd, math401).
enroll(nouran, math401).
enroll(lobna, math401).
enroll(ahmed, math401).

type(Code,[theory]):- exams(Code,1,0,0).
type(Code,[theory,mcq]):- exams(Code,1,1,0).
type(Code,[practical]):- exams(Code,0,0,1).
type(Code,[mcq,practical]):- exams(Code,0,1,1).
type(Code,[theory,practical]):- exams(Code,1,0,1).
type(Code,[theory,mcq,practical]):- exams(Code,1,1,1).
type(Code,[mcq]):- exams(Code,0,1,0).

locations(Type,Location):-location(Type,Locations),member(Location,Locations).


%true when first exam put satisfies the type constraint (theortical before practical)
firstconstraint(Code,Type):-
exams(Code,1,_,1),
Type=theory.


firstconstraint(_,_).

types(Code,Type):- type(Code,Types),member(Type,Types).

%true when E is an element in a nested list
membernested(E,[H|_]):-member(E,H).
membernested(E,[_|T]):-membernested(E,T).

memberdoublenested(E,[H|_]):-membernested(E,H).
memberdoublenested(E,[_|T]):-memberdoublenested(E,T).

membertriplenested(E,[H|_]):-memberdoublenested(E,H).
membertriplenested(E,[_|T]):-membertriplenested(E,T).


%true when code does not clash with other exams of students taking it
studentconstraint(Code,Schedule,Dayindex):-bagof(Student,enroll(Student,Code),Students),custombag(Students,Exams),
examsnottakenbefore(Exams,Schedule,Dayindex).

examsnottakenbefore([H|T],S,Dayindex):-codenottakenbefore(H,S,Dayindex),examsnottakenbefore(T,S,Dayindex).
examsnottakenbefore([],_,_).

custombag([H|T],Exams):-bagof(Code,enroll(H,Code),Codes),append(Codes,Acodes,Exams),
custombag(T,Acodes).
custombag([],[]).

codenottakenbefore(Code,Schedule,Dayindex):- nth1(Dayindex,Schedule,Desiredday), \+membernested([Code,_,_],Desiredday).









%is true when the location is not used in the same slot
locationconstraint(Schedule,Location,Slotindex,Dayindex):-nth1(Dayindex,Schedule,Desiredday),
 nth1(Slotindex,Desiredday,Desiredslot), \+membernested(Location,Desiredslot).

%is true when theory preceds practical if both are present
theorybefprac(Code,_):-exams(Code,0,_,_).
theorybefprac(Code,_):-exams(Code,_,_,0).
theorybefprac(Code,Schedule):-memberdoublenested([Code,theory,_],Schedule).
theorybefprac(Code,Schedule):-memberdoublenested([Code,mcq,_],Schedule), \+memberdoublenested([Code,practical,_],Schedule).



%true when exam is not present in slot
examnottakenbefore(Code,Type,Schedule):- \+memberdoublenested([Code,Type,_],Schedule).

%adds exam in schedule in specific day and index and returns newschedule
addexam(Schedule,Exam,Dayindex,Slotindex,Newschedule):-
nth1(Dayindex,Schedule,Desiredday),
nth1(Slotindex,Desiredday,Desiredslot),
append(Desiredslot,[Exam],Newslot),
delete(Desiredday,Desiredslot,Unfinishedday),
nth1(Slotindex,Realday,Newslot,Unfinishedday),
delete(Schedule,Desiredday,Unfinisheds),
nth1(Dayindex,Newschedule,Realday,Unfinisheds).



%puts first exam satisfying only one constraint and moves on to complete the whole schedule
schedule(Realschedule):-
exams(Code,_,_,_),
types(Code,Type),
firstconstraint(Code,Type),
locations(Type,Location),
makeschedule([[[[Code,Type,Location]]]],Realschedule,1,1).



%general for putting exams in one slot UNFINISHED
makeschedule(Acc,Realschedule,Slotindex,Dayindex):-

exams(Code,_,_,_),
types(Code,Type),
studentconstraint(Code,Acc,Dayindex),
examnottakenbefore(Code,Type,Acc),
locations(Type,Location),
locationconstraint(Acc,Location,Slotindex,Dayindex),


addexam(Acc,[Code,Type,Location],Dayindex,Slotindex,Newsch),
theorybefprac(Code,Newsch),
makeschedule(Newsch,Realschedule,Slotindex,Dayindex).



makeschedule(Acc,Realschedule,Slotindex,Dayindex):-
Slotindex2 is Slotindex+1,
Slotindex2<4,
%selects day currently being filled
nth1(Dayindex,Acc,Desiredday),
%puts an empty slot in said day
nth1(Slotindex2,Newday,[],Desiredday),
%now we replace the day without the new slot
delete(Acc,Desiredday,Acc2),
nth1(Dayindex,Acc3,Newday,Acc2),
makeschedule(Acc3,Realschedule,Slotindex2,Dayindex).


makeschedule(Acc,Realschedule,_,Dayindex):-
Dayindex2 is Dayindex+1,
Dayindex2<14,
Dayindex2 \= 7,
Slotindex2 is 1,

nth1(Dayindex2,Acc2,[[]],Acc),
makeschedule(Acc2,Realschedule,Slotindex2,Dayindex2).

makeschedule(Acc,Realschedule,_,Dayindex):-
Dayindex2 is Dayindex+1,
Dayindex2=7,
nth1(Dayindex2,Acc2,[noexams],Acc),
nth1(8,Acc3,[[]],Acc2),

makeschedule(Acc3,Realschedule,1,8).



makeschedule(Acc,Realschedule,_,Dayindex):-
Dayindex2 is Dayindex+1,
Dayindex2=14,
nth1(Dayindex2,Acc2,[noexams],Acc),
Acc2=Realschedule.



studentschedule(Name,Schedule):- bagof(Code,enroll(Name,Code),Codes),getschedule(Codes,Schedule).




getschedule([H|T],Schedule):-

schedule(X),
nth1(Dayindex,X,Day),
nth1(Slotindex,Day,Slot),
member([H,Type,Location],Slot),


getschedule([H|T],Schedule,X,[[H,Type,Location,Dayindex,Slotindex]]).

getschedule([H|T],Schedule,X,Acc):-
nth1(Dayindex,X,Day),
nth1(Slotindex,Day,Slot),
member([H,Type,Location],Slot),
\+member([H,Type,Location,_,_],Acc),
append( [[H,Type,Location,Dayindex,Slotindex]],Acc,Acc2),
getschedule([H|T],Schedule,X,Acc2).

getschedule([_|T],Schedule,X,Acc):-
getschedule(T,Schedule,X,Acc).

getschedule([],Schedule,_,Schedule).




















