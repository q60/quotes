-module(handler).

-export([init/2]).

init(Req0, State) ->
    {Code, Response} = get_quote(),
    Req = cowboy_req:reply(Code,
                           #{<<"content-type">> => <<"text/plain">>},
                           Response,
                           Req0),

    {ok, Req, State}.

get_quote() ->
    Params = "method=getQuote&format=text&lang=en",
    {ok, Code, _, ClientRef} = hackney:get("https://api.forismatic.com/api/1.0/?" ++ Params,
                                           [],
                                           <<>>,
                                           []),
    case Code of
        200 ->
            {ok, Text} = hackney:body(ClientRef),
            Quote = string:strip(binary:bin_to_list(Text)),
            case re:run(Quote, "\\(.+\\)$") of
                {match, [Captured]} ->
                               {AuthorStart, AuthorLen} = Captured,
                               Author = string:strip(
                                          string:slice(Quote, AuthorStart + 1, AuthorLen - 2)
                                        ),
                               QuoteFormed = string:strip(
                                               string:slice(Quote, 0, AuthorStart)
                                             ),
                    {200, QuoteFormed ++ "\n" ++ Author};
                nomatch ->
                    {200, Quote}
            end;
        _ ->
            {Code, <<"nothing">>}
    end.
