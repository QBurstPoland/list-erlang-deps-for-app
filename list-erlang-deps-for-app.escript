#!/usr/bin/env escript
%% -*- erlang -*-

-define(NAME, escript:script_name()).

-define(ERLANG_APPLICATIONS,
[
%% Basic
compiler,
erts,
kernel,
sasl,
stdlib,
%% Database
mnesia,
odbc,
%% Operation & Maintenance
os_mon,
otp_mibs,
snmp,
%% Interface and Communication
asn1,
crypto,
diameter,
eldap,
erl_interface,
gs,
inets,
jinterface,
megaco,
public_key,
ssh,
ssl,
wx,
xmerl,
%% Tools
debugger,
dialyzer,
et,
observer,
parsetools,
percept,
reltool,
runtime_tools,
syntax_tools,
tools,
typer,
webtool,
%% Test
common_test,
eunit,
test_server,
%% Documentation
edoc,
erl_docgen,
%% Object Request Broker & IDL
cosEvent,
cosEventDomain,
cosFileTransfer,
cosNotification,
cosProperty,
cosTime,
cosTransactions,
ic,
orber,
%% Miscellaneous
hipe,
ose
]).

-define(SPEC,
[
{cwd,           $c,         "cwd",          {string, "."},      "Main application root directory"},
{output,        $o,         "output",       {atom, bash},       "Desired output format, either erlang or bash"}
]).

%% --------------------------------------------------
%% Entry point
%% --------------------------------------------------

main(["--help"]) ->
    load_getopt(),
    Usage = getopt:usage(
        ?SPEC, ?NAME, "[files ...]",
        [{"files", "Optional list of .app.src files to parse instead of automatically finding them in cwd"}]
    ),
    print(bash, Usage);
main(Args) ->
    load_getopt(),
    ParsedArgs = getopt:parse(?SPEC, Args),
    {ok, {ArgsProplist, MaybeAppSrcs}} = ParsedArgs,
    OutputFormat = proplists:get_value(output, ArgsProplist),
    Cwd = proplists:get_value(cwd, ArgsProplist),
    print_used_erlang_applications(OutputFormat, Cwd, MaybeAppSrcs).

load_getopt() ->
    EscriptDir = filename:absname(filename:dirname(escript:script_name())),
    true = code:add_path(EscriptDir),
    {module, _Module} = code:ensure_loaded(getopt).

%% --------------------------------------------------
%% Script steps and definitions
%% --------------------------------------------------

print_used_erlang_applications(OutputFormat, Cwd, []) ->
    RawAppSrcs = filelib:wildcard("**/*.app.src", Cwd),
    MaybeAppSrcs = [get_appsrc_path(Cwd, RawAppSrc) || RawAppSrc <- RawAppSrcs],
    AppSrcs = lists:filter(fun(MaybeAppSrc) -> filelib:is_regular(MaybeAppSrc) end, MaybeAppSrcs),
    print_used_erlang_applications(OutputFormat, Cwd, AppSrcs);
print_used_erlang_applications(OutputFormat, _Cwd, AppSrcs) ->
    UsedErlangApplications = get_used_erlang_applications(AppSrcs),
    final_print_used_erlang_applications(OutputFormat, UsedErlangApplications).

final_print_used_erlang_applications(erlang, UsedErlangApplications) ->
    print(erlang, UsedErlangApplications);
final_print_used_erlang_applications(bash, UsedErlangApplications) ->
    ProcessedUsedErlangApplications = lists:foldl(
        fun(Element, Acc) -> io_lib:format("~s ~s", [Acc, Element]) end,
    hd(UsedErlangApplications), tl(UsedErlangApplications)),
    print(bash, ProcessedUsedErlangApplications).

get_used_erlang_applications(AppSrcs) ->
    get_used_erlang_applications(AppSrcs, []).
get_used_erlang_applications([AppSrc|Rest], Acc) ->
    ErlangApps = get_used_erlang_applications_in_app_src(AppSrc),
    get_used_erlang_applications(Rest, lists:umerge(Acc, ErlangApps));
get_used_erlang_applications([], Acc) ->
    Acc.

get_used_erlang_applications_in_app_src(AppSrc) ->
    {ok, [Application]} = file:consult(AppSrc),
    ApplicationDescription = element(3, Application),
    Dependencies = proplists:get_value(applications, ApplicationDescription, []),
    ErlangDependencies = lists:filter(fun(App) -> is_erlang_application(App) end, Dependencies),
    lists:sort(ErlangDependencies).

get_appsrc_path(Cwd, AppSrc) -> filename:join(Cwd, AppSrc).

is_erlang_application(App) -> lists:member(App, ?ERLANG_APPLICATIONS).

print(erlang, ToPrint) ->
    io:format("~p", [ToPrint]);
print(bash, ToPrint) ->
    io:format("~s", [ToPrint]).
