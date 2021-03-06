%=== MACROS ====================================================================

-define(DEBUG_NODE_ID, 10).
-define(DEBUG_NODE(FMT, ARGS, ID), (fun() ->
  case (ID) =:= ?DEBUG_NODE_ID of
    false -> ok;
    true -> io:format((FMT), (ARGS))
  end
end())).

%=== TYPES =====================================================================

-type real_time() :: non_neg_integer().
-type sim_time() :: non_neg_integer().
-type delay() :: non_neg_integer().
-type id() :: pos_integer().

-type address_group() :: {0..255, 0..255}.
-type address() :: {inet:ip_address(), inet:port_number()}.
-type address_map() :: #{address() => id()}.
-type address_range() :: {binary(), 1..31}.
-type address_ranges() :: [address_range()].
-type termination_reason() :: error | frozen | sim_timeout | real_timeout | normal.

-type neighbour() :: {id(), address()}.
-type neighbours() :: [neighbour()].

-type event_id() :: id().
-type eventy_time() :: sim_time().
-type event_ref() :: {eventy_time(), event_id()}.
-type event_tag() :: term().
-type event_name() :: atom().
-type event_addr() :: [id() | atom() | reference()].

-type conn_ref() :: reference().
-type conn_type() :: inbound | outbound.
-type conn_status() :: connecting | connected.
-type conn_filter() :: conn_type() | conn_status().

-type report_type() :: simple | complete.

-type peer() :: #{
  type := trusted | normal,
  addr := address(),
  source_addr := address(),
  gossip_time := sim_time(),
  retry_count := sim_time(),
  retry_time := sim_time(),
  conn_time := sim_time()
}.

-type peers() :: #{id() => peer()}.
-type connections() :: term(). % Opaque structure, use aesim_connections with it
-type pool() :: {module(), term()}. % Opaque structure, use aesim_pool with it
-type context() :: #{
  node_id := id(),
  node_addr := address(),
  self := event_addr(),
  peers := peers(),
  conns => connections(),
  pool => pool(),
  peer_id => id(),
  conn_ref => conn_ref()
}.

-type sim() :: #{
  config := term(),
  events := term(),
  metrics := term(),
  sim_dir := undefined | string(),
  report_file := undefined | file:io_device(),
  trusted := undefined | neighbours(),
  real_start_time := real_time() | undefined, % should never be undefined
  time := sim_time(),
  max_sim_time := sim_time() | infinity,
  max_real_time := real_time() | infinity,
  progress_counter := non_neg_integer(),
  progress_phase := undefined | aesim_scenario:phase_tag(),
  progress_sim_time := sim_time(),
  progress_sim_interval := sim_time(),
  progress_real_time := real_time() | undefined, % should never be undefined
  progress_real_interval := real_time()
}.
