-module(day2).
-export([p1/0, p2/0, is_repeating/2]).

p1() ->
    Ranges = get_ranges(),
    GetInvalidIdsFn = fun get_invalid_ids/2,
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

get_invalid_ids(Range, Acc) ->
    % Range Str is always of the form "X-Y" where X and Y are integers
    [LowStr, HighStr] = string:tokens(Range, "-"),
    [Low, High] = [list_to_integer(X) || X <:- [LowStr, HighStr]],
    Seq = lists:seq(Low, High),

    GetInvalidIdsFn = fun is_invalid_id/2,
    ResultFromSeq = lists:foldl(
        GetInvalidIdsFn,
        [],
        Seq
    ),
    [ResultFromSeq|Acc].

    %io:format("Invalid Ids in get_invalid_ids fn~n"),
    %erlang:display(InvalidIds).

is_invalid_id(Num, Acc) ->
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
    %Ranges = get_ranges().
    is_repeating("824824824", "82").

% Pattern must be a valid prefix of the string.
is_repeating(String, Pattern) ->
    PatternLen = length(Pattern),
    Suffix = string:slice(String, PatternLen),

    SubstringsOfPatternLength = split_by_n(Suffix, PatternLen),
    lists:all(fun(S) -> S == Pattern end, SubstringsOfPatternLength).
    
split_by_n(String, N) -> split_helper(String, N, []).

split_helper([], _, Acc) -> lists:reverse(Acc);

split_helper(String, N, Acc) when N > length(String) -> 
    NewAcc = [String|Acc],
    split_helper([], N, NewAcc);

split_helper(String, N, Acc) when N =< length(String) -> 
    NewAcc = [string:slice(String, 0, N) | Acc],
    NewStr = string:slice(String, N),
    split_helper(NewStr, N, NewAcc).


