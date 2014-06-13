%% -------------------------------------------------------------------
%%
%% Copyright (c) 2014 Basho Technologies, Inc.  All Rights Reserved.
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
-module(riak_ensemble_config).
-compile(export_all).
-include_lib("riak_ensemble_types.hrl").

%% @doc
%% The primary ensemble tick that determines the rate at which an elected
%% leader attempts to refresh its lease.
tick() ->
    500.

%% @doc
%% The follower timeout determines how long a follower waits to hear from
%% the leader before abandoning it.
follower_timeout() ->
    tick() * 2.

%% @doc
%% The election timeout used for randomized election.
election_timeout() ->
    Timeout = follower_timeout(),
    Timeout + random:uniform(Timeout).

%% @doc
%% The prefollow timeout determines how long a peer waits to hear from the
%% preliminary leader before abandoning it.
prefollow_timeout() ->
    tick() * 2.

%% @doc
%% The pending timeout determines how long a pending peer waits in the pending
%% state to hear from an existing leader.
pending_timeout() ->
    tick() * 10.

%% @doc
%% The amount of time between probe attempts.
probe_delay() ->
    1000.

%% @doc The internal timeout used by peer worker FSMs when performing gets.
local_get_timeout() ->
    30000.

%% @doc The internal timeout used by peer worker FSMs when performing puts.
local_put_timeout() ->
    infinity.

%% @doc
%% The number of leader ticks that can go by without hearing from the ensemble
%% backend.
alive_ticks() ->
    1.

%% @doc The number of peer workers/FSM processes used by the leader.
peer_workers() ->
    1.

%% @doc
%% The operation delay used by {@link riak_ensemble_storage} to coalesce
%% multiple local operations into a single disk oepration.
storage_delay() ->
    50.

%% @doc
%% The periodic tick at which {@link riak_ensemble_storage} flushes operations
%% to disk even if there are no explicit sync requests.
storage_tick() ->
    5000.
