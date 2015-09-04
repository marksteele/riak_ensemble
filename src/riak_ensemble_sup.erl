%% -------------------------------------------------------------------
%%
%% Copyright (c) 2013 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------
-module(riak_ensemble_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_link/1]).

-export([engage/0,
         disengage/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link(Path) ->
    application:set_env(riak_ensemble, data_root, Path),
    start_link().

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

engage() ->
    lists:foreach(fun ensure_child/1, children()).

disengage() ->
    lists:foreach(fun(Id) -> supervisor:terminate_child(?MODULE, Id) end,
                  children_ids()).

%% Must protect against multiple calls to engange/0
ensure_child({Id, _, _, _, _, _}=ChildSpec) ->
    case supervisor:start_child(?MODULE, ChildSpec) of
        {ok, _} ->
            ok;
        {ok, _, _} ->
            ok;
        {error, {already_started, _}} ->
            ok;
        {error, already_present} ->
            case supervisor:restart_child(?MODULE, Id) of
                {ok, _} ->
                    ok;
                {ok, _, _} ->
                    ok;
                {error, Okay} when Okay==running orelse Okay==restarting ->
                    ok;
                {error, Error} ->
                    exit({riak_ensemble_ensure_child_restart, Error})
            end;
        {error, Error} ->
            exit({riak_ensemble_ensure_child, Error})
    end.

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    riak_ensemble_test:setup(),
    synctree_leveldb:init_ets(),
    Children = [],
    {ok, {{rest_for_one, 5, 10}, Children}}.

%% @doc to be started when asked to do so from riak_ensemble_manager.
children() ->
    [?CHILD(riak_ensemble_router_sup, supervisor),
     ?CHILD(riak_ensemble_storage, worker),
     ?CHILD(riak_ensemble_peer_sup, supervisor),
     ?CHILD(riak_ensemble_manager, worker)].

children_ids() ->
    [ Id
      || {Id,_,_,_,_,_} <- children()].
