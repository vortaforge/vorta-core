function #cmd_tunnel_sys:dispatch

# Dynamic gate (default off): cmd_tunnel_sys:dynamic_on enables execution.
execute if score #dynamic cmd_tunnel_cfg matches 1 at @s run function cmd_tunnel_sys:run_exec
