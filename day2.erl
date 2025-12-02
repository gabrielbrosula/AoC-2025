-module(day2).
-export([p1/0, p2/0, get_invalid_p2/2, is_invalid_p2/2, build_patterns/1, check_patterns/2, is_repeating_from_pattern/2]).

p1() ->
    Ranges = get_ranges(),
    GetInvalidIdsFn = fun get_invalid_p1/2,
    InvalidIds = lists:merge(lists:foldl(
        GetInvalidIdsFn,
        [],
        Ranges
    )),

    Sum = lists:foldl(fun(X, Sum) -> X + Sum end, 0, InvalidIds),
    erlang:display(Sum).

get_ranges() ->
    FileName = "input/2.txt",
    FileOutput = lists:nth(1, util:read_file(FileName)),
    string:tokens(FileOutput, ",").

get_invalid_p1(Range, Acc) ->
    % Range Str is always of the form "X-Y" where X and Y are integers
    [LowStr, HighStr] = string:tokens(Range, "-"),
    [Low, High] = [list_to_integer(X) || X <:- [LowStr, HighStr]],
    Seq = lists:seq(Low, High),

    IsInvalidFn = fun is_invalid_p1/2,
    ResultFromSeq = lists:foldl(
        IsInvalidFn,
        [],
        Seq
    ),
    [ResultFromSeq|Acc].

    %io:format("Invalid Ids in get_invalid_ids fn~n"),
    %erlang:display(InvalidIds).

is_invalid_p1(Num, Acc) ->
    NumStr = integer_to_list(Num),
    StrLen = string:len(NumStr),
    Res = invalid_checker(Num, StrLen, Acc),
    %io:format("Result of is is_invalid_id(Num = ~p, Acc = ~p): ~p~n", [Num, Acc, Res]),
    Res.

% Prepends num to acc if second argument (string length modulus) is 0 and 
% first half == second half
invalid_checker(Num, StrLen, Acc) when StrLen rem 2 == 0 ->
    NumStr = integer_to_list(Num),
    FirstHalf = string:slice(NumStr, 0, StrLen div 2),
    SecondHalf = string:slice(NumStr, StrLen div 2, StrLen),
    case FirstHalf == SecondHalf of
        true -> Ret = [Num|Acc];
        false -> Ret = Acc
    end,
    %io:format("Num: ~p, FirstHalf: ~p, SecondHalf: ~p, Ret: ~p~n", [Num, FirstHalf, SecondHalf, Ret]),
    Ret;
invalid_checker(_, StrLen, Acc) when StrLen rem 2 == 1-> Acc.

p2() -> 
    Ranges = get_ranges(),
    GetInvalidIdsFn = fun get_invalid_p2/2,

    InvalidIds = lists:merge(lists:foldl(
        GetInvalidIdsFn,
        [],
        Ranges
    )),

    Sum = lists:foldl(fun(X, Sum) -> X + Sum end, 0, InvalidIds),
    erlang:display(Sum).
 
get_invalid_p2(Range, Acc) ->
    % Range Str is always of the form "X-Y" where X and Y are integers
    [LowStr, HighStr] = string:tokens(Range, "-"),
    [Low, High] = [list_to_integer(X) || X <:- [LowStr, HighStr]],
    Seq = lists:seq(Low, High),

    IsInvalidFn = fun is_invalid_p2/2,
    ResultFromSeq = lists:foldl(
        IsInvalidFn,
        [],
        Seq
    ),
    
    NewAcc = [ResultFromSeq|Acc],

    %io:format("Invalid Ids in get_invalid_p2 fn~n"),
    %io:format("~w~n", [ResultFromSeq]),

    NewAcc.

is_invalid_p2(Num, Acc) ->
    NumStr = integer_to_list(Num),
    Patterns = build_patterns(NumStr),
    IsRepeating = check_patterns(NumStr, Patterns),

    %io:format("IsRepeating(~p)? ~p~n", [Num, IsRepeating]),

    case IsRepeating of
        true -> [Num|Acc];
        false -> Acc
    end.


% Build patterns
% 824824824 should have the patterns list ["8", "82", "824", "8248"]
% 121 should have the patterns list ["1"]
build_patterns(NumStr) -> bp_helper(NumStr, 1, []).

% TODO: Revisit the pattern builder
bp_helper(NumStr, _, _) when length(NumStr) == 1 -> [false];
bp_helper(NumStr, Idx, Acc) when Idx == length(NumStr) div 2 -> [string:slice(NumStr, 0, Idx)|Acc];
bp_helper(NumStr, Idx, Acc) when Idx < length(NumStr) div 2 ->
    NewAcc = [string:slice(NumStr, 0, Idx)|Acc],
    bp_helper(NumStr, Idx + 1, NewAcc).

check_patterns(NumStr, Patterns) ->
    PatternCheckResults = [is_repeating_from_pattern(NumStr, P) || P <- Patterns, is_list(P)],
    lists:any(fun(Res) -> Res == true end, PatternCheckResults).

% Pattern must be a valid prefix of the string.
% TODO: Revisit the pattern checking
is_repeating_from_pattern(NumStr, Pattern) ->
    PatternLen = length(Pattern),
    Suffix = string:slice(NumStr, PatternLen),

    SubstringsOfPatternLength = split_by_n(Suffix, PatternLen),
    AllMatch = lists:all(fun(S) -> S == Pattern end, SubstringsOfPatternLength),
    AllMatch andalso length(SubstringsOfPatternLength) >= 2.
    
split_by_n(String, N) -> split_helper(String, N, []).

split_helper([], _, Acc) -> lists:reverse(Acc);

split_helper(String, N, Acc) when N > length(String) -> 
    NewAcc = [String|Acc],
    split_helper([], N, NewAcc);

split_helper(String, N, Acc) when N =< length(String) -> 
    NewAcc = [string:slice(String, 0, N) | Acc],
    NewStr = string:slice(String, N),
    split_helper(NewStr, N, NewAcc).


