% berkay demirtaş
% 2017400234
% compiling: yes
% complete: yes

features([explicit-0, danceability-1, energy-1,
          key-0, loudness-0, mode-1, speechiness-1,
       	  acousticness-1, instrumentalness-1,
          liveness-1, valence-1, tempo-0, duration_ms-0,
          time_signature-0]).

filter_features(Features, Filtered) :- features(X), filter_features_rec(Features, X, Filtered).


filter_features_rec([], [], []).
filter_features_rec([FeatHead|FeatTail], [Head|Tail], FilteredFeatures) :-
    filter_features_rec(FeatTail, Tail, FilteredTail),
    _-Use = Head,
    (
        (Use is 1, FilteredFeatures = [FeatHead|FilteredTail]);
        (Use is 0,
            FilteredFeatures = FilteredTail
        )
    ).

% artist(ArtistName, Genres, AlbumIds).
% album(AlbumId, AlbumName, ArtistNames, TrackIds).
% track(TrackId, TrackName, ArtistNames, AlbumName, [Explicit, Danceability, Energy,
%                                                    Key, Loudness, Mode, Speechiness,
%                                                    Acousticness, Instrumentalness, Liveness,
%                                                    Valence, Tempo, DurationMs, TimeSignature]).



   % appendTracksID(+List1,-Result) . This predicate takes a list of track names and 
   % append all of the ids correspond to this tracks to a list(Result) .
   appendTracksID([],[]). 
   appendTracksID([Head|Tail],Result) :-
   album(Head,_,_,D),
   appendTracksID(Tail,Resultt) ,
   append(D,Resultt,Result).

  % appendTracks(+List1,-Result) . This predicate takes a list of track ids and 
  % append all of the names correspond to this tracks to a list(Result) .
   appendTracks([],[]). 
   appendTracks([Head|Tail],Resulttt) :-
   track(Head,T,_,_,_),
   appendTracks(Tail,Resultttt) ,
   Resulttt=[T|Resultttt].
   
  getArtistTracks(ArtistName, Result,Result2):-
    artist(ArtistName,_,AlbumId), appendTracksID(AlbumId,Result) , appendTracks(Result,Result2) .


% sum(+List,-A,-B,-C,-D,-E,-F,-G,-H) . This predicate takes a list of track ids and sum useful 
% track features . For example after invoking this predicate , A is equal to sum of danceability features of all tracks in 
% track list.
sum([],0,0,0,0,0,0,0,0).
sum([Head|Tail],A,B,C,D,E,F,G,H):-
  track(Head,_,_,_,[_,A3,B3,_,_,C3,D3,E3,F3,G3,H3,_,_,_]),
  sum(Tail,A2,B2,C2,D2,E2,F2,G2,H2),
  A is A2 + A3,
  B is B2 + B3,
  C is C2 + C3,
  D is D2 + D3,
  E is E2 + E3,
  F is F2 + F3,
  G is G2 + G3,
  H is H2 + H3.

 % divide(+W,+A,+B,+C,+D,+E,+F,+G,+H,-A1,-B1,-C1,-D1,-E1,-F1,-G1,-H1) . This predicate divides A,B...H to W and put results to A1,B1....H1 .
  divide(W,A,B,C,D,E,F,G,H,A1,B1,C1,D1,E1,F1,G1,H1):-
     A1 is A/W,
     B1 is B/W,
     C1 is C/W,
     D1 is D/W,
     E1 is E/W,
     F1 is F/W,
     G1 is G/W,
     H1 is H/W.
   

albumFeatures(AlbumId, AlbumFeatures):-
   AlbumId2=[AlbumId|[]],
   appendTracksID(AlbumId2,Result),
   sum(Result,A,B,C,D,E,F,G,H),
   length(Result,W),
   divide(W,A,B,C,D,E,F,G,H,A1,B1,C1,D1,E1,F1,G1,H1),
   append([A1,B1,C1,D1,E1,F1,G1,H1],[],AlbumFeatures).

    

% totalLength(+List,-W) , calculates size of the list.
totalLength([],0).
totalLength([_|Tail],W):-
   totalLength(Tail,W2),
     W is W2+1.

% subs(+List1,+List2,-Result). substitute first element of list2 from list1 , second element of list2 from list1 ...
% and put them to result with order.
subs([],[],[]).
subs([Head1|Tail1],[Head2|Tail2],Result):-
   X is Head1-Head2,
   subs(Tail1,Tail2,Result2),
   Result= [X|Result2].


% squareAndSum(List1,Result) . takes square of all elements of List1 and sum them .
squareAndSum([],0).
squareAndSum([Head|Tail],Result):-
    X is Head*Head,
    squareAndSum(Tail,Result2),
    Result is X+Result2 .


 artistFeatures(ArtistName, ArtistFeatures) :-
   artist(ArtistName,_,AlbumId) , appendTracksID(AlbumId,Result),totalLength(Result,W),sum(Result,A,B,C,D,E,F,G,H), divide(W,A,B,C,D,E,F,G,H,A1,B1,C1,D1,E1,F1,G1,H1),
   append([A1,B1,C1,D1,E1,F1,G1,H1],[],ArtistFeatures).

 trackDistance(TrackId1, TrackId2, Score) :-
    track(TrackId1,_,_,_,Res1) , track(TrackId2,_,_,_,Res2) , subs(Res1,Res2,List) , filter_features(List,List2) ,
    squareAndSum(List2,Res3) , Score is sqrt(Res3) .


 albumDistance(AlbumId1, AlbumId2, Score) :-
   albumFeatures(AlbumId1,Res1) , albumFeatures(AlbumId2,Res2) , subs(Res1,Res2,List2) , squareAndSum(List2,Res3) , Score is sqrt(Res3) .

artistDistance(ArtistName1, ArtistName2, Score):-
artistFeatures(ArtistName1,Res1) , artistFeatures(ArtistName2,Res2) , subs(Res1,Res2,List2) , squareAndSum(List2,Res3) , Score is sqrt(Res3) .


% allTrackDistance(+List1,+Tr1,-Result) , calculates distance of elements of list1 to Tr1 and put all results to Result.
allTrackDistance([],_,[]).
allTrackDistance([Head|Tail],Tr1,Result):-
  trackDistance(Tr1,Head,Score),
  X = (Score,Head),
  allTrackDistance(Tail,Tr1,Result2),
  Result=[X|Result2].

% take30(+List,+N,-Result) . puts first 30 element of list to Result . (N=30) .
take30(_,0,[]).
take30([Head|Tail],N,Result):-
  M is N-1,
  take30(Tail,M,Result2),
  Result=[Head|Result2]. 


% deletes head of a list and puts tail to Result.
deleteHead([_|Tail],Result):-
Result=Tail.

% takes second item of a tuple.
extract_second_item([], []).
extract_second_item([(_,X)|T], [X|T2]):- extract_second_item(T,T2).



findMostSimilarTracks(TrackId, SimilarIds, SimilarNames):-
findall(X, (track(X,_,_,_,_)), L),
allTrackDistance(L,TrackId,List1),
sort(List1,List2),
extract_second_item(List2, List3),
deleteHead(List3,List4),
take30(List4,30,List5),
SimilarIds = List5,
appendTracks(List5,List6) ,
SimilarNames = List6 .
 


% allAlbumDistance(+List,+Tr1,-Result) . calculates distance of elements of list1 to Tr1 and put all results to Result.
allAlbumDistance([],_,[]).
allAlbumDistance([Head|Tail],Tr1,Result):-
  albumDistance(Tr1,Head,Score),
  X = (Score,Head),
  allAlbumDistance(Tail,Tr1,Result2),
  Result=[X|Result2].

% appendAlbums(+List,-Resulttt) . takes a list that consists of album ids and append album names. 
appendAlbums([],[]). 
   appendAlbums([Head|Tail],Resulttt) :-
   album(Head,T,_,_),
   appendAlbums(Tail,Resultttt) ,
   Resulttt=[T|Resultttt].

findMostSimilarAlbums(AlbumId, SimilarIds, SimilarNames) :-
findall(X,(album(X,_,_,_)),L) ,
allAlbumDistance(L,AlbumId,List1),
sort(List1,List2),
extract_second_item(List2, List3),
deleteHead(List3,List4),
take30(List4,30,List5),
SimilarIds = List5,
appendAlbums(List5,List6) ,
SimilarNames = List6 .
 
% allArtistDistance(+List1,+Tr1,-Result), calculates distance of elements of list1 to Tr1 and put all results to Result.
allArtistDistance([],_,[]).
allArtistDistance([Head|Tail],Tr1,Result):-
  artistDistance(Tr1,Head,Score),
  X = (Score,Head),
  allArtistDistance(Tail,Tr1,Result2),
  Result=[X|Result2].

% find max element .
max(X,Y,Z) :-
    (  X =< Y
    -> Z = Y
    ;  Z = X
    ).

findMostSimilarArtists(ArtistName, SimilarArtists) :-
findall(X,(artist(X,_,_)),L) ,
allArtistDistance(L,ArtistName,List1),
sort(List1,List2),
extract_second_item(List2, List3),
deleteHead(List3,List4),
take30(List4,30,List5),
SimilarArtists = List5.


% filterEx(+List1, -Result) . takes a list and append the tracks that have explicit value 0 to Result
filterEx( [],[]  ).
filterEx([Head|Tail], Result):-
track(Head,_,_,_,[A,_,_,_,_,_,_,_,_,_,_,_,_,_]),
filterEx(Tail, Result2),
(
     A<1
  -> Result=[Head|Result2]    
  ; Result=Result2
).


filterExplicitTracks(TrackList, FilteredTracks) :-
filterEx(TrackList,Result), 
FilteredTracks= Result .


% getGenres(+List,-Result) , takes a track list and appends artist genres of tracks that are in this list to Result.
getGenres([],[]).
getGenres([Head|Tail],Result):-
artist(Head,A,_),
getGenres(Tail,Result2),
append(A,Result2,Result).


getTrackGenre(TrackId, Genres) :-
track(TrackId,_,List1,_,_),
getGenres(List1,List2),
list_to_set(List2,List3),
Genres= List3 .


% disLikedGen(+List1,+DislikedGenres,-Result) . filter all tracks in list1 according to DislikedGenres. Put result to Result list.
disLikedGen([],_,[]).
disLikedGen([Head|Tail],DislikedGenres,Result):-

disLikedGen(Tail,DislikedGenres,Result2),
getTrackGenre(Head,Res),
  subsitr(Res,DislikedGenres,Res2),
(
  Res2<1 
  -> Result=[Head|Result2] 
   ; Result=Result2 
).

% likedGen(+List1,+LikedGenres,-Result) filter all tracks in list1 according to LikedGenres. Put result to Result list.
likedGen([],_,[]).
likedGen([Head|Tail],LikedGenres,Result):-
likedGen(Tail,LikedGenres,Result2),
getTrackGenre(Head,Res),
  subsitr(Res,LikedGenres,Res2),
 (
  Res2>0 
  -> Result=[Head|Result2] 
   ; Result=Result2 
).

% subsitr2(+Element,+List,-Result) . checks whether genres of Element contains a substring that is in List. 
% Result=0 means there is not , Result>0 means there is.
subsitr2(_,[],0).
subsitr2(Element,[Head|Tail],Result):-
subsitr2(Element,Tail,Result2),
(
sub_string(Element,_, _, _,Head)
-> Result is Result2+1 
; Result=Result2
).


% subsitr(+List1,+LikedGenres,-Result) , invokes subsitr2 fo r all elements of subsitr2. (Result=0 means there is not , Result>0 means there is.) . 
subsitr([],_,0).
subsitr([Head|Tail],LikedGenres,Result):-
subsitr2(Head,LikedGenres,Result2),
subsitr(Tail,LikedGenres,Result3),
Result is Result3+Result2 .


% allTrackDistance2(+List1,+Tr1,+Result) . it is same with allTrackDistance2 but it takes a set of features instead of 1 track id.
allTrackDistance2([],_,[]).
allTrackDistance2([Head|Tail],Tr1,Result):-
  trackDistance2(Tr1,Head,Score),
  X = (Score,Head),
  allTrackDistance2(Tail,Tr1,Result2),
  Result=[X|Result2].

% trackDistance2(+Res2,+TrackId1, -Score) . it is same with trackDistance but it takes a set of features instead of 1 track id.
  trackDistance2(Res2,TrackId1, Score) :-
    track(TrackId1,_,_,_,Res1)  , filter_features(Res1,Res4), subs(Res4,Res2,List2)  ,
    squareAndSum(List2,Res3) , Score is sqrt(Res3) .

% artistsss(+List1,-Result) . Concatanetes all artists of tracks that are in List1. 
   artistsss([],[]).
   artistsss([Head|Tail],Result):-
   track(Head,_,List1,_,_), 
   artistsss(Tail,Result2),
   Result=[List1|Result2].


% takes first item of tuple .
extract_first_item([], []).
extract_first_item([(X,_)|T], [X|T2]):- extract_first_item(T,T2).


discoverPlaylist(LikedGenres, DislikedGenres, Features, FileName, Playlist) :-
findall(X, (track(X,_,_,_,_)), List1),
likedGen(List1,LikedGenres,List2),
disLikedGen(List2,DislikedGenres,List3),
allTrackDistance2(List3,Features,List4),
sort(List4,List5),
extract_second_item(List5, List6),
take30(List6,30,List7),
Playlist = List7 ,
open(FileName,append,X),
write(X,List7),nl(X),
appendTracks(List7,List8),
write(X,List8),nl(X),
artistsss(List7,List9),
write(X,List9),nl(X),
extract_first_item(List5,List10),
take30(List10,30,List11),
write(X,List11),
close(X).





