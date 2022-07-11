%%%-------------------------------------------------------------------
%% @doc quotes public API
%% @end
%%%-------------------------------------------------------------------

-module(quotes_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
                                      {'_', [{"/quote", handler, []}]}
                                     ]),
    {ok, _} = cowboy:start_clear(http,
                                 [{port, 8228}],
                                 #{env => #{dispatch => Dispatch}}
                                ),
    quotes_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http).

%% internal functions
