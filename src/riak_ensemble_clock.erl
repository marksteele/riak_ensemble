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
-module(riak_ensemble_clock).
-on_load(init/0).
-export([monotonic_time/0, monotonic_time_ms/0]).

monotonic_time() ->
    erlang:nif_error({error, not_loaded}).

monotonic_time_ms() ->
    erlang:nif_error({error, not_loaded}).

init() ->
  Path = case application:get_env(code,sopath) of
           {ok, CodePath} ->
             CodePath;
           _ ->
             case code:priv_dir(?MODULE) of
               {error, _} ->
                 EbinDir = filename:dirname(code:which(?MODULE)),
                 AppPath = filename:dirname(EbinDir),
                 filename:join(AppPath, "priv");
               CodePath ->
                 CodePath
             end
         end,
  erlang:load_nif(filename:join(Path, ?MODULE), 0).
