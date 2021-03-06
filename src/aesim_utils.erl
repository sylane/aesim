-module(aesim_utils).

%=== INCLUDES ==================================================================

-include_lib("stdlib/include/assert.hrl").
-include("aesim_types.hrl").

%=== EXPORTS ===================================================================

-export([address_group/1]).
-export([format/2]).
-export([format_time/1]).
-export([format_minimal_time/1]).
-export([rand/1, rand/2]).
-export([skewed_rand/2]).
-export([rand_take/1, rand_take/2]).
-export([rand_pick/1, rand_pick/2, rand_pick/3]).
-export([list_add_new/2]).
-export([reduce_metric/1]).
-export([sum/1]).

%=== API FUNCTIONS =============================================================


-spec address_group(address()) -> address_group().
address_group({{A, B, _ ,_}, _}) -> {A, B}.

-spec format(string(), [term()]) -> string().
format(Format, Params) ->
  lists:flatten(io_lib:format(Format, Params)).

-spec format_time(non_neg_integer()) -> string().
format_time(Miliseconds) ->
  Sec = Miliseconds div 1000,
  Min = Sec div 60,
  Hour = Min div 60,
  Args = [Hour, Min rem 60, Sec rem 60, Miliseconds rem 1000],
  format("~bh~2.10.0bm~2.10.0bs~3.10.0b", Args).

-spec format_minimal_time(non_neg_integer()) -> string().
format_minimal_time(Miliseconds) ->
  Sec = Miliseconds div 1000,
  Min = Sec div 60,
  Hour = Min div 60,
  Parts = [{"", Miliseconds rem 1000}, {"s", Sec rem 60},
           {"m", Min rem 60}, {"h", Hour}],
  IoList = lists:foldl(fun
    ({_Postfix, 0}, Acc) -> Acc;
    ({Postfix, Value}, Acc) -> [integer_to_list(Value), Postfix | Acc]
  end, [], Parts),
  lists:flatten(IoList).

%% Returns X where 0 <= X < N
-spec rand(non_neg_integer()) -> non_neg_integer().
rand(N) -> rand:uniform(N) - 1.

%% @doc Generates a random integer with a skewed distribution.
%% If the given skew is `1` the distribution is uniform.
%% The more the skew is larger than `1` the more the distribution is skewed
%% toward the small values.
-spec skewed_rand(non_neg_integer(), float()) -> non_neg_integer().
skewed_rand(N, Skew) ->
  floor(N * math:pow(rand:uniform(), Skew)).

%% Returns X where N <= X < M
-spec rand(non_neg_integer(), non_neg_integer()) -> non_neg_integer().
rand(N, M) -> N + rand:uniform(M - N) - 1.

-spec rand_take(list()) -> {term(), list()}.
rand_take(Col) when is_list(Col)->
  {L1, [R | L2]} = lists:split(rand(length(Col)), Col),
  {R, L1 ++ L2}.

-spec rand_take(pos_integer(), list()) -> {[term()], list()}.
rand_take(1, Col) when is_list(Col) ->
  {Item, L} = rand_take(Col),
  {[Item], L};
rand_take(N, Col) when is_list(Col), N > 1 ->
  {Item, L1} = rand_take(Col),
  {Items, L2} = rand_take(N - 1, L1),
  {[Item | Items], L2}.

-spec rand_pick(list()) -> term().
rand_pick(Col) when is_list(Col) -> lists:nth(1 + rand(length(Col)), Col).

-spec rand_pick(pos_integer(), list(), list()) -> [term()].
rand_pick(N, Col) when is_list(Col), N > 0 ->
  {Items, _} = rand_take(N, Col),
  Items.

%% Really basic implementation....
-spec rand_pick(pos_integer(), list()) -> [term()].
rand_pick(_, [], _) -> [];
rand_pick(0, _, _) -> [];
rand_pick(N, Col, Exclude) when is_list(Col), N > 0 ->
  {L1, [R | L2]} = lists:split(rand(length(Col)), Col),
  case lists:member(R, Exclude) of
    true -> rand_pick(N, L1 ++ L2, Exclude);
    false -> [R | rand_pick(N - 1, L1 ++ L2, Exclude)]
  end.

-spec list_add_new(term(), list()) -> list().
list_add_new(Value, List) ->
  case lists:member(Value, List) of
    false -> [Value | List];
    true -> List
  end.

-spec reduce_metric([integer()]) -> {integer(), integer(), integer(), integer()}.
reduce_metric([_|_] = Values) ->
  {Total, Min, Max, Count} = lists:foldl(fun(V, {T, Mn, Mx, C}) ->
    {T + V, safe_min(Mn, V), safe_max(Mx, V), C + 1}
  end, {0, undefined, undefined, 0}, Values),
  Avg = round(Total / Count),
  Median = lists:nth(max(Count div 2, 1), lists:sort(Values)),
  {Min, Avg, Median, Max}.

-spec sum([integer()]) -> integer().
sum(Values) ->
  lists:foldl(fun(V, Acc) -> Acc + V end, 0, Values).

%=== INTERNAL FUNCTIONS ========================================================

safe_min(undefined, V) -> V;
safe_min(V1, V2) -> min(V1, V2).

safe_max(undefined, V) -> V;
safe_max(V1, V2) -> max(V1, V2).
